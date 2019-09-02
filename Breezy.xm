@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

@interface SDAirDropHandlerGenericFiles: NSObject //its not but its fine.
- (id)initWithTransfer:(id)arg1 bundleIdentifier:(id)arg2;
- (void)activate;
@end

%hook SFAirDropTransfer
-(void)updateWithInformation:(id)arg {
	%log;
	NSArray <NSURL *> *items = arg[@"Items"];
	if (items.count > 0){
		//SURL *url = items[0];
		NSMutableArray *paths = [NSMutableArray new];
		[items enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    		   [paths addObject:[obj path]];
    	}];
		NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
		NSDictionary *userInfo = @{@"Items": paths};
		HBLogDebug(@"Breezy: sending user info: %@", userInfo);
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
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
	    HBLogDebug(@"Breezy: meta: %@", meta);
		id genericHandler = [[NSClassFromString(@"SDAirDropHandlerGenericFiles") alloc] initWithTransfer:transfer bundleIdentifier:@"com.nito.nitoTV4"];
		[genericHandler activate];
		return genericHandler;
	} else {
		HBLogDebug(@"Breezy: %@ created for transfer: %@", r, transfer);
	}
	return r; 
	}
%end
