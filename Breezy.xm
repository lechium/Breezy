#import "FindProcess.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "FBSystemServiceOpenApplicationRequest.h"
#import "breezy.h"
#import "CTBlockDescription.h"
#include <CoreFoundation/CoreFoundation.h>


@class BindingEvaluator, LSContext, LSBundleData;

@protocol LSOpenResourceOperationDelegate <NSObject>
@optional
-(void)openResourceOperation:(id)arg1 didFailWithError:(id)arg2;
-(void)openResourceOperationDidComplete:(id)arg1;
-(void)openResourceOperation:(id)arg1 didFinishCopyingResource:(id)arg2;
@end

/**
 
 Some failed experiments to programatically add airdrop support so Info.plist doesn't need to be edited, no paydirt yet.
 
 */

/*
 %hook NSBundle
 
 - (id)infoDictionary {
 
 //%log;
 id orig = %orig;
 NSString *bundleId = [orig valueForKey:@"CFBundleIdentifier"];
 if (bundleId){
 if([[orig allKeys] containsObject:@"CFBundleDocumentTypes"]){
 HBLogDebug(@"### found bundle id", bundleId);
 }
 }
 return orig;
 }
 
 %end
 
 %hook _LSDModifyClient
 
 -(void)removeHandlerForContentType:(id)arg1 roles:(unsigned)arg2 completionHandler:(id)arg3 {
 %log;
 %orig;
 }
 
 -(void)setHandler:(id)arg1 version:(id)arg2 roles:(unsigned)arg3 forContentType:(id)arg4 completionHandler:(id)arg5 {
 
 %log;
 %orig;
 
 }
 %end
 
 
 %hook LSBundleProxy
 
 - (id)_infoDictionary {
 %log;
 id orig = %orig;
 NSString *bundleId = [self bundleIdentifier];
 id propertyList = [orig valueForKey:@"propertyList"];
 NSLog(@"%@: %@", bundleId, propertyList);
 return orig;
 }
 
 %end
 
 %hook LSApplicationProxy
 
 - (NSSet *)claimedDocumentContentTypes {
 
 id orig = %orig;
 NSString *bundleId = [self bundleIdentifier];
 NSLog(@"Breezy.xm 41: LSApplicationProxy:claimedDocumentContenTypes: %@", orig);
 NSLog(@"Breezy.xm 42: bundleId: %@", bundleId);
 if ([bundleId isEqualToString:@"com.firecore.infuse.pro.5"]){
 NSLog(@"Breezy.xm 45: Infuse test run!");
 return [NSSet setWithArray:@[@"org.xiph.oga",@"public.mpeg",@"org.videolan.mxf",@"public.audio",@"org.videolan.webm",@"org.videolan.mxg",@"public.movie",@"public.aifc-audio",@"public.avi",@"public.mpeg-4",@"com.microsoft.windows-\xe2\x80\x8bmedia-wma",@"org.videolan.idx",@"org.videolan.jss",@"com.apple.quicktime-movie",@"public.aiff-audio",@"com.real.realmedia",@"com.microsoft.windows-media-wmv",@"org.videolan.caf",@"org.videolan.w64",@"org.videolan.opus",@"public.audiovisual-content",@"org.videolan.srt",@"public.utf",@"org.videolan.smi",@"org.matroska.mkv",@"com.divx.divx",@"com.microsoft.advanced-systems-format",@"com.real.smil",@"public.3gpp2",@"org.videolan.ass",@"org.videolan.oma",@"org.videolan.aqt",@"org.videolan.psb",@"org.videolan.smil",@"org.videolan.flac",@"public.ulaw-audio",@"com.microsoft.waveform-audio",@"org.videolan.vlc",@"org.videolan.ssa",@"com.real.realaudio",@"org.xiph.ogv",@"public.mp3",@"org.videolan.sub",@"org.videolan.cdg",@"org.videolan.rt",@"public.mpeg4",@"public.video",@"public.3gpp",@"com.microsoft.windows-media-wm",@"public.mpeg-4-audio"]];
 }
 return orig;
 
 }
 
 
 %end
 
 %hook _LSLazyPropertyList
 
 -(BOOL)_getValue:(id*)arg1 forPropertyListKey:(id)arg2 {
 
 %log;
 return %orig;
 }
 
 %end
 
 %hook _LSCompoundLazyPropertyList
 
 -(BOOL)_getValue:(id*)arg1 forPropertyListKey:(id)arg2 {
 
 %log;
 return %orig;
 }
 - (id)propertyList {
 
 %log;
 id orig = %orig;
 NSString *bundleId = [orig valueForKey:@"CFBundleIdentifier"];
 if ([bundleId isEqualToString:@"target"]){
 
 }
 return orig;
 }
 
 %end
 */

%group Bro

%hook SFAirDropNode
+(id)nodeWithSFNode:(id)arg1  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(NSString *)secondaryName { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)setDisplayName:(NSString *)arg1  { %log; %orig; }
-(BOOL)isMe { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(void)setModel:(NSString *)arg1  { %log; %orig; }
-(void)setUnknown:(BOOL)arg1  { %log; %orig; }
-(void)setSecondaryName:(NSString *)arg1  { %log; %orig; }
-(void)setMe:(BOOL)arg1  { %log; %orig; }
-(NSString *)contactIdentifier { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)setContactIdentifier:(NSString *)arg1  { %log; %orig; }
-(void)setMonogram:(BOOL)arg1  { %log; %orig; }
-(BOOL)isUnknown { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(void)updateWithSFNode:(id)arg1  { %log; %orig; }
-(BOOL)isClassroom { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(BOOL)isClassroomCourse { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(BOOL)isKnown { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(void)handleOperationCallback:(id)arg1 event:(long long)arg2 withResults:(id)arg3  { %log; %orig; }
-(void)setDisplayIcon:(UIImage *)arg1  { %log; %orig; }
-(void)setRealName:(NSString *)arg1  { %log; %orig; }
-(void)cancelSend { %log; %orig; }
-(void)startSendForBundleID:(id)arg1 sessionID:(id)arg2 items:(id)arg3 description:(id)arg4 previewImage:(id)arg5  { %log; %orig; }
-(void)simulateFakeTransferWithSessionID:(id)arg1  { %log; %orig; }
-(NSString *)realName { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(UIImage *)displayIcon { %log; UIImage * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(BOOL)isMonogram { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(void)setClassroom:(BOOL)arg1  { %log; %orig; }
-(BOOL)isclassroomGroup { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(void)setClassroomGroup:(BOOL)arg1  { %log; %orig; }
-(void)setClassroomCourse:(BOOL)arg1  { %log; %orig; }
-(BOOL)supportsCredentials { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(BOOL)supportsFMF { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(BOOL)supportsPasses { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(BOOL)supportsMixedTypes { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(NSDate *)discoveryDate { %log; NSDate * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)init { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(BOOL)isEqual:(id)arg1  { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(unsigned long long)hash { %log; unsigned long long r = %orig; HBLogDebug(@" = %llu", r); return r; }
-(id)description { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)node { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)setNode:(id)arg1  { %log; %orig; }
-(NSString *)model { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(NSString *)displayName { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
%end


%hook MCMContainerManager
+(id)defaultManager { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)init { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)containerWithContentClass:(long long)arg1 identifier:(id)arg2 error:(id*)arg3  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)containerWithContentClass:(long long)arg1 identifier:(id)arg2 createIfNecessary:(BOOL)arg3 existed:(BOOL*)arg4 error:(id*)arg5  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)temporaryContainerWithContentClass:(long long)arg1 identifier:(id)arg2 existed:(BOOL*)arg3 error:(id*)arg4  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)containersWithClass:(long long)arg1 error:(id*)arg2  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)temporaryContainersWithClass:(long long)arg1 error:(id*)arg2  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)deleteContainers:(id)arg1 withCompletion:(/*^block*/id)arg2  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(BOOL)replaceContainer:(id)arg1 withContainer:(id)arg2 error:(id*)arg3  { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(BOOL)replaceContainer:(id)arg1 withContainer:(id)arg2 error:(id*)arg3 withCompletion:(/*^block*/id)arg4  { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(id)_containersWithClass:(long long)arg1 temporary:(BOOL)arg2 error:(id*)arg3  { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
%end
%end

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

/*
 
 ###### info: {
 AutoAccept = 1;
 BundleID = "com.apple.finder";
 BytesCopied = 447;
 "Content-Type" = "application/x-dvzip";
 Files =     (
 {
 ConvertMediaFormats = 0;
 FileBomPath = "./FindProcess.h";
 FileIsDirectory = 0;
 FileName = "FindProcess.h";
 FileType = "public.c-header";
 }
 );
 FilesCopied = 0;
 Items =     (
 "file:///var/mobile/Downloads/com.apple.AirDrop/39F5E35B-1B94-41F4-9E5E-41D4D0C214F7/Files/FindProcess.h"
 );
 SenderCompositeName = "Kevin Bradley";
 SenderComputerName = ;
 SenderEmail = "";
 SenderFirstName = Kevin;
 SenderID = ;
 SenderIcon = <89504e47 0d0a1a0a 0000000d 49484452 000000fa 000000fa 08060000 0088ec5a 3d000000 01735247 4200aece 1ce90000 001c6944 4f540000 00020000 00000000 007d0000 00280000 007d0000 007d0000 0ecbdf9c ec3e0000 0e974944 41547801 ec5d0bac 1d5515bd b4b528c5 f22d890a 1a032526 52b5368a 34942616 29d49818 4ac1ca
 
 
 ###### meta items: {(
 <SFAirDropTransferItem 0x0223, type: public.c-header, count: 1, isFile: yes>
 )}
 */

//all of this code is thoroughly documented in the README if you are having trouble understanding it.

-(void)updateWithInformation:(id)arg {
    %log;
    NSProgress *prog = [self transferProgress];
    HBLogDebug(@"progress: %@", prog);
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
            /*
             NSData *imageData = arg[@"SenderIcon"];
             HBLogDebug(@"writing image data: %@", imageData);
             NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *filePath = [@"/private/var/tmp" stringByAppendingPathComponent:@"SenderIcon.png"];
             HBLogDebug(@"filePath: %@", filePath);
             [imageData writeToFile:filePath atomically:TRUE];
             */
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.breezy.kludgeh4x" object:nil userInfo:sent];
        }
    }
    %orig;
}
%end

%hook SDAirDropTransferManager

//actually saw this create something successfully for the "first" time?
/*
 
 [1;36m[Breezy] [m[0;36mBreezy.xm:306[m [0;30;46mDEBUG:[m Breezy: <sharingd.SDAirDropHandlerIPA 0x1733, transferIdentifier: 3DDCEF16-2B7A-48DD-8CC8-A45BC6FBA62E> created for transfer: <SFAirDropTransfer 0x1991, identifier: 3DDCEF16-2B7A-48DD-8CC8-A45BC6FBA62E, transferState: Unknown, userResponse: None, needsAction: yes, possibleActions: NULL, metadata: <SFAirDropTransferMetaData 0xFCA3, transferTypes: [Unclassified], verifiableIdentity: yes, hasContactIdentifier: yes, senderIsMe: yes, canAutoAccept: yes, sender: "nitoMBP", hasPreviewImage: yes, hasSmallPreviewImage: yes>>
 
 */


- (id)determineHandlerForTransfer:(id)transfer { 
    %log;
    id  r = %orig;
    //  if (!r){
    //For now, force all transfers to be acceptable.
    id meta = [transfer metaData];
    [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_verifiableIdentity"];
    [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_canAutoAccept"];
    //[FindProcess classDumpObject:meta];
    //NSLog(@"###### meta items: %@", [meta items]);
    //HBLogDebug(@"meta rawFiles: %@", [meta rawFiles]);
    //HBLogDebug(@"meta rawFiles: %@", [meta itemsDescriptionAdvanced]);
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

%hook PBProcessManager

- (void)_openApp:(id)arg1 options:(id)arg2 origin:(id)arg3 withResult:(id)arg4 {
    %log;
    %orig;
}
- (void)_handleOpenApplicationRequest:(id)arg1 bundleID:(id)arg2 options:(id)arg3 withResult:(id)arg4 {
    %log;
    %orig;
    if (arg4 != nil){
        CTBlockDescription *blockDescription = [[CTBlockDescription alloc] initWithBlock:arg4];
        NSMethodSignature *methodSignature = blockDescription.blockSignature;
        HBLogDebug(@"result: %@", [methodSignature debugDescription]);
    }
    
}
- (void)systemService:(id)arg1 handleOpenApplicationRequest:(id)arg2 withCompletion:(id)arg3 {
    %log;
    %orig;
}
-(void)_openAppFromRequest:(id)arg1 bundleIdentifier:(id)arg2 URL:(id)arg3 completion:(/*^block*/id)arg4  {
    %log;
    HBLogDebug(@"[Breezy] request: %@", arg1);
    HBLogDebug(@"[Breezy] bundleIdentifier: %@", arg2);
    HBLogDebug(@"[Breezy] URL: %@", arg3);
    if (arg4 != nil){
        CTBlockDescription *blockDescription = [[CTBlockDescription alloc] initWithBlock:arg4];
        NSMethodSignature *methodSignature = blockDescription.blockSignature;
        HBLogDebug(@"[Breezy] completion: %@", [methodSignature debugDescription]);
    }
    %orig;
}

-(void)openApplication:(id)arg1 launchURL:(id)arg2 options:(id)arg3 suspended:(BOOL)arg4 completion:(/*^block*/id)arg5  {
    %log;
    %orig;
}
%end

%hook PBAppDelegate


//add these delegate methods to handle when operations are complete, this is the proper way to do it. nothing else works.

%new -(void)openResourceOperation:(id)arg1 didFailWithError:(id)arg2 {
    %log;
    //TODO: should probably do some error handling here
    HBLogDebug(@"failed with error: %@", arg2);
    [[self operationArray] removeObject:arg1];
    [self runNextOperation];
}

%new - (void)openResourceOperationDidComplete:(id)arg1 {
    %log;
    [[self operationArray] removeObject:arg1];
    [self runNextOperation];
}

%new - (void)openResourceOperation:(id)arg1 didFinishCopyingResource:(id)arg2 {
    
    %log;
    [self postBulletinForFile:[arg2 lastPathComponent]];
}
%new - (void)runNextOperation {
    
    HBLogDebug(@"runNextOp operations: %@", [self operationArray]);
    if ([[self operationArray] count] == 0){
        HBLogDebug(@"no operations left!");
    } else {
        NSOperation *firstObject = [[self operationArray] firstObject];
        HBLogDebug(@"next operation: %@", firstObject);
        [firstObject start];
    }
    
}

%new - (NSMutableArray *)operationArray {
    id ooq = objc_getAssociatedObject(self, @selector(operationArray));
    if (ooq == nil){
        ooq = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(operationArray), ooq, OBJC_ASSOCIATION_RETAIN);
    }
    return ooq;
}
//__UTTypeAddWithDeclarationDictionary
//a bit misleading, reports can come here and the import MIGHT have failed FIXME:
%new - (void)postBulletinForFile:(NSString *)fileName {
    NSString *message = [NSString stringWithFormat:@"Imported '%@' successfully!",fileName];
    NSString *title = @"Import Successful";
    [self sendBulletinWithMessage:message title:title];
}

%new - (void)sendBulletinWithMessage:(NSString *)message title:(NSString *)title {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"message"] = message;
    dict[@"title"] = title;
    dict[@"timeout"] = @2;
    NSString *imageName = @"AirDrop-large.png";
    NSString *privateFrameworks = @"/System/Library/PrivateFrameworks/";
    //different frameworks for different versions 13+ is SharingUI.framework
    NSString *sharingFW = [privateFrameworks stringByAppendingPathComponent:@"SharingUI.framework"];
    NSFileManager *man = [NSFileManager defaultManager];
    if (![man fileExistsAtPath:sharingFW]){
        sharingFW = [privateFrameworks stringByAppendingPathComponent:@"Sharing.framework"];
    }
    NSString *imagePath = [sharingFW stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData){
        dict[@"imageData"] = imageData;
    }
    //dict[@"imageID"] = @"PBSSystemBulletinImageIDTV";
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.bulletinh4x/displayBulletin" object:nil userInfo:dict];
    
}

/*
 
 notes on stringing files together to open them up, our operation creation call eventually ends up in
 _LSDOpenClient calling
 -(void)performOpenOperationWithURL:(id)arg1 applicationIdentifier:(id)arg2 documentIdentifier:(id)arg3 isContentManaged:(BOOL)arg4 sourceAuditToken:(const SCD_Struct_LS10*)arg5 userInfo:(id)arg6 options:(id)arg7 delegate:(id)arg8 completionHandler:(id)arg9
 
 can't decipher enough about how it works internally yet to try to augment or even replicate it into another function that accepts multiple files.
 
 */

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
    //NSString *name = userInfo[@"SenderCompositeName"];
    //NSString *text = [NSString stringWithFormat:@"%@ is sending a file, where would you like to open it?", name];
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
    
    NSArray  *applications = [ws applicationsAvailableForOpeningDocument:doxy];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"bundleIdentifier != 'com.nito.nitoTV4'"];
    applications = [applications filteredArrayUsingPredicate: pred];
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
    
    //get the operation array here because its a mutable array we will continue to add on to.
    NSMutableArray <NSOperation *>*opArray = [self operationArray];
    NSLog(@"available applications: %@", applications);
    NSString *cancelButtonTitle = @"Cancel";
    if (applications.count == 1){ //Theres only one application, just open it automatically
        id launchApp = applications[0];
        //if (!thirteenPlus) {
            if (URLS.count > 0){
                //process URLs
                [self legacyHandleURLs:URLS withApplication:launchApp];
            } else {
                //process files
                [self ourOpenOperationForItems:localFiles withApplication:launchApp];
            }
            return;
        //}
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            if (URLS.count > 0){
                [URLS enumerateObjectsUsingBlock:^(NSString  * fileURL, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSURL *url = [NSURL URLWithString:fileURL];
                    NSBlockOperation *operation = [ws operationToOpenResource:url usingApplication:[launchApp bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE], @"LSDocumentDropCount": [NSNumber numberWithInteger:URLS.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]} options:nil delegate:self];
                    
                    HBLogDebug(@"operation: %@", operation);
                    [opArray addObject:operation];
                }];
            } else {
                [localFiles enumerateObjectsUsingBlock:^(NSString  * localFile, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSURL *url = [NSURL fileURLWithPath:localFile];
                    
                    NSBlockOperation *operation = [ws operationToOpenResource:url usingApplication:[launchApp bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE], @"LSDocumentDropCount": [NSNumber numberWithInteger:localFiles.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]} options:nil delegate:self];
                    
                    HBLogDebug(@"operation: %@", operation);
                    [opArray addObject:operation];
                }];
            }
            [[opArray firstObject] start];
            
        });
        return;
        
    } else if (applications.count > 1){  //multiple applications available, build up the menu
        
        [applications enumerateObjectsUsingBlock:^(id  _Nonnull currentApp, NSUInteger idx, BOOL * _Nonnull stop) {
            [applicationAlert addButtonWithTitle:[currentApp localizedName] type:0 handler:^{
                
                if (thirteenPlus) {
                    [dialogManager dismissDialogWithContext:context options:nil completion:nil];
                } else {
                    [windowManager dismissDialogViewController:applicationAlert];
                    if (URLS.count > 0){
                        //process URLs
                        [self legacyHandleURLs:URLS withApplication:currentApp];
                    } else {
                        //process files
                        [self legacyHandleFiles:localFiles withApplication:currentApp];
                    }
                    return;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    if (URLS.count > 0){
                        [URLS enumerateObjectsUsingBlock:^(NSString  * fileURL, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            //NSURL *url = [NSURL fileURLWithPath:localFile];
                            NSURL *url = [NSURL URLWithString:fileURL];
                            NSBlockOperation *operation = [ws operationToOpenResource:url usingApplication:[currentApp bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE], @"LSDocumentDropCount": [NSNumber numberWithInteger:URLS.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]} options:nil delegate:self];
                            
                            HBLogDebug(@"operation: %@", operation);
                            [opArray addObject:operation];
                        }];
                    } else {
                        [localFiles enumerateObjectsUsingBlock:^(NSString  * localFile, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSURL *url = [NSURL fileURLWithPath:localFile];
                            NSBlockOperation *operation = [ws operationToOpenResource:url usingApplication:[currentApp bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE], @"LSDocumentDropCount": [NSNumber numberWithInteger:localFiles.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]} options:nil delegate:self];
                            HBLogDebug(@"operation: %@", operation);
                            [opArray addObject:operation];
                            
                            
                        }];
                    }
                    [[opArray firstObject] start];
                });
                
            }];
        }];
    } else {
        
        cancelButtonTitle = @"OK";
        NSLog(@"no applications found to open these file(s)");
        NSString *newMessage = [NSString stringWithFormat:@"Failed to find any applications to open '%@' with", names];
        [applicationAlert setText:newMessage];
    }
    
    
    
    [applicationAlert addButtonWithTitle:cancelButtonTitle type:0 handler:^{
        if (thirteenPlus) {
            [dialogManager dismissDialogWithContext:context options:nil completion:nil];
        } else {
            [windowManager dismissDialogViewController:applicationAlert];
            
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (thirteenPlus){
            context = [objc_getClass("PBDialogContext") contextWithViewController:applicationAlert];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dialogManager presentDialogWithContext:context options:@{@"PBDialogOptionPresentForcedKey": [NSNumber numberWithInteger:1], @"PBDialogOptionPresentWhileScreenSaverActiveKey": [NSNumber numberWithInteger:1]} completion:nil];
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
    [notificationCenter addObserver:self  selector:@selector(showSystemAlertFromAlert:) name:@"com.breezy.kludgeh4x" object:nil];
    return orig;
    
}

%new - (void)legacyHandleURLs:(NSArray *)items withApplication:(id)proxy {
    
    %log;
    if (items.count > 0){
        if (items.count == 1){
            NSURL *url = [NSURL URLWithString:items[0]];
            HBLogDebug(@"urL: %@", url);
            
            NSBlockOperation *operation = [[LSApplicationWorkspace defaultWorkspace] operationToOpenResource:url usingApplication:[proxy bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE]} options:nil delegate:self];
            HBLogDebug(@"operation: %@", operation);
            [operation start];
        } else {
            NSFileManager *man = [NSFileManager defaultManager];
            NSString *onePath = [[proxy dataContainerURL] path];
            if (onePath == nil){
                onePath = @"/";
            }
            NSString *cachePath = [[onePath stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:[proxy bundleIdentifier]];
            if ([man fileExistsAtPath:cachePath]){
                [man createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *tempPlistFile = [cachePath stringByAppendingPathComponent:@"AirDrop.plist"];
            [items writeToFile:tempPlistFile atomically:FALSE];
            [[LSApplicationWorkspace defaultWorkspace] openApplicationWithBundleID:[proxy bundleIdentifier]];
        }
    }
    
}

/*
 
 [1;36m[Breezy] [m[0;36mExtra.xm:141[m [0;30;46mDEBUG:[m -[<FBSOpenApplicationOptions: 0x2837fc0f0> setDictionary:{
 "__ActivateSuspended" = 0;
 "__DocumentOpen4LS" = 1;
 "__PayloadAnnotation" =     {
 LSMoveDocumentOnOpen = 1;
 };
 "__PayloadOptions" =     {
 UIApplicationLaunchOptionsSourceApplicationKey = "com.apple.PineBoard";
 };
 "__PayloadURL" = "file:///var/mobile/Library/Application%20Support/Containers/com.nito.Ethereal/Documents/Inbox/atvside.mov";
 }]
 
 default    23:44:39.860462 -0700    PineBoard    [1;36m[Breezy] [m[0;36mExtra.xm:128[m [0;30;46mDEBUG:[m +[<FBSystemServiceOpenApplicationRequest: 0x1e2fa29e0> request]
 
 */


%new - (void)ourOpenOperationForItems:(NSArray *)items withApplication:(id)proxy {
    
    Class FBSOpenApplicationOptions = NSClassFromString(@"FBSOpenApplicationOptions");
    Class FBSystemServiceOpenApplicationRequest = NSClassFromString(@"FBSystemServiceOpenApplicationRequest");
    Class PBProcessManager = NSClassFromString(@"PBProcessManager");
    id pbProcMan = [PBProcessManager sharedInstance];
    id _fbProcMan = [pbProcMan valueForKey:@"_fbProcessManager"];
    id pbProcess = [_fbProcMan processesForBundleIdentifier:@"com.apple.PineBoard"][0];
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        //LSBlockUntilComplete = 1;
        NSMutableDictionary *_ourDict = [NSMutableDictionary new];
        _ourDict[FBSOpenApplicationOptionKeyActivateSuspended] = @0;
        _ourDict[FBSOpenApplicationOptionKeyDocumentOpen4LS] = @1;
        //_ourDict[@"LSBlockUntilComplete"] = @1; //13.0+ shouldnt hurt anything
        _ourDict[FBSOpenApplicationOptionKeyPayloadAnnotation] = @{@"LSMoveDocumentOnOpen": @0, @"LSDocumentDropCount": [NSNumber numberWithInteger:items.count], @"LSDocumentDropIndex": [NSNumber numberWithInteger:idx]};
        _ourDict[FBSOpenApplicationOptionKeyPayloadOptions] = @{@"UIApplicationLaunchOptionsSourceApplicationKey": @"com.apple.PineBoard"};
        _ourDict[FBSOpenApplicationOptionKeyPayloadURL] = [NSURL fileURLWithPath:item];
        
        id options = [FBSOpenApplicationOptions optionsWithDictionary:_ourDict];
        id openAppRequest = [FBSystemServiceOpenApplicationRequest request];
        [openAppRequest setTrusted:TRUE];
        [openAppRequest setBundleIdentifier:[proxy bundleIdentifier]];
        [openAppRequest setOptions:options];
        [openAppRequest setClientProcess:pbProcess];
        if ([pbProcMan respondsToSelector:@selector(_handleOpenApplicationRequest:bundleID:options:withResult:)]){
            [pbProcMan _handleOpenApplicationRequest:openAppRequest bundleID:[proxy bundleIdentifier] options:_ourDict withResult:^(NSError *error) {
                HBLogDebug(@"open app finished with error: %@", error);
            }];
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

%new - (void)legacyHandleFiles:(NSArray *)items withApplication:(id)proxy {
    
    %log;
    NSFileManager *man = [NSFileManager defaultManager];
    NSString *onePath = [[proxy dataContainerURL] path];
    if (onePath == nil){
        onePath = @"/";
    }
    __block NSMutableArray *finalArray = [NSMutableArray new];
    NSString *cachePath = [[onePath stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:[proxy bundleIdentifier]];
    NSError *theError = nil;
    if ([man fileExistsAtPath:cachePath]){
        [man createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&theError];
    }
    HBLogDebug(@"cache path: %@ error: %@", cachePath, theError);
    
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *newPath = [cachePath stringByAppendingPathComponent:[obj lastPathComponent]];
        NSError *copyError = nil;
        if ([man fileExistsAtPath:newPath]){
            [finalArray addObject:newPath];
        } else {
            HBLogDebug(@"attempting to copy %@ to %@", obj, newPath);
            if ([man copyItemAtPath:obj toPath:newPath error:&copyError]) {
                [finalArray addObject:newPath];
            } else {
                HBLogDebug(@"failed to copy %@ to %@ with error: %@", obj, newPath, copyError);
                
            }
        }
        
    }];
    
    if (finalArray.count > 0){
        
        if (finalArray.count == 1){
            /*
             NSURL *url = [NSURL fileURLWithPath:finalArray[0]];
             HBLogDebug(@"urL: %@", url);
             
             NSBlockOperation *operation = [[LSApplicationWorkspace defaultWorkspace] operationToOpenResource:url usingApplication:[proxy bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE]} options:nil delegate:self];
             HBLogDebug(@"operation: %@", operation);
             [operation start];
             
             */
            [self ourOpenOperationForItems:finalArray withApplication:proxy];
            
        } else {
            NSString *tempPlistFile = [cachePath stringByAppendingPathComponent:@"AirDrop.plist"];
            [finalArray writeToFile:tempPlistFile atomically:FALSE];
            [[LSApplicationWorkspace defaultWorkspace] openApplicationWithBundleID:[proxy bundleIdentifier]];
        }
        
        /*
         
         */
    }
    
}

%end
%end //PineBoard Group

%ctor {
    %init(Bro);
    NSString *processName = [[[[NSProcessInfo processInfo] arguments] lastObject] lastPathComponent];
    //HBLogDebug(@"Process name: %@", processName);
    if ([processName isEqualToString:@"PineBoard"]){
        %init(PineBoard);
    } else if ([processName isEqualToString:@"sharingd"]){
        %init(Sharingd);
    }
}
