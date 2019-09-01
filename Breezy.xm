@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end
@interface LSApplicationWorkspace : NSObject 
+(id)defaultWorkspace;
@end

@interface SDAirDropHandlerGenericFiles: NSObject //its not but its fine.
- (id)initWithTransfer:(id)arg1 bundleIdentifier:(id)arg2;
@property(copy, nonatomic) NSArray *availableApplications;
- (NSArray *)allInstalledApplications;
- (void)activate;

@end

%hook SFAirDropTransfer
-(void)updateWithInformation:(id)arg {
	%log;
	NSArray *items = arg[@"Items"];
	if (items.count > 0){
		//NSLog(@"items: %@", items);
		NSURL *url = items[0];
		//NSArray *actions = [self possibleActions];
		//NSLog(@"actions: %@", actions);
		NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
		NSDictionary *userInfo = @{@"Path": [url path]};
		NSLog(@"sending user info: %@", userInfo);
		NSDistributedNotificationCenter *noteCenter = [NSDistributedNotificationCenter defaultCenter];
		[noteCenter postNotificationName:notificationName object:nil userInfo:userInfo];
	}
	
	%orig;
}

%end


%hook SDAirDropTransferManager

- (id)determineHandlerForTransfer:(id)arg1 { 
	%log; id  r = %orig; 
	HBLogDebug(@" = %@", r); 
	
	if (!r){
		HBLogDebug(@"nil identifier, we cant be havin that!");
		//- (id)initWithTransfer:(id)arg1 bundleIdentifier:(id)arg2
		id genericHandler = [[NSClassFromString(@"SDAirDropHandlerGenericFiles") alloc] initWithTransfer:arg1 bundleIdentifier:@"com.nito.nitoTV4"];
		  NSArray *installedApplications = [[LSApplicationWorkspace defaultWorkspace] allInstalledApplications];
    	  NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.applicationIdentifier contains[cd] %@ ", @"com.nito.nitoTV4"];
          NSArray  *mobileApplications = [installedApplications filteredArrayUsingPredicate:pred];
		  [genericHandler setAvailableApplications:mobileApplications];
		   HBLogDebug(@"finding nito: %@", mobileApplications);
		  id apps = [genericHandler availableApplications];
		HBLogDebug(@"genericHandler: %@, apps: %@", genericHandler, apps);
		[genericHandler activate];
		return genericHandler;
	}
	return r; 

	}

%end
