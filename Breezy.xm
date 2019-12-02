#import "FindProcess.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "breezy.h"
#import "CTBlockDescription.h"

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


-(void)updateWithInformation:(id)arg {
    %log;
    NSProgress *prog = [self transferProgress];
    HBLogDebug(@"progress: %@", prog);
    NSArray <NSURL *> *items = arg[@"Items"];
    if (items.count > 0 && [prog isFinished]){
        HBLogDebug(@"info: %@", arg);
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

- (id)determineHandlerForTransfer:(id)transfer { 
    %log;
    id  r = %orig;
    if (!r){
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
    } else {
        HBLogDebug(@"Breezy: %@ created for transfer: %@", r, transfer);
    }
    return r;
}
%end

%hook PBAppDelegate

%new - (void)runNextOperation {
    
    HBLogDebug(@"runNextOp: %@", [self operationArray]);
    //NSMutableArray *opArray = [self operationArray];
    if ([[self operationArray] count] == 0){
        HBLogDebug(@"no operations left!");
        return;
    }
    NSOperation *firstObject = [[self operationArray] firstObject];
    HBLogDebug(@"firstObject: %@", firstObject);
        [[self operationArray] removeObject:firstObject];
        if ([[self operationArray] count] > 0){
            firstObject = [[self operationArray] firstObject];
            HBLogDebug(@"object: %@", firstObject);
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

%new - (NSOperationQueue *)openOperationQueue {
    
    id ooq = objc_getAssociatedObject(self, @selector(openOperationQueue));
    if (ooq == nil){
        ooq = [NSOperationQueue currentQueue];
        objc_setAssociatedObject(self, @selector(openOperationQueue), ooq, OBJC_ASSOCIATION_RETAIN);
    }
    return ooq;
}

%new -(void)contentPresenting:(id)arg1 willDismissContentWithResult:(id)arg2 error:(id)arg3 {
    %log;
}

%new -(void)contentPresentingDidDismissContent:(id)arg1 {
    %log;
}

%new - (void)showSystemAlertFromAlert:(id)alert {
    
    %log;
    NSLog(@"showSystemAlertFromAlert: %@", alert);
    id windowManager = [objc_getClass("PBWindowManager") sharedInstance];
    id ws = [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
    __block id context; //13+ only
    __block id dialogManager; //13+ only
    NSDictionary *userInfo = [alert userInfo];
    //NSString *name = userInfo[@"SenderCompositeName"];
    //NSString *text = [NSString stringWithFormat:@"%@ is sending a file, where would you like to open it?", name];
    NSArray <NSDictionary *> *files = userInfo[@"Files"];
    NSArray <NSString *> *localFiles = userInfo[@"LocalFiles"];
    __block NSMutableString *names = [NSMutableString new];
    __block id doxy = nil;
    [files enumerateObjectsUsingBlock:^(NSDictionary  * adFile, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *fileName = adFile[@"FileName"];
        NSString *fileType = adFile[@"FileType"];
        if (!doxy) {
            doxy = [objc_getClass("LSDocumentProxy") documentProxyForName:fileName type:fileType MIMEType:nil];
        }
        [names appendFormat:@"%@, ", fileName];
        
    }];

    id applicationAlert = [[objc_getClass("PBUserNotificationViewControllerAlert") alloc] initWithTitle:@"AirDrop" text:[NSString stringWithFormat:@"Open '%@' with...", names]];
    NSArray  *applications = nil;
    BOOL thirteenPlus = FALSE;
    if ([doxy respondsToSelector:@selector(applicationsAvailableForOpeningWithStyle:limit:XPCConnection:error:)]){
        applications = [doxy applicationsAvailableForOpeningWithStyle:0 limit:1 XPCConnection:nil error:nil];
        thirteenPlus = true;
        dialogManager = [objc_getClass("PBDialogManager") sharedInstance];
    } else {
        applications = [doxy applicationsAvailableForOpeningWithTypeDeclarer: 1 style: 0 XPCConnection: nil error: nil];
    }

    NSMutableArray <NSOperation *>*opArray = [self operationArray];
    HBLogDebug(@"opArray: %@", opArray);
    //NSOperationQueue *opQueue = [self openOperationQueue];
    //opQueue.maxConcurrentOperationCount = 1;
    //HBLogDebug(@"opQueue: %@", opQueue);
    HBLogDebug(@"applications: %@", applications);
    if (applications.count == 1){
        //NSString *file = localFiles[0];
        //NSURL *url = [NSURL fileURLWithPath:file];
        id launchApp = applications[0];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [localFiles enumerateObjectsUsingBlock:^(NSString  * localFile, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSURL *url = [NSURL fileURLWithPath:localFile];
                NSBlockOperation *operation = [ws operationToOpenResource:url usingApplication:[launchApp bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE]} options:nil delegate:nil];
                //[operation start];
               
                HBLogDebug(@"operation: %@", operation);
                [opArray addObject:operation];
                [operation addExecutionBlock: ^{
                    
                    [self runNextOperation];
                }];
                if (idx == 0){
                  //  [operation start];
                }
            }];
            
              [[opArray firstObject] start];
            
        });
        return;
    } else {
        [applications enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [applicationAlert addButtonWithTitle:[obj localizedName] type:0 handler:^{
                
                if (thirteenPlus) {
                    [dialogManager dismissDialogWithContext:context options:nil completion:nil];
                } else {
                    [windowManager dismissDialogViewController:applicationAlert];
                    
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    
                    [localFiles enumerateObjectsUsingBlock:^(NSString  * localFile, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSURL *url = [NSURL fileURLWithPath:localFile];
                        NSBlockOperation *operation = [ws operationToOpenResource:url usingApplication:[obj bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": [NSNumber numberWithBool:TRUE]} options:nil delegate:nil];
                      
                       // if (idx == 0){
                         //   [operation start];
                        //} else {
                        //[operation start];
                        [opArray addObject:operation];
                        [operation addExecutionBlock: ^{
                            [self runNextOperation];
                        }];
                        if (idx == 0){
                            [operation start];
                        }
                           // [opQueue addOperation:operation];
                            
                       // }
                        
                    }];
                });
     
            }];
        }];
    }
    [applicationAlert addButtonWithTitle:@"Cancel" type:0 handler:^{
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
               [dialogManager presentDialogWithContext:context options:@{@"PBDialogOptionPresentForcedKey": [NSNumber numberWithInteger:0], @"PBDialogOptionPresentWhileScreenSaverActiveKey": [NSNumber numberWithInteger:0]} completion:nil];
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

%end
