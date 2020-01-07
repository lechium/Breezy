#import "FindProcess.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "FBSystemServiceOpenApplicationRequest.h"
#import "breezy.h"
#import "CTBlockDescription.h"
#include <CoreFoundation/CoreFoundation.h>
#import "EXTobjc.h"

@class BindingEvaluator, LSContext, LSBundleData;

//start actual code
%group Sharingd
%hook SharingDaemon

- (_Bool)canAccessAirDropSettings:(id)arg1 {
    
    %log;
    //description of item looks like this <OS_xpc_connection: <connection: 0x133dc3790> { name = com.apple.sharingd.peer.0x133dc3790, listener = false, pid = 3731, euid = 501, egid = 501, asid = 0 }>
    //find the related pid by trimming it out of the description
    int pid = [FindProcess pidFromItemDescription:[arg1 description]];
    HBLogDebug(@"PID %i", pid);
    //exempting TVSettings from AirDrop entitlement checks so we can toggle it on and off there easier.
    boolean_t matches = [FindProcess process:pid matches:"TVSettings"];
    if (matches){
        return true;
    }
    //return true;
    return %orig;
}

%end

%hook SFAirDropTransfer

//all of this code is thoroughly documented in the README if you are having trouble understanding it.

-(void)updateWithInformation:(id)arg {
    %log;
    NSProgress *prog = [self transferProgress];
    //HBLogDebug(@"progress: %@", prog);
    NSArray <NSURL *> *items = arg[@"Items"];
    if (items.count > 0 && [prog isFinished]){
        HBLogDebug(@"info: %@", arg);
        //HBLogDebug(@"handler: %@", [self handler]);
        NSMutableArray *paths = [NSMutableArray new];
        NSMutableArray *URLS = [NSMutableArray new];
        [items enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:(@selector(isFileURL))]){
                if ([obj isFileURL]){
                    [paths addObject:[obj path]];
                } else {
                    HBLogDebug(@"obj isnt a file path: %@", obj);
                    [URLS addObject:[obj absoluteString]];
                }
            } else {
                HBLogDebug(@"doesnt respond to isFileURL: %@", obj);
                [paths addObject:[obj path]];
            }
        }];
        if (paths.count > 0 || URLS.count > 0){
            
            NSMutableDictionary *sent = [NSMutableDictionary new];
            sent[@"Files"] = arg[@"Files"];
            sent[@"LocalFiles"] = paths;
            sent[@"URLS"] = URLS;
            sent[@"SenderCompositeName"] = arg[@"SenderCompositeName"];
            sent[@"SenderComputerName"] = arg[@"SenderComputerName"];
            HBLogDebug(@"Breezy: sending user info: %@", sent);
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.breezy.kludgeh4x" object:nil userInfo:sent];
        }
    }
    %orig;
}
%end

%hook SDAirDropTransferManager

- (id)determineHandlerForTransfer:(id)transfer { 
    %log;
    id  r = %orig;
    //  if (!r){
    //For now, force all transfers to be acceptable.
    id meta = [transfer metaData];
    [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_verifiableIdentity"];
    [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_canAutoAccept"];
    id genericHandler = [[objc_getClass("SDAirDropHandlerGenericFiles") alloc] initWithTransfer:transfer bundleIdentifier:@"com.nito.nitoTV4"];
    [genericHandler activate];
    return genericHandler;
    //} else {
    //  HBLogDebug(@"Breezy: %@ created for transfer: %@", r, transfer);
    //}
    return r;
}
%end

%end //Sharingd Group

%group PineBoard

%hook PBAppDelegate

%new - (void)showSystemAlertFromAlert:(id)alert {
    %log;
    BOOL thirteenPlus = (kCFCoreFoundationVersionNumber > 1585.17); //12.4 is 1575.17, not sure what 12.4.1 is but this should be safe enough bump up
    __block id dialogManager; //13+ only
    if (thirteenPlus){
        dialogManager = [objc_getClass("PBDialogManager") sharedInstance]; //get this out of the way
    }
    NSLog(@"[Breezy] CFVersion %.2f\n", kCFCoreFoundationVersionNumber);
    NSLog(@"[Breezy] showSystemAlertFromAlert: %@", alert);
    id windowManager = [objc_getClass("PBWindowManager") sharedInstance];
    LSApplicationWorkspace *ws = [LSApplicationWorkspace defaultWorkspace];
    __block id context; //13+ only
    NSDictionary *userInfo = [alert userInfo];

    NSArray <NSDictionary *> *files = userInfo[@"Files"];
    NSArray <NSString *> *localFiles = userInfo[@"LocalFiles"];
    NSArray <NSString *> *URLS = userInfo[@"URLS"];
    __block NSMutableString *names = [NSMutableString new];
    __block id doxy = nil;
    //TODO: this could smarter, its possible the files selected dont all work in one app, need to accomodate that
    //TODO: also, the file name list should have a limit so it gets truncated at a certain point, the wall of text can get MASSIVE.
    
    [files enumerateObjectsUsingBlock:^(NSDictionary  * adFile, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = adFile[@"FileName"];
        NSString *fileType = adFile[@"FileType"];
        if (!doxy) {
            doxy = [LSDocumentProxy documentProxyForName:fileName type:fileType MIMEType:nil];
        }
        [names appendFormat:@"%@, ", fileName];
    }];
    if (names.length > 400){
        names = [NSString stringWithFormat:@"%@...", [names substringToIndex:400]];
    }
    NSArray  *applications = [ws applicationsAvailableForOpeningDocument:doxy];
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"bundleIdentifier != 'com.nito.nitoTV4'"];
    //applications = [applications filteredArrayUsingPredicate: pred];
    if (URLS.count > 0){ //we take a different path here entirely
        NSString *firstURL = URLS[0];
        [names appendString:firstURL];
        NSString *scheme = [[NSURL URLWithString:firstURL] scheme];
        NSLog(@"[Breezy] scheme: %@", scheme);
        applications = [ws applicationsAvailableForHandlingURLScheme:[[NSURL URLWithString:firstURL] scheme]];
        //PBLinkHandler is useless and we dont want to list it as an option.
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"bundleIdentifier != 'com.apple.PBLinkHandler'"];
        applications = [applications filteredArrayUsingPredicate: pred];
    }
    NSLog(@"[Breezy] names length: %lu", names.length);
    id applicationAlert = [[objc_getClass("PBUserNotificationViewControllerAlert") alloc] initWithTitle:@"AirDrop" text:[NSString stringWithFormat:@"Open '%@' with...", names]];
    NSLog(@"available applications: %@", applications);
    NSString *cancelButtonTitle = @"Cancel";
    if (applications.count == 1){ //Theres only one application, just open it automatically
        id launchApp = applications[0];
            if (URLS.count > 0){
                //process URLs
                [self openItems:URLS ofType:KBBreezyFileTypeLink withApplication:launchApp];
            } else {
                //process files
                [self openItems:localFiles ofType:KBBreezyFileTypeLocal withApplication:launchApp];
            }
        return; //returning here because we dont want to show a dialog, we are done.
    } else if (applications.count > 1){  //multiple applications available, build up the menu
        __weak typeof(applicationAlert) weakAlert = applicationAlert;
        [applications enumerateObjectsUsingBlock:^(id  _Nonnull currentApp, NSUInteger idx, BOOL * _Nonnull stop) {
            [applicationAlert addButtonWithTitle:[currentApp localizedName] type:0 handler:^{
                if (thirteenPlus) {
                    [dialogManager dismissDialogWithContext:context options:nil completion:nil];
                } else {
                    [windowManager dismissDialogViewController:weakAlert];
                }
                if (URLS.count > 0){
                    //process URLs
                    [self openItems:URLS ofType:KBBreezyFileTypeLink withApplication:currentApp];
                } else {
                    //process files
                    [self openItems:localFiles ofType:KBBreezyFileTypeLocal withApplication:currentApp];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    //leaving this here in case any of our processing actually needs to be in here..
                });
            }];
        }];
    } else { //no applications found
        cancelButtonTitle = @"OK";
        NSLog(@"no applications found to open these file(s)");
        NSString *newMessage = [NSString stringWithFormat:@"Failed to find any applications to open '%@' with", names];
        [applicationAlert setText:newMessage];
    }
    __weak typeof(applicationAlert) weakAlert = applicationAlert;
    [applicationAlert addButtonWithTitle:cancelButtonTitle type:0 handler:^{
        if (thirteenPlus) {
            [dialogManager dismissDialogWithContext:context options:nil completion:nil];
        } else {
            [windowManager dismissDialogViewController:weakAlert];
        }
    }];
    
    //done all our processing, time to show the alert!
    dispatch_async(dispatch_get_main_queue(), ^{
        if (thirteenPlus){
            context = [objc_getClass("PBDialogContext") contextWithViewController:applicationAlert];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dialogManager presentDialogWithContext:context options:@{@"PBDialogOptionPresentForcedKey": @1, @"PBDialogOptionPresentWhileScreenSaverActiveKey": @1} completion:nil];
            });
        } else {
            [windowManager presentDialogViewController:applicationAlert];
        }
    });
    //HBLogDebug(@"file: %@ of type: %@ can open in the following applications: %@",fileName, fileType, applications);
}
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    
    _Bool orig = %orig;
    %log;
    id notificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [notificationCenter addObserver:self  selector:@selector(showSystemAlertFromAlert:) name:@"com.breezy.kludgeh4x" object:nil]; //still need to get rid of this ugly eyesore
    return orig;
    
}

%new - (void)openItems:(NSArray *)items ofType:(KBBreezyFileType)fileType withApplication:(id)proxy {
    
    Class FBSOpenApplicationOptions = NSClassFromString(@"FBSOpenApplicationOptions");
    Class FBSystemServiceOpenApplicationRequest = NSClassFromString(@"FBSystemServiceOpenApplicationRequest");
    id pbProcMan = [NSClassFromString(@"PBProcessManager") sharedInstance];
    id _fbProcMan = [NSClassFromString(@"FBProcessManager") sharedInstance];
    __block id pbProcess = [_fbProcMan systemApplicationProcess];
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *_options = [NSMutableDictionary new];
        _options[FBSOpenApplicationOptionKeyActivateSuspended] = @0;
        _options[FBSOpenApplicationOptionKeyDocumentOpen4LS] = @1;
        //_options[@"LSBlockUntilComplete"] = @1; //13.0+ shouldnt hurt anything
        _options[FBSOpenApplicationOptionKeyPayloadAnnotation] = @{@"LSMoveDocumentOnOpen": @0, @"LSDocumentDropCount": [NSNumber numberWithInteger:items.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]};
        _options[FBSOpenApplicationOptionKeyPayloadOptions] = @{@"UIApplicationLaunchOptionsSourceApplicationKey": @"com.apple.PineBoard"};
        if (fileType == KBBreezyFileTypeLink){
            _options[FBSOpenApplicationOptionKeyPayloadURL] = [NSURL URLWithString:item];
        } else {
            _options[FBSOpenApplicationOptionKeyPayloadURL] = [NSURL fileURLWithPath:item];
        }
        id options = [FBSOpenApplicationOptions optionsWithDictionary:_options];
        id openAppRequest = [FBSystemServiceOpenApplicationRequest request];
        [openAppRequest setTrusted:TRUE];
        [openAppRequest setBundleIdentifier:[proxy bundleIdentifier]];
        [openAppRequest setOptions:options];
        [openAppRequest setClientProcess:pbProcess];
        if ([pbProcMan respondsToSelector:@selector(_handleOpenApplicationRequest:bundleID:options:withResult:)]){ //12.x or less
     //on 12.x and lower you cant open documents too closely together or it will throw a fit about being in the middle of a transition, this staggers each open by 1 second.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, idx * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [pbProcMan _handleOpenApplicationRequest:openAppRequest bundleID:[proxy bundleIdentifier] options:_options withResult:^(NSError *error) {
                    HBLogDebug(@"open app finished with error: %@", error);
                    if (error != nil){
                        [pbProcMan activateApplication:[proxy bundleIdentifier] openURL:_options[FBSOpenApplicationOptionKeyPayloadURL] options:_options suspended:FALSE completion:nil];
                    }
                }];
            });
        } else if ([pbProcMan respondsToSelector:@selector(_openAppFromRequest:bundleIdentifier:URL:withResult:)]){ //13.0 -> ?
            [pbProcMan _openAppFromRequest:openAppRequest bundleIdentifier:[proxy bundleIdentifier] URL:[NSURL fileURLWithPath:item] withResult:^(NSError *error) {
                HBLogDebug(@"open app finished with error: %@", error);
            }];
        } else {
            [pbProcMan _openAppFromRequest:openAppRequest bundleIdentifier:[proxy bundleIdentifier] URL:[NSURL fileURLWithPath:item] completion:^(NSError *error) {
                HBLogDebug(@"open app finished with error: %@", error);
            }];
        }
    }];
}

%end
%end //PineBoard Group

%ctor {
    NSString *processName = [[[[NSProcessInfo processInfo] arguments] lastObject] lastPathComponent];
    //HBLogDebug(@"Process name: %@", processName);
    if ([processName isEqualToString:@"PineBoard"]){
        %init(PineBoard);
    } else if ([processName isEqualToString:@"sharingd"]){
        %init(Sharingd);
    }
}
