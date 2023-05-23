#import "FindProcess.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "breezy.h"
#import "CTBlockDescription.h"
#include <CoreFoundation/CoreFoundation.h>

@class BindingEvaluator, LSContext, LSBundleData;


static NSDictionary *blessPayload(NSDictionary *payload) {
    NSMutableDictionary *blessed = [payload mutableCopy];
    // Compiler will warn about NSKeyedArchiver being ios11+ without this guard
    if (@available(tvOS 11.0, *)) {
        // Create audittoken to verify identity
        id auditToken = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"BSAuditToken"), NSSelectorFromString(@"tokenForCurrentProcess"));
        NSData *token = [NSKeyedArchiver archivedDataWithRootObject:auditToken];
        [blessed setValue:token forKey:KBBreezyAuditToken];
    }

    return blessed;
}

static BOOL isPayloadBlessed(NSDictionary *payload, NSString *expectedEntitlement) {
    // Verify the authenticity of the notifications origin
    if (@available(tvOS 11.0, *)) {
        NSData *auditTokenArchive = (NSData *)payload[KBBreezyAuditToken];
        id auditToken = [NSKeyedUnarchiver unarchivedObjectOfClass:NSClassFromString(@"BSAuditToken") fromData:auditTokenArchive error:nil];

        BOOL senderHasEntitlement = ((BOOL * (*)(id, SEL, NSString *))objc_msgSend)(auditToken, NSSelectorFromString(@"hasEntitlement:"), expectedEntitlement);
        if (!senderHasEntitlement)
        {
            NSLog(@"failed to verify sender: %d, expected: %@", senderHasEntitlement, expectedEntitlement);
            return false;
        }
    }

    return true;
}

//start actual code
%group Sharingd
%hook SharingDaemon

- (_Bool)canAccessAirDropSettings:(id)arg1 {
    
    %log;
    //description of item looks like this <OS_xpc_connection: <connection: 0x133dc3790> { name = com.apple.sharingd.peer.0x133dc3790, listener = false, pid = 3731, euid = 501, egid = 501, asid = 0 }>
    //find the related pid by trimming it out of the description
    int pid = [FindProcess pidFromItemDescription:[arg1 description]];
    NSLog(@"PID %i", pid);
    //exempting TVSettings from AirDrop entitlement checks so we can toggle it on and off there easier.
    boolean_t matches = [FindProcess process:pid matches:"TVSettings"];
    if (matches){
        return true;
    }
    //return true;
    return %orig;
}

%end


//all of this code is thoroughly documented in the README if you are having trouble understanding it.
%hook SDAirDropTransferManager

- (id)init {
    id _self = %orig;
    // Observer for responses from PineBoard - containing what the user selected on the alert
    id notificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [notificationCenter addObserver:self  selector:NSSelectorFromString(@"handleBreezyAirdropPermissionResponse:") name:KBBreezyAirdropPresentAlert object:KBBreezyRespondToPermission];

    return _self;
}

- (id)determineHandlerForTransfer:(id)transfer { 
    %log;

    id genericHandler = [[%c(SDAirDropHandlerGenericFiles) alloc] initWithTransfer:transfer bundleIdentifier:@"com.nito.nitoTV4"];
    // [genericHandler prepareOrPerformOpenAction];
    // [genericHandler updatePossibleActions];
    ((void (*)(id, SEL))objc_msgSend)(genericHandler, NSSelectorFromString(@"prepareOrPerformOpenAction"));
    ((void (*)(id, SEL))objc_msgSend)(genericHandler, NSSelectorFromString(@"updatePossibleActions"));
    [genericHandler activate];
    
    return genericHandler;
}

- (void)askEventForRecordID:(id)recordID withResults:(id)results {
    
    %orig;

    SFAirDropTransfer *transfer = ((NSDictionary *(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"transferIdentifierToTransfer"))[recordID];
    // Requests from trusted devices don't need the alert
    if ([[[transfer metaData] valueForKey:@"_canAutoAccept"] boolValue] == true) {
        return;
    }

    // Sending device's name
    NSString *sender = [[transfer metaData] valueForKey:@"_senderComputerName"];

    NSArray *transferItems = [[[transfer metaData] valueForKey:@"_items"] allObjects];
    NSLog(@"[Breezy] transferItems: %@", transferItems);
    NSString *alertText;
    if ([transferItems count] == 1) {
        // One file being transfered. Try to determine what kind of file it is
        NSString *type = [transferItems[0] valueForKey:@"_type"];
        NSString *fileDescription = UTTypeCopyDescription(type);
        if (fileDescription) {
            alertText = [NSString stringWithFormat:@"\"%@\" would like to share a %@ file.", sender, fileDescription];
        }
        else {
            // Unknown file type
            alertText = [NSString stringWithFormat:@"\"%@\" would like to share a file.", sender];
        }
    }
    else {
        // Multiple files
        alertText = [NSString stringWithFormat:@"\"%@\" would like to share multiple files.", sender];
    }

    // Construct serializable preview image if needed
    NSData *previewImageData = [NSData new];
    CGImageRef previewImage = (__bridge CGImageRef)[[transfer metaData] valueForKey:@"_previewImage"];
    if (previewImage) {

        CFMutableDataRef newImageData = CFDataCreateMutable(NULL, 0);
        CFStringRef type = UTTypeCreatePreferredIdentifierForTag(CFSTR("public.mime-type"), CFSTR("image/png"), CFSTR("public.image"));
        CGImageDestinationRef destination = CGImageDestinationCreateWithData(newImageData, type, 1, NULL);
        CFRelease(type);
        CGImageDestinationAddImage(destination, previewImage, nil);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
        previewImageData = (__bridge_transfer NSData *)newImageData;
    }

    // Construct the alert request
    NSDictionary *payload = @{
        KBBreezyAirdropTransferRecordID: recordID,
        KBBreezyAlertTitle: @"AirDrop",
        KBBreezyAlertDetail: alertText,
        KBBreezyAlertPreviewImage: previewImageData,
        KBBreezyButtonDefinitions: @[
            @{
                KBBreezyButtonTitle: @"Accept",
                KBBreezyButtonAction: KBBreezyButtonActionAccept,
            },
            @{
                KBBreezyButtonTitle: @"Decline",
                KBBreezyButtonAction: KBBreezyButtonActionDeny,
            }
        ]
    };
    payload = blessPayload(payload);

    NSLog(@"transfer preview image data %@", previewImage);
    NSLog(@"preview image as nsdata %d bytes", (int)[previewImageData length]);
    NSLog(@"notification to pineboard: %@", payload);

    // Ask Pineboard to present it
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:KBBreezyAirdropPresentAlert object:KBBreezyRequestPermission userInfo:payload];
}

-(void)finishedEventForRecordID:(id)recordID withResults:(id)arg
{
    SFAirDropTransfer *transfer = ((NSDictionary *(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"transferIdentifierToTransfer"))[recordID];
    NSArray <NSURL *> *items = arg[@"Items"];
    if (items.count > 0) {

        NSMutableArray *paths = [NSMutableArray new];
        NSMutableArray *URLS = [NSMutableArray new];
        for (NSURL *obj in items) {
            if ([obj respondsToSelector:(@selector(isFileURL))]) {
                if ([obj isFileURL]) {
                    [paths addObject:[obj path]];
                } else {
                    NSLog(@"obj isnt a file path: %@", obj);
                    [URLS addObject:[obj absoluteString]];
                }
            } else {
                NSLog(@"doesnt respond to isFileURL: %@", obj);
                [paths addObject:[obj path]];
            }
        }

        if (paths.count > 0 || URLS.count > 0) {
            
            // The container for the transferred files. In some scenarios, PineBoard will be responsible for
            // cleaning this up.
            NSURL *containerLocation = ((NSURL * (*)(id, SEL, id))objc_msgSend)(self, NSSelectorFromString(@"transferURLForTransfer:"), transfer);

            NSMutableDictionary *sent = [NSMutableDictionary new];
            sent[@"Files"] = arg[@"Files"];
            sent[@"LocalFiles"] = paths;
            sent[@"URLS"] = URLS;
            sent[KBBreezyAlertTitle] = @"AirDrop";
            sent[KBBreezyAirdropCustomDestination] = [containerLocation path];

            NSLog(@"Breezy: sending user info: %@", sent);
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:KBBreezyAirdropPresentAlert object:KBBreezyOpenAirDropFiles userInfo:blessPayload((NSDictionary *)sent)];
        }
    }

    // when false, sharingd will not delete the transferred files.
    BOOL shouldCleanup = false;
    ((void (*)(id, SEL, id, BOOL))objc_msgSend)(self, NSSelectorFromString(@"removeTransfer:shouldCleanup:"), transfer, shouldCleanup);
    %orig;
}

%new
- (void)handleBreezyAirdropPermissionResponse:(id)notification {
    NSDictionary *payload = [notification userInfo];

    // Sharingd does not have the entitlement to perform this :(
    // i would like to figure out some sort of check, so rogue process can't send an accept request in
    // if (!isPayloadBlessed(payload, @"com.apple.backboard.client")) {
    //     return;
    // }

    NSString *recordID = payload[KBBreezyAirdropTransferRecordID];
    if (!recordID) {
        return;
    }

    NSString *selectedActionIdentifier = payload[KBBreezyAlertSelectedAction];
    id selectedAction = nil;

    SFAirDropTransfer *transfer = ((NSDictionary *(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"transferIdentifierToTransfer"))[recordID];
    NSArray *possibleActions = ((NSArray *(*)(id, SEL))objc_msgSend)(transfer, NSSelectorFromString(@"possibleActions"));

    // Determine which action is intended
    if ([selectedActionIdentifier isEqualToString:KBBreezyButtonActionAccept]) {
        // Accept is the first "possible action"
        selectedAction = possibleActions[0];
    }
    else if ([selectedActionIdentifier isEqualToString:KBBreezyButtonActionDeny]) {
        selectedAction = [transfer valueForKey:@"_cancelAction"];
    }

    // Perform selected action
    ((void (*)(id, SEL, id, id))objc_msgSend)(self, NSSelectorFromString(@"transfer:actionTriggeredForAction:"), transfer, selectedAction);
    ((void (*)(id, SEL, id))objc_msgSend)(self, NSSelectorFromString(@"transferUserResponseUpdated:"), transfer);
}

%end

%end //Sharingd Group

%group PineBoard

%hook PBAppDelegate

/*
 
 the Breezy preferences (/var/mobile/Library/Preferences/com.nito.Breezy.plist) track whether or not
 AirDrop is on AND whether or not applications will 'mimic' another to shoe-horn in AirDrop support
 utilizing code injection rather than editing a file on device.
 
 In this default example we add VLC to mimic Ethereal's AirDrop advertising settings, that means
 any file that Ethereal can open, VLC will claim it can open as well!
 
 */

%new - (NSArray *) updatedApplicationsWithMimes:(NSArray *)original {
    __block NSMutableArray *newApps = [original mutableCopy];
    NSDictionary *appMimicMap = [self appMimicMap];
    if (appMimicMap == nil){
        //setup default
        appMimicMap = @{@"com.nito.Ethereal":@[@"org.videolan.vlc-ios"]};
        [[self breezyPreferences] setObject:appMimicMap forKey:@"appMimicMap"];
        [[self breezyPreferences] synchronize];
    }
    [original enumerateObjectsUsingBlock:^(LSApplicationProxy *application, NSUInteger idx, BOOL * _Nonnull stop){
        NSString *bundleID = [application bundleIdentifier];
        if ([[appMimicMap allKeys] containsObject:bundleID]){
            id apps = [appMimicMap objectForKey:bundleID];
            [apps enumerateObjectsUsingBlock:^(id obj, NSUInteger appIdx, BOOL * _Nonnull stopA) {
               id foundProx = [LSApplicationProxy applicationProxyForIdentifier:obj];
               if (foundProx){
                    NSLog(@"found application: %@", foundProx);
                   if (![newApps containsObject:foundProx]){
                       [newApps addObject:foundProx];
                       
                   }
               }
            }];
        }
    }];
    return newApps;
}

%new - (void)showSystemAlertFromAlert:(id)alert
{
    %log;
    NSDictionary *payload = [alert userInfo];
    NSString *alertContext = [alert object];

    if ([alertContext isEqualToString:KBBreezyRespondToPermission])
    {
        return;
    }

    // Only sharingd is expected to communicate
    if (!isPayloadBlessed(payload, @"com.apple.sharing.RemoteInteractionSession")) {
        return;
    }

    // Construct the alert
    id applicationAlert = [[%c(PBUserNotificationViewControllerAlert) alloc] initWithTitle:payload[KBBreezyAlertTitle] text:payload[KBBreezyAlertDetail]];
    __weak typeof(applicationAlert) weakApplicationAlert = applicationAlert;

    // Dismiss handler has special behavior depending on os version
    void (^dismissAlert)(void) = nil;
    void (^presentAlert)(void) = nil;

    if (kCFCoreFoundationVersionNumber > 1585.17)
    {
        // iOS 13+
        __block id ios13AlertContext = nil;
        presentAlert = ^(void) {
            ios13AlertContext = [%c(PBDialogContext) contextWithViewController:applicationAlert];
            [[%c(PBDialogManager) sharedInstance] presentDialogWithContext:ios13AlertContext options:@{@"PBDialogOptionPresentForcedKey": @1, @"PBDialogOptionPresentWhileScreenSaverActiveKey": @1} completion:nil];
        };

        dismissAlert = ^void(void) {
            [[%c(PBDialogManager) sharedInstance] dismissDialogWithContext:ios13AlertContext options:nil completion:nil];
        };
    }
    else
    {
        // iOS 12 and under
        id windowManager = [%c(PBWindowManager) sharedInstance];
        presentAlert = ^(void) {
            [windowManager presentDialogViewController:applicationAlert];
        };

        dismissAlert = ^void(void) {
            [windowManager dismissDialogViewController:weakApplicationAlert];
        };
    }
    
    if ([alertContext isEqualToString:KBBreezyRequestPermission]) {

        // Construct the buttons
        for (NSDictionary *buttonDefinition in payload[KBBreezyButtonDefinitions])
        {
            [applicationAlert addButtonWithTitle:buttonDefinition[KBBreezyButtonTitle] type:0 handler:^{
                // Send the answer back
                NSDictionary *responsePayload = @{
                    KBBreezyAirdropTransferRecordID: payload[KBBreezyAirdropTransferRecordID],
                    KBBreezyAlertSelectedAction: buttonDefinition[KBBreezyButtonAction]
                };
                [[NSDistributedNotificationCenter defaultCenter] postNotificationName:KBBreezyAirdropPresentAlert object:KBBreezyRespondToPermission userInfo:responsePayload];
                // Dismiss the alert
                dismissAlert();
            }];
        }

        // Handle preview image if needed
        NSData *previewImageData = payload[KBBreezyAlertPreviewImage];

        NSLog(@"pineboard received notification: %@", payload);
        NSLog(@"pineboard preview image: %d bytes", (int)[previewImageData length]);

        if (previewImageData) {

            // Construct UIImage from data
            CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)previewImageData);
            CGImageRef imageRef = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
            CGDataProviderRelease(imgDataProvider);
            UIImage *previewImage = [[UIImage alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);

            NSLog(@"pineboard constructed uiimage %@", previewImage);

            // Add it to the alert
            // [applicationAlert setHeaderImage:previewImage];
            ((void (*)(id, SEL, id))objc_msgSend)(applicationAlert, NSSelectorFromString(@"setHeaderImage:"), previewImage);

            id headerImage = ((id (*)(id, SEL))objc_msgSend)(applicationAlert, NSSelectorFromString(@"headerImage"));
            NSLog(@"pineboard alert's header image: %@", headerImage);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            presentAlert();
        });
    }
    else if ([alertContext isEqualToString:KBBreezyOpenAirDropFiles]) {
        NSLog(@"[Breezy] CFVersion %.2f\n", kCFCoreFoundationVersionNumber);
        NSLog(@"[Breezy] showSystemAlertFromAlert: %@", alert);

        LSApplicationWorkspace *ws = [LSApplicationWorkspace defaultWorkspace];
        NSDictionary *userInfo = [alert userInfo];
        NSArray <NSDictionary *> *files = userInfo[@"Files"];
        NSArray <NSString *> *localFiles = userInfo[@"LocalFiles"];
        NSArray <NSString *> *URLS = userInfo[@"URLS"];
        __block NSMutableString *names = [NSMutableString new];
        __block id doxy = nil;

        // If the alert is cancelled or no compatible apps are installed, this handler will delete the airdropped files
        void (^cleanupFiles)(void) = ^void(void) {
            NSString *airdropContainer = payload[KBBreezyAirdropCustomDestination];
            if ([[NSFileManager defaultManager] fileExistsAtPath:airdropContainer]) {
                [[NSFileManager defaultManager] removeItemAtPath:airdropContainer error:nil];
            }
        };
	//array of items that will be forced to open through nitoTV if no app is 'found'
	NSArray *_forcedNitoExceptions = @[@"deb"];
        //TODO: this could smarter, its possible the files selected dont all work in one app, need to accomodate that
	__block BOOL hasMC = FALSE; //hacky check for mobileconfig to go through wireguard if applicable
        __block BOOL hasIPA = FALSE; //kinda of a hacky check to make sure IPA's go through ReProvision if its avail.
        __block BOOL nitoForce = FALSE; //ditto hacky check for deb
        [files enumerateObjectsUsingBlock:^(NSDictionary  * adFile, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *fileName = adFile[@"FileName"];
            NSString *fileType = adFile[@"FileType"];
	    if ([[[fileType pathExtension] lowercaseString] isEqualToString:@"mobileconfig"] || [[[fileName pathExtension] lowercaseString] isEqualToString:@"mobileconfig"]){
                hasMC = TRUE;
            }
            if ([[[fileType pathExtension] lowercaseString] isEqualToString:@"ipa"] || [[[fileName pathExtension] lowercaseString] isEqualToString:@"ipa"]){
                hasIPA = TRUE;
            }
	    if ([_forcedNitoExceptions containsObject:fileType.pathExtension.lowercaseString] || [_forcedNitoExceptions containsObject:fileName.pathExtension.lowercaseString]){
                nitoForce = TRUE;
		//below is some experimental code that got left in by accident, keeping for research purposes
		/*
                NSString * UTI = (__bridge NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, 
                                                                   (CFStringRef)@"ipa", 
                                                                   NULL);
                NSLog(@"[Breezy] mobile config UTI: %@", UTI);
                CFURLRef ur = UTTypeCopyDeclaringBundleURL(UTI);
                NSLog(@"[Breezy] url: %@", (__bridge NSURL *)ur);
                NSString *str = (__bridge NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI,kUTTagClassMIMEType);
                NSLog(@"[Breezy] MIME type: %@", str);
		*/
	    }
            //h4x, we are only creating doxy if it doesnt already exist, so that means we are only taking into account the file type of the first file in the list.
            if (!doxy) {
                doxy = [LSDocumentProxy documentProxyForName:fileName type:fileType MIMEType:nil];
            }
            // Add comma if there are more files after this one
            [names appendString:fileName];
            if (idx < [files count] - 1) {
                [names appendString:@", "];
            }
        }];
   
        NSString *appList = names;
        if (names.length > 400){
            appList = [NSString stringWithFormat:@"%@...", [names substringToIndex:400]];
        }
        [applicationAlert setText:[NSString stringWithFormat:@"Open \"%@\" with...", appList]];

        NSArray *applications = [ws applicationsAvailableForOpeningDocument:doxy];
        //NSPredicate *pred = [NSPredicate predicateWithFormat:@"bundleIdentifier != 'com.nito.nitoTV4'"];
        //applications = [applications filteredArrayUsingPredicate: pred];
        if (URLS.count > 0){ //we take a different path here
            NSString *firstURL = URLS[0];
            [names appendString:firstURL];
            NSString *scheme = [[NSURL URLWithString:firstURL] scheme];
            NSLog(@"[Breezy] scheme: %@", scheme);
            applications = [ws applicationsAvailableForHandlingURLScheme:[[NSURL URLWithString:firstURL] scheme]];
            //PBLinkHandler is useless and we dont want to list it as an option.
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"bundleIdentifier != 'com.apple.PBLinkHandler'"];
            applications = [applications filteredArrayUsingPredicate: pred];
        }

        // create the alert, we may not end up using it if theres only one application
        NSLog(@"[Breezy] available applications: %@", applications);
        NSString *cancelButtonTitle = @"Cancel";
        //let applications mimic one another to easily add AirDrop support

        // EA: not sure if intentional, but when VLC is not installed, this ends up adding a VLC app entry to the 
        // applications array. That causes this alert to contain multiple buttons (because there is multiple apps),
        // with a blank button representing the phantom VLC app.
        // I'll work around it by ignoring apps that dont have a localizedName
        applications = [self updatedApplicationsWithMimes:applications];
        NSMutableArray *realApplications = [[NSMutableArray alloc] init];
        for (id application in applications) {
            if ([application localizedName] != nil) {
                [realApplications addObject:application];
            }
        }
        applications = [realApplications copy];
        
        //this is to work around old bug that may or may not still be present for ReProvision not registering
        //for IPA support properly.
        
        if (applications.count == 0){
            if (hasIPA){
                NSLog(@"[Breezy] no applications and its an IPA file, check for ReProvision!");
                id reproCheck = [LSApplicationProxy applicationProxyForIdentifier:@"com.matchstic.reprovision.tvos"];
                if (reproCheck && [reproCheck localizedName]){
                    NSLog(@"[Breezy] found ReProvision: %@", reproCheck );
                    applications = @[reproCheck];
                }
            }
            if (nitoForce){
                NSLog(@"[Breezy] no applications and its a deb file, force to open in nitoTV");
                id ntvProx = [LSApplicationProxy applicationProxyForIdentifier:@"com.nito.nitoTV4"];
                if (ntvProx && [ntvProx localizedName]){
                    NSLog(@"[Breezy] found nitoTV: %@", ntvProx );
                    applications = @[ntvProx];
                }
            }
	    if (hasMC){
	    	NSLog(@"[Breezy] no applications and its a mobileconfig file, force to open in wireguard");
                id wgProx = [LSApplicationProxy applicationProxyForIdentifier:@"com.nito.wireguard-ios"];
                if (wgProx && [wgProx localizedName]){
                    NSLog(@"[Breezy] found wireguard: %@", wgProx );
                    applications = @[wgProx];
                }
	    }
        }
        if (applications.count == 1){ //Theres only one application, just open it automatically
            id launchApp = applications[0];
                if (URLS.count > 0){
                    //process URLs
                    [self openItems:URLS ofType:KBBreezyFileTypeLink withApplication:launchApp];
                } else {
                    //process files
                    [self openItems:localFiles ofType:KBBreezyFileTypeLocal withApplication:launchApp];
                }
                // Make sure the entire airdrop container is cleaned up, not just the transferred files
                cleanupFiles();
            return; //returning here because we dont want to show a dialog, we are done.
        } else if (applications.count > 1){  //multiple applications available, build up the menu

            [applications enumerateObjectsUsingBlock:^(id  _Nonnull currentApp, NSUInteger idx, BOOL * _Nonnull stop) {
                [applicationAlert addButtonWithTitle:[currentApp localizedName] type:0 handler:^{
                    
                    dismissAlert();

                    if (URLS.count > 0){
                        //process URLs
                        [self openItems:URLS ofType:KBBreezyFileTypeLink withApplication:currentApp];
                    } else {
                        //process files
                        [self openItems:localFiles ofType:KBBreezyFileTypeLocal withApplication:currentApp];
                    }
                    cleanupFiles();
                    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    //     //leaving this here in case any of our processing actually needs to be in here..
                    // });
                }];
            }];
        } else { //no applications found
            cancelButtonTitle = @"OK";
            NSLog(@"no applications found to open these file(s)");
            NSString *newMessage = [NSString stringWithFormat:@"Failed to find any applications to open \"%@\" with", names];
            [applicationAlert setText:newMessage];

            cleanupFiles();
        }

        [applicationAlert addButtonWithTitle:cancelButtonTitle type:0 handler:^{
            
            dismissAlert();
            cleanupFiles();
        }];
        
        //done all our processing, time to show the alert!
        presentAlert();

        //NSLog(@"file: %@ of type: %@ can open in the following applications: %@",fileName, fileType, applications);
    }
}

- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    
    _Bool orig = %orig;
    %log;
    
    // still need to get rid of this ugly eyesore
    id notificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [notificationCenter addObserver:self  selector:@selector(showSystemAlertFromAlert:) name:KBBreezyAirdropPresentAlert object:nil];

    [self setupPreferences];
    return orig;
    
}

//this never ended up being needed but im leaving it in as an example of how to hook a private C function
%new - (NSURL *)inboxForIdentifier:(NSString *)identifier {
    //dlopen("/System/Library/Frameworks/CoreServices.framework/CoreServices", RTLD_LAZY);
    MSImageRef cs = MSGetImageByName("/System/Library/Frameworks/CoreServices.framework/CoreServices");
    void *(*LSGetInboxURLForAppIdentifier)(id identifier);
    LSGetInboxURLForAppIdentifier = (void *(*)(id identifier)) MSFindSymbol(cs, "__LSGetInboxURLForAppIdentifier");
    NSLog(@"[Breezy] %p", LSGetInboxURLForAppIdentifier);
    if (LSGetInboxURLForAppIdentifier){
        NSURL *inbox = (__bridge NSURL *)(*LSGetInboxURLForAppIdentifier)(identifier);
        return inbox;
    }
    return nil;
}

/*
 
 Added this to make sure files are in a folder they can be accessed from.
 
 */

%new - (NSString *)importFile:(NSString *)inputFile withApp:(id)proxy {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSString *onePath = [[proxy dataContainerURL] path];
    if (onePath == nil){
        onePath = @"/";
    }
    NSString *cachePath = [[onePath stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:[proxy bundleIdentifier]];
    if (![man fileExistsAtPath:cachePath]){
        NSDictionary *folderAttrs = @{NSFileGroupOwnerAccountName: @"admin",NSFileOwnerAccountName: @"mobile", NSFilePosixPermissions: @755};
        NSError *error = nil;
        [man createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:folderAttrs error:&error];
        if (error){
            NSLog(@"creating %@ had error: %@", cachePath, error);
        }
    }
    NSString *newPath = [cachePath stringByAppendingPathComponent:[inputFile lastPathComponent]];
    NSError *copyError = nil;
    if ([man fileExistsAtPath:newPath]){
        [man removeItemAtPath:inputFile error:nil];
        return newPath;
    } else {
        NSLog(@"attempting to copy %@ to %@", inputFile, newPath);
        if ([man copyItemAtPath:inputFile toPath:newPath error:&copyError]) {
            [man removeItemAtPath:inputFile error:nil];
            return newPath;
        } else {
            NSLog(@"failed to copy %@ to %@ with error: %@", inputFile, newPath, copyError);
            return inputFile;
        }
    }
    return inputFile;
}

%new - (id)appMimicMap {
    
    return [[self breezyPreferences] objectForKey:@"appMimicMap"];
}

%new - (id)breezyPreferences {
    id bp = objc_getAssociatedObject(self, @selector(breezyPreferences));
    if (bp == nil){
        [[NSBundle bundleWithPath:@"/System/Library/Frameworks/TVServices.framework/"] load];
        bp = [%c(TVSPreferences) preferencesWithDomain:@"com.nito.Breezy"];
        objc_setAssociatedObject(self, @selector(breezyPreferences), bp, OBJC_ASSOCIATION_RETAIN);
    }
    return bp;
}

%new -(void)setupPreferences {
    
    //dlopen("/System/Library/Frameworks/TVServices.framework/TVServices", RTLD_NOW);
    [[NSBundle bundleWithPath:@"/System/Library/Frameworks/TVServices.framework/"] load];
    id prefs = [%c(TVSPreferences) preferencesWithDomain:@"com.nito.Breezy"];
    BOOL airdropServerState = [prefs boolForKey:@"airdropServerState"];
    NSLog(@"[Breezy] airdropServerState: %i", airdropServerState);
}

/*
 
 Meat and potatoes of opening the applications on our own, this works better than their
 operations provided in LSApplicationWorkspace to open files.
 
 Use FrontBoardServices framework in conjunction with FBProcessManager, CoreServices and Launchservices
 to create an application launch request and process it.
 
 */

%new - (void)openItems:(NSArray *)items ofType:(KBBreezyFileType)fileType withApplication:(id)proxy {
    
    Class FBSOpenApplicationOptions = %c(FBSOpenApplicationOptions);
    Class FBSystemServiceOpenApplicationRequest = %c(FBSystemServiceOpenApplicationRequest);
    id pbProcMan = [%c(PBProcessManager) sharedInstance];
    id _fbProcMan = [%c(FBProcessManager) sharedInstance];
    NSString *bundleID = [proxy bundleIdentifier];
    __block id pbProcess = [_fbProcMan systemApplicationProcess]; //Our process reference to PineBoard
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *_options = [NSMutableDictionary new];
        _options[FBSOpenApplicationOptionKeyActivateSuspended] = @0;
        _options[FBSOpenApplicationOptionKeyDocumentOpen4LS] = @1;
        _options[@"LSBlockUntilComplete"] = @1; //13.0+ shouldnt hurt anything
        _options[FBSOpenApplicationOptionKeyPayloadAnnotation] = @{@"LSMoveDocumentOnOpen": @0, @"LSDocumentDropCount": [NSNumber numberWithInteger:items.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]};
        _options[FBSOpenApplicationOptionKeyPayloadOptions] = @{@"UIApplicationLaunchOptionsSourceApplicationKey": @"com.apple.PineBoard"};
        if (fileType == KBBreezyFileTypeLink){
            _options[FBSOpenApplicationOptionKeyPayloadURL] = [NSURL URLWithString:item];
        } else {
            NSLog(@"[Breezy] og item: %@", item);
            //NSString *importedItem = [inbox stringByAppendingPathComponent:item.lastPathComponent];
            NSString *importedItem = [self importFile:item withApp:proxy];
            NSLog(@"[Breezy] imported item: %@", importedItem);
            _options[FBSOpenApplicationOptionKeyPayloadURL] = [NSURL fileURLWithPath:importedItem];
        }
        
        id options = [FBSOpenApplicationOptions optionsWithDictionary:_options];
        id openAppRequest = [FBSystemServiceOpenApplicationRequest request];
        [openAppRequest setTrusted:TRUE];
        [openAppRequest setBundleIdentifier:bundleID];
        [openAppRequest setOptions:options];
        [openAppRequest setClientProcess:pbProcess];
        CGFloat multiplier = 0.5;
        if ([_fbProcMan processesForBundleIdentifier:bundleID].count == 0){
            multiplier = 1;
            NSLog(@"App isnt running yet, bumping up the multiplier so stuff gets processed successfully");
        }
        CGFloat offset = idx*multiplier;
        
        // staggers each open by 'offset' seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, offset * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            if ([pbProcMan respondsToSelector:@selector(_handleOpenApplicationRequest:bundleID:options:withResult:)]){
                [pbProcMan _handleOpenApplicationRequest:openAppRequest bundleID:bundleID options:_options withResult:^(NSError *error) {
                    NSLog(@"open app finished with error: %@", error);
                    if (error != nil){
                        [pbProcMan activateApplication:bundleID openURL:_options[FBSOpenApplicationOptionKeyPayloadURL] options:_options suspended:FALSE completion:nil];
                    }
                }];
                
            } else if ([pbProcMan respondsToSelector:@selector(_openAppFromRequest:bundleIdentifier:URL:withResult:)]){ //13.0 -> ?
                [pbProcMan _openAppFromRequest:openAppRequest bundleIdentifier:bundleID URL:[NSURL fileURLWithPath:item] withResult:^(NSError *error) {
                    NSLog(@"open app finished with error: %@", error);
                }];
            } else {
                [pbProcMan _openAppFromRequest:openAppRequest bundleIdentifier:bundleID URL:[NSURL fileURLWithPath:item] completion:^(NSError *error) {
                    NSLog(@"open app finished with error: %@", error);
                }];
            }
        });
    }];
}

%end
%end //PineBoard Group

%ctor {
    
    NSString *processName = [[[[NSProcessInfo processInfo] arguments] lastObject] lastPathComponent];
    //NSLog(@"Process name: %@", processName);
    if ([processName isEqualToString:@"PineBoard"]){
        %init(PineBoard);

    } else if ([processName isEqualToString:@"sharingd"]){
        %init(Sharingd);
    }
}
