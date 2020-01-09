#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSApplicationProxy : NSObject
+ (id)applicationProxyForIdentifier:(NSString *)identifier;
- (NSURL *)containerURL;
@end

@interface AppDelegate: UIResponder
- (void)importFileAtURL:(NSURL *)url;
- (NSString *)uploadDirectory;
@end

%hook AppDelegate


%new - (void)importFileAtURL:(NSURL *)url {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSLog(@"[Provenance] host: %@ path: %@", url.host, url.path);
    NSString *cache = [self uploadDirectory];
    NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
    NSLog(@"[Provenance] cache attrs: %@", attrs);
    NSLog(@"[Provenance] cache path: %@", cache);
    NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
    NSString *originalPath = url.path;
    NSError *error = nil;
    [man copyItemAtPath:originalPath toPath:newPath error:&error];
    NSLog(@"[Provenance] copy error: %@", error);
}

%new - (NSString *)uploadDirectory {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Imports"];
    if (![man fileExistsAtPath:cache]){
        NSLog(@"this path wasnt found; %@",cache );
        NSDictionary *folderAttrs = @{NSFileGroupOwnerAccountName: @"staff",NSFileOwnerAccountName: @"mobile"};
        NSError *error = nil;
        [man createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:folderAttrs error:&error];
        if (error){
            NSLog(@"error: %@", error);
        }
    }
    return cache;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {

    %log;
    [self importFileAtURL:url];
    return YES; /*
    NSFileManager *man = [NSFileManager defaultManager];
    NSLog(@"[Provenance] host: %@ path: %@", url.host, url.path);
    //BOOL orig = %orig;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Imports"];
    NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
    NSLog(@"[Provenance] cache attrs: %@", attrs);
    NSLog(@"[Provenance] cache path: %@", cache);

    NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
    NSString *originalPath = url.path;
    NSString *airdropFolder = [originalPath stringByDeletingLastPathComponent];
    NSLog(@"[Provenance] airdropFolder: %@", airdropFolder);
    __block NSError *error = nil;
    //NSArray *contents = [man contentsOfDirectoryAtPath:airdropFolder error:nil];
    //NSLog(@"[Provenance] airdropFolder contents: %@", contents);
    [man copyItemAtPath:originalPath toPath:newPath error:&error];
    NSLog(@"error: %@", error);

    return YES;
                 */
}

%end

%ctor {
%init(AppDelegate = objc_getClass("Provenance.PVAppDelegate"));
}
