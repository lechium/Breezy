#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook AppDelegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {

    %log;
    NSFileManager *man = [NSFileManager defaultManager];
    HBLogDebug(@"[Provenance] host: %@ path: %@", url.host, url.path);
    BOOL orig = %orig;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Imports"];
    NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
    HBLogDebug(@"[Provenance] cache attrs: %@", attrs);
    HBLogDebug(@"[Provenance] cache path: %@", cache);

    NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
    NSString *originalPath = url.path;
    NSError *error = nil;
    [man copyItemAtPath:originalPath toPath:newPath error:&error];
    HBLogDebug(@"error: %@", error);

    return YES;
}

%end

%ctor {
%init(AppDelegate = objc_getClass("Provenance.PVAppDelegate"));
}
