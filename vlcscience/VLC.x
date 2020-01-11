#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VLCOpenNetworkStreamTVViewController:  UIViewController
@property (readwrite, nonatomic, weak) IBOutlet UITextField *playURLField;
- (void)URLEnteredInField:(id)sender;
- (void)outHere:(NSString *)urlStringToPlay;
@end

@interface AppleTVAppDelegate: UIResponder <UIApplicationDelegate>
- (void)_openURLStringAndDismiss:(NSString *)urlString;
- (void)importFileAtURL:(NSURL *)url;
- (NSString *)uploadDirectory;
@end

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

%new - (void)_openURLStringAndDismiss:(NSString *)urlString
{
    UITabBarController *tbc = (UITabBarController*)[[self window] rootViewController];
    if (tbc.viewControllers.count > 2){
        [tbc setSelectedIndex: 2];
        UINavigationController *networkNavigationController = tbc.viewControllers[2];
        //VLCOpenNetworkStreamTVViewController
        UIViewController *topViewController = [networkNavigationController topViewController];
        if ([topViewController respondsToSelector:@selector(outHere:)]){
            [topViewController performSelector:@selector(outHere:) withObject:urlString];
        }
    }
}

%new - (void)importFileAtURL:(NSURL *)url {

        if (![url isFileURL]){
            [self _openURLStringAndDismiss:url.absoluteString];
        } else {
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
