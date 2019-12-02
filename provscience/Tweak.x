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
    NSString *airdropFolder = [originalPath stringByDeletingLastPathComponent];
    HBLogDebug(@"[Provenance] airdropFolder: %@", airdropFolder);
    __block NSError *error = nil;
    NSArray *contents = [man contentsOfDirectoryAtPath:airdropFolder error:nil];
    HBLogDebug(@"[Provenance] airdropFolder contents: %@", contents);
    [man copyItemAtPath:originalPath toPath:newPath error:&error];
    HBLogDebug(@"error: %@", error);
    [contents enumerateObjectsUsingBlock:^(NSString  * file, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *fullPath = [airdropFolder stringByAppendingPathComponent:file];
        NSString *newPaths = [cache stringByAppendingPathComponent:file];
        HBLogDebug(@"fullPath: %@ to %@", fullPath, newPaths);
        [man copyItemAtPath:originalPath toPath:newPaths error:&error];
        HBLogDebug(@"copy error: %@", error);
    }];

    return YES;
}

%end

%ctor {
%init(AppDelegate = objc_getClass("Provenance.PVAppDelegate"));
}
