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
	NSArray *items = arg[@"Items"];
	if (items.count > 0){
		NSURL *url = items[0];
		NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
		NSDictionary *userInfo = @{@"Path": [url path]};
		NSLog(@"sending user info: %@", userInfo);
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
	}	
	%orig;
}
%end

%hook SDAirDropTransferManager

- (id)determineHandlerForTransfer:(id)arg1 { 
	%log; 
	id  r = %orig;  
	if (!r){
		id genericHandler = [[NSClassFromString(@"SDAirDropHandlerGenericFiles") alloc] initWithTransfer:arg1 bundleIdentifier:@"com.nito.nitoTV4"];
		[genericHandler activate];
		return genericHandler;
	}
	return r; 
	}
%end
