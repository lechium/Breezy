#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VLCOpenNetworkStreamTVViewController:  UIViewController
@property UITextField *playURLField;
- (void)URLEnteredInField:(id)sender;
- (void)outHere:(NSString *)urlStringToPlay;
@end

@interface AppleTVAppDelegate: UIResponder <UIApplicationDelegate>
- (void)importFileAtURL:(NSURL *)url;
- (NSString *)uploadDirectory;
@end
//TODO future incorp downloading links? ffmpeg -user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/601.7.8 (KHTML, like Gecko) Version/9.1.3 Safari/537.86.7" -i http://185.38.12.60/sec/1503173737/363333397f6b65370bfc740ca4dea8c3f8dd2a93419f7748/ivs/12/b1/2ec5e15ba2a6/hls/tracks-4,5/index.m3u8 -c copy pd.mkv
%hook VLCOpenNetworkStreamTVViewController
//<3 to other open source projects https://github.com/videolan/vlc-ios/blob/master/Apple-TV/VLCOpenNetworkStreamTVViewController.m#L130

%new - (void)outHere:(NSString *)urlToPlay {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playURLField.text = urlToPlay;
        [self URLEnteredInField:self.playURLField];
    });
}

%end

%hook AppleTVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    %log;
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    HBLogDebug(@"MY NAME IS URL: %@", url);
    if (url != nil){
        [self importFileAtURL:url];
    }
    return %orig;
}

%new - (NSString *)uploadDirectory {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Upload"];
    if (![man fileExistsAtPath:cache]){
        HBLogDebug(@"this path wasnt found; %@",cache );
        NSDictionary *folderAttrs = @{NSFileGroupOwnerAccountName: @"staff",NSFileOwnerAccountName: @"mobile"};
        NSError *error = nil;
        [man createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:folderAttrs error:&error];
        if (error){
            HBLogDebug(@"error: %@", error);
        }
    }
    return cache;
}


%new - (void)importFileAtURL:(NSURL *)url {

        UITabBarController *tabBarController = (UITabBarController*)[[self window] rootViewController];
        if (![url isFileURL]){
            [tabBarController setSelectedIndex: 2];
            UINavigationController *networkNavigationController = tabBarController.viewControllers[2];
            //VLCOpenNetworkStreamTVViewController
            UIViewController *topViewController = [networkNavigationController topViewController];
            if ([topViewController respondsToSelector:@selector(outHere:)]){
                [topViewController performSelector:@selector(outHere:) withObject:url];
            }
        } else {
            [tabBarController setSelectedIndex: 1];
            NSFileManager *man = [NSFileManager defaultManager];
            HBLogDebug(@"[VLC] host: %@ path: %@", url.host, url.path);
            NSString *cache = [self uploadDirectory];
            //NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
            //HBLogDebug(@"[VLC] cache attrs: %@", attrs);
            HBLogDebug(@"[VLC] cache path: %@", cache);
            NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
            NSString *originalPath = url.path;
            NSError *error = nil;
            [man copyItemAtPath:originalPath toPath:newPath error:&error];
            HBLogDebug(@"[VLC] copyItemAtPath error: %@", error);
        }

}

%new - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {

    %log;
    [self importFileAtURL:url];
    return YES;
}

%end

%ctor {

    //was going to try and introspect the class to hook here but doesnt seem to work properly.
}
