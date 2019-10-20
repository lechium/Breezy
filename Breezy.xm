#import "FindProcess.h"
#import <UIKit/UIKit.h>

@interface PBWindowManager: NSObject

+ (id)sharedInstance;
- (void)presentDialogViewController:(id)dialog;
- (void)dismissDialogViewController:(id)view;

@end

@interface PBUserNotificationViewControllerAlert: UIViewController

-(id)initWithTitle:(id)arg1 text:(id)arg2;
-(void)addButtonWithTitle:(id)arg1 type:(unsigned long long)arg2 handler:(void (^)(void))handler;

@end

@interface LSDocumentProxy: NSObject
+(id)documentProxyForName:(id)arg1 type:(id)arg2 MIMEType:(id)arg3 ;
-(id)applicationsAvailableForOpeningWithTypeDeclarer:(BOOL)arg1 style:(unsigned char)arg2 XPCConnection:(id)arg3 error:(id*)arg4;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

@interface SDAirDropHandlerGenericFiles: NSObject //its not but its fine.
- (id)initWithTransfer:(id)arg1 bundleIdentifier:(id)arg2;
- (void)activate;
@end

@interface SFAirDropTransfer: NSObject

-(NSProgress *)transferProgress;

@end

@interface SFAirDropTransferMetaData : NSObject

-(NSArray *)rawFiles;
-(NSDictionary *)itemsDescriptionAdvanced;

@end

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
	return true;
	//return %orig;
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

		//id meta = [self metaData];
		//NSLog(@"###### meta items: %@", [meta items]);
		HBLogDebug(@"info: %@", arg);
		HBLogDebug(@"science bro");
	
		NSMutableDictionary *bro = [arg mutableCopy];
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
		[bro removeObjectForKey:@"Items"];
		HBLogDebug(@"Down here bro: %@, ", bro);
		if (paths.count > 0){

			HBLogDebug(@"we got paths ese");
			//NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
			//NSDictionary *userInfo = @{@"Items": paths};
			//HBLogDebug(@"Breezy: sending user info: %@", userInfo);
			//[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
			[bro setObject:paths forKey:@"LocalFiles"];
		}

		if (URLS.count > 0){
			//NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
			//NSDictionary *userInfo = @{@"URLS": URLS};
			//HBLogDebug(@"Breezy: sending user info: %@", userInfo);
			//[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
			[bro setObject:URLS forKey:@"URLS"];
		}
		if (paths.count > 0 || URLS.count > 0){
			
			HBLogDebug(@"Breezy: sending user info: %@", bro);
			NSMutableDictionary *sent = [NSMutableDictionary new];
			sent[@"Files"] = bro[@"Files"];
			sent[@"LocalFiles"] = bro[@"LocalFiles"];
			sent[@"URLS"] = bro[@"URLS"];
			sent[@"SenderCompositeName"] = bro[@"SenderCompositeName"];
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.breezy.kludgeh4x" object:nil userInfo:sent];
		}
	}	
	%orig;
}
%end

/*

###### meta items: {(
    <SFAirDropTransferItem 0x9BD2, type: public.c-header, count: 1, isFile: yes>
)}

*/

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
		id genericHandler = [[NSClassFromString(@"SDAirDropHandlerGenericFiles") alloc] initWithTransfer:transfer bundleIdentifier:@"com.nito.nitoTV4"];
		[genericHandler activate];
		return genericHandler;
	} else {
		HBLogDebug(@"Breezy: %@ created for transfer: %@", r, transfer);
	}
	return r; 
	}
%end

%hook PBAppDelegate

%new - (void)showSystemAlertFromAlert:(id)alert {

	%log;
	NSLog(@"showSystemAlertFromAlert: %@", alert);
	id windowManager = [NSClassFromString(@"PBWindowManager") sharedInstance];

	NSDictionary *userInfo = [alert userInfo];
	//NSString *name = userInfo[@"SenderCompositeName"];
	//NSString *text = [NSString stringWithFormat:@"%@ is sending a file, where would you like to open it?", name];
	id applicationAlert = [[NSClassFromString(@"PBUserNotificationViewControllerAlert") alloc] initWithTitle:@"AirDrop" text:@"Open with..."];
	NSArray <NSDictionary *> *files = userInfo[@"Files"];
	NSArray <NSString *> *localFiles = userInfo[@"LocalFiles"];
	NSDictionary *fileOne = files[0];
	NSString *fileName = fileOne[@"FileName"];
	NSString *fileType = fileOne[@"FileType"];
	id doxy = [NSClassFromString(@"LSDocumentProxy") documentProxyForName:fileName type:fileType MIMEType:nil];
	NSArray *applications = [doxy applicationsAvailableForOpeningWithTypeDeclarer: 1 style: 0 XPCConnection: nil error: nil];
	[applications enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		 [applicationAlert addButtonWithTitle:[obj localizedName] type:0 handler:^{
                       
					   NSLog(@"selected this guy: %@", obj);
					   NSURL *url = [NSURL fileURLWithPath:localFiles[0]];
					   NSLog(@"selected this guy: %@", url);
					   [windowManager dismissDialogViewController:applicationAlert];
					   id ws = [NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace];
					   id operation = [ws operationToOpenResource:url usingApplication:[obj bundleIdentifier] uniqueDocumentIdentifier:nil isContentManaged:0 sourceAuditToken:nil userInfo:@{@"LSMoveDocumentOnOpen": @1} options:nil delegate:nil];
					   
					    dispatch_async(dispatch_get_main_queue(), ^{
							NSLog(@"operation brother: %@", operation);
							   [operation start];

    					});
				    }];
	}];

	[applicationAlert addButtonWithTitle:@"Cancel" type:0 handler:^{
                       
					   [windowManager dismissDialogViewController:applicationAlert];
                    }];
	
	 dispatch_async(dispatch_get_main_queue(), ^{
        	[windowManager presentDialogViewController:applicationAlert];
    });
	NSLog(@"file: %@ of type: %@ can open in the following applications: %@",fileName, fileType, applications);

}

- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    
    _Bool orig = %orig;
    %log;
    id notificationCenter = [NSDistributedNotificationCenter defaultCenter];
    //NSLog(@"after note center");
    [notificationCenter addObserver:self  selector:@selector(showSystemAlertFromAlert:) name:@"com.breezy.kludgeh4x" object:nil];
	return orig;
    
}

%end