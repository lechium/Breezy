#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <spawn.h>
#include <sys/wait.h>

#include <string.h>
#include <math.h>
#include <sys/stat.h>
#include <sys/param.h>

@interface LSApplicationWorkspace

@end

@interface NSDistributedNotificationCenter : NSNotificationCenter

+ (id)defaultCenter;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;

@end

%hook NSAssertionHandler

@interface SDAirDropHandler: NSObject

@end

@interface SDAirDropHandlerGenericFiles : SDAirDropHandler

@property(retain, nonatomic) id selectedApplication; // @synthesize selectedApplication=_selectedApplication;
@property(copy, nonatomic) NSArray *availableApplications; // @synthesize availableApplications=_availableApplications;

- (id)cancelActionTitleToAccompanyActions:(id)arg1;	// IMP=0x0000000100090cd4
- (void)updatePossibleActions;	// IMP=0x0000000100090a40
- (id)suitableContentsDescription;	// IMP=0x0000000100090894
- (long long)transferTypes;	// IMP=0x000000010009085c
- (_Bool)canHandleTransfer;	// IMP=0x0000000100090784
- (id)initWithTransfer:(id)arg1 bundleIdentifier:(id)arg2;	// IMP=0x0000000100090688
- (id)initWithTransfer:(id)arg1;

@end

- (void)handleFailureInFunction:(id)arg1 file:(id)arg2 lineNumber:(long long)arg3 description:(id)arg4 
{
	%log;
	%orig;
}
- (void)handleFailureInMethod:(SEL)arg1 object:(id)arg2 file:(id)arg3 lineNumber:(long long)arg4 description:(id)arg5{
	
	%log;
	%orig;
}

%end

%hook SDAirDropHandlerGenericFiles 

- (NSArray *) availableApplications {

	%log;
	id orig = %orig;
	NSLog(@"availableApplications %@", orig);
	return orig;

}

%end
/*
%hook SDAirDropTransferManager 

- (id)itemTypesForTransfer:(id)arg1 {

	%log;
	return %orig;

}

- (id)currentHandler {
	
	%log;
	id orig = %orig;
	if (orig == nil){
		HBLogDebug(@"NO HANDLER FOR YOU");
	}
	return orig;
}

- (void)askEventForRecordID:(id)arg1 withResults:(id)arg2 {

	%log;
	%orig;
}

%end
*/
%hook SFAirDropTransfer

-(id)initWithIdentifier:(id)arg1 initialInformation:(id)arg2 {

	%log;
	return %orig;

}

%new - (NSArray *)returnForProcess:(NSString *)call
{
    if (call==nil)
        return 0;
    char line[200];
    //DDLogInfo(@"running process: %@", call);
    FILE* fp = popen([call UTF8String], "r");
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    if (fp)
    {
        while (fgets(line, sizeof line, fp))
        {
            NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lines addObject:s];
        }
    }
    pclose(fp);
    return lines;
}


-(void)updateWithInformation:(id)arg {
	%log;
	NSArray *items = arg[@"Items"];
	if (items.count > 0){
		//NSLog(@"items: %@", items);
		NSURL *url = items[0];
		NSArray *actions = [self possibleActions];
		//NSLog(@"actions: %@", actions);
		NSLog(@"first item: %@", url);
		LSApplicationWorkspace *ws = [LSApplicationWorkspace defaultWorkspace];
		NSArray *apps = [ws applicationsAvailableForOpeningURL:url];
		//NSLog(@"apps: %@", apps);
		[ws openURL:url];
		NSString *notificationName = @"com.nito.AirDropper/airDropFileReceived";
		NSDictionary *userInfo = @{@"Path": [url path]};
		NSLog(@"sending user info: %@", userInfo);
		NSDistributedNotificationCenter *noteCenter = [NSDistributedNotificationCenter defaultCenter];
		NSLog(@"notification center: %@", noteCenter);
		[noteCenter postNotificationName:notificationName object:nil userInfo:userInfo];
		/*
		 NSString *outputPath = @"/var/mobile/Library/Preferences/filetest";
    	 NSURL *destUrl = [NSURL fileURLWithPath:outputPath];
         NSError *error = nil;
		 NSLog(@"copying %@ to %@", url, destUrl);

         [[NSFileManager defaultManager] copyItemAtURL:url toURL:destUrl error:&error];
		  NSLog(@"Copy error: %@", error);
		  NSString *fileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    	  NSLog(@"fileContents: %@ error: %@", fileContents, error);
		  NSString *trySomethingNew = [NSString stringWithFormat:@"/bin/cp %@ %@", [url path], outputPath];
		  NSLog(@"%@",trySomethingNew);
		  [self returnForProcess:trySomethingNew];
		  */

	}
	
	%orig;
}


//- (id)metaData { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }


%end
/*

%hook LSApplicationWorkspace

- (NSURL *)URLOverrideForURL:(NSURL *)url { %log; NSURL * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (NSArray *)applicationsAvailableForOpeningURL:(NSURL *)url { 
	%log; 
	NSArray * r = %orig; 
	HBLogDebug(@" = %@", r); 
	if (r.count == 0) {

		  NSArray *installedApplications = [self allInstalledApplications];
    	  NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.applicationIdentifier contains[cd] %@ ", @"com.nito.nitoTV4"];
          NSArray  *mobileApplications = [installedApplications filteredArrayUsingPredicate:pred];
		  HBLogDebug(@"finding nito: %@", mobileApplications);
		  if (mobileApplications.count > 0){
			  return mobileApplications[0];
		  }
	}
	return r; 
	}

%end

*/

%hook SFAirDropTransferMetaData

-(NSArray *)rawFiles { %log; NSArray * r = %orig; HBLogDebug(@" = %@", r); return r; }

%end 


%hook SDAirDropTransferManager



-(NSMutableDictionary *)transferIdentifierToTransfer { %log; NSMutableDictionary * r = %orig; HBLogDebug(@" = %@", r); return r; }
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
		HBLogDebug(@"genericHandler: %@, apps", genericHandler, apps);
		[genericHandler activate];
		return genericHandler;
	}
	return r; 

	}

%end

%hook SDAirDropClient

- (void)startSending {

	%log; %orig;
}

- (void)validateAirDropItemsWithCompletionHandler:(id)arg1 { %log; %orig;}

- (id)initWithPerson:(id)arg1 items:(id)arg2 forDiscovery:(_Bool)arg3 {
	%log;
	return %orig;
}

- (void)notifyClientForEvent:(long long)arg1 withProperty:(void *)arg2 {
	%log;
	%orig;
}

%end

/*
%hook SFAirDropTransferObserver
-(id)remoteObjectInterface { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(id)machServiceName { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)updatedTransfer:(id)arg1  { %log; %orig; }
-(NSMutableDictionary *)transferIdentifierToTransfer { %log; NSMutableDictionary * r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)_getRemoteObjectProxyOnQueue:(/id)arg1  { %log; %orig; }
-(void)observeForLocalOnlyPropertiesOnTransfer:(id)arg1  { %log; %orig; }
-(void)updateActionHandlersOnTransfer:(id)arg1  { %log; %orig; }
-(void)removeObserverForLocalOnlyPropertiesOnTransfer:(id)arg1  { %log; %orig; }
-(void)removedTransfer:(id)arg1  { %log; %orig; }
-(BOOL)shouldEscapeXpcTryCatch { %log; BOOL r = %orig; HBLogDebug(@" = %d", r); return r; }
-(void)setTransferIdentifierToTransfer:(NSMutableDictionary *)arg1  { %log; %orig; }
-(id)init { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)setDelegate:(id)arg1  { %log; %orig; }
-(id)delegate { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
-(void)invalidate { %log; %orig; }
-(void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void*)arg4  { %log; %orig; }
-(void)activate { %log; %orig; }
-(id)exportedInterface { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
%end
*/