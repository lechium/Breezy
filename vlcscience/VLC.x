#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppleTVAppDelegate: NSObject

- (void)importFileAtURL:(NSURL *)url;
- (NSString *)uploadDirectory;
- (NSString *)movedFileToCache:(NSString *)fileName;
@end

%hook AppleTVAppDelegate

%new - (NSString *)movedFileToCache:(NSString *)fileName {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSString *cache = [self uploadDirectory];
    NSString *newPath = [cache stringByAppendingPathComponent:fileName.lastPathComponent];
    NSError *error = nil;
    
    if ([man fileExistsAtPath:newPath]){
        [man removeItemAtPath:fileName error:nil];
        return newPath;
    }
    if ([man copyItemAtPath:fileName toPath:newPath error:&error]){
        if(!error){
            [man removeItemAtPath:fileName error:nil];
            return newPath;
        }
    }
    return nil;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    %log;
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    HBLogDebug(@"MY NAME IS URL: %@", url);
    if (url != nil){
        [self importFileAtURL:url];
    }
    return %orig;

}

%new - (void)handleLegacyAirdropFile:(NSString *)adFile {
    
    //NSFileManager *man = [NSFileManager defaultManager];
    NSArray *fileArray = [NSArray arrayWithContentsOfFile:adFile];
    NSLog(@"airdropper array: %@", fileArray);
    //__block NSMutableArray *processArray = [NSMutableArray new];
    [fileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *newFile = [self movedFileToCache:obj];
        //[processArray addObject:newFile];
        [self importFileAtURL:[NSURL fileURLWithPath:newFile]];
    }];

    
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

        NSFileManager *man = [NSFileManager defaultManager];
        HBLogDebug(@"[VLC] host: %@ path: %@", url.host, url.path);
        //NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cache = [self uploadDirectory];//[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Upload"];
  
        NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
        HBLogDebug(@"[VLC] cache attrs: %@", attrs);
        HBLogDebug(@"[VLC] cache path: %@", cache);

        NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
        NSString *originalPath = url.path;
        NSError *error = nil;
        [man copyItemAtPath:originalPath toPath:newPath error:&error];
        HBLogDebug(@"copy error: %@", error);
}

%new - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {

    %log;
    NSFileManager *man = [NSFileManager defaultManager];
    HBLogDebug(@"[VLC] host: %@ path: %@", url.host, url.path);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Upload"];
    if ([man fileExistsAtPath:cache]){
        HBLogDebug(@"this path wasnt found; %@",cache );
        NSDictionary *folderAttrs = @{NSFileGroupOwnerAccountName: @"staff",NSFileOwnerAccountName: @"mobile"};
        NSError *error = nil;
        [man createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:folderAttrs error:&error];
        if (error){
            HBLogDebug(@"error: %@", error);
        }
    }
    NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
    HBLogDebug(@"[VLC] cache attrs: %@", attrs);
    HBLogDebug(@"[VLC] cache path: %@", cache);

    NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
    NSString *originalPath = url.path;
    NSError *error = nil;
    [man copyItemAtPath:originalPath toPath:newPath error:&error];
    HBLogDebug(@"error: %@", error);

    return YES;
}

%end

%ctor {

    //was going to try and introspect the class to hook here but doesnt seem to work properly.
}
