#import "FindProcess.h"


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
	return %orig;
}

%end

%hook SFAirDropTransfer



-(void)updateWithInformation:(id)arg {
	%log;

	NSProgress *prog = [self transferProgress];
	HBLogDebug(@"progress: %@", prog);

	NSArray <NSURL *> *items = arg[@"Items"];
	if (items.count > 0 && [prog isFinished]){

		//SURL *url = items[0];
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
		if (paths.count > 0){
			NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
			NSDictionary *userInfo = @{@"Items": paths};
			HBLogDebug(@"Breezy: sending user info: %@", userInfo);
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
		}

		if (URLS.count > 0){
			NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
			NSDictionary *userInfo = @{@"URLS": URLS};
			HBLogDebug(@"Breezy: sending user info: %@", userInfo);
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
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
