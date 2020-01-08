#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSApplicationProxy : NSObject
+ (id)applicationProxyForIdentifier:(NSString *)identifier;
- (NSURL *)containerURL;
@end

@interface AppDelegate: UIResponder
- (void)handleLegacyAirdropFile:(NSString *)adFile;
- (NSString *)movedFileToCache:(NSString *)fileName;
- (void)importFileAtURL:(NSURL *)url;
- (NSString *)uploadDirectory;
@end

%hook AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    %log;
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *adFile = [[cache stringByAppendingPathComponent:bundleID] stringByAppendingPathComponent:@"AirDrop.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:adFile]){
        NSLog(@"[Provenance] fileExistsAtPath: %@", adFile);
        [self handleLegacyAirdropFile:adFile];
    } else {
        NSLog(@"[Provenance] file does NOT exist at path!?!?!?: %@", adFile);
    }
    %orig;
    
}
/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    %log;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *caches = [paths objectAtIndex:0];
    NSLog(@"[Provenance] paths: %@", paths);
    NSString *adFile = [caches stringByAppendingPathComponent:@"AirDrop.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:adFile]){
        NSLog(@"[Provenance] fileExistsAtPath: %@", adFile);
        [self handleLegacyAirdropFile:adFile];
    } else {
        NSLog(@"[Provenance] file does NOT exist at path!?!?!?: %@", adFile);
    }
    return %orig;
    //NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    //id prox =  [NSClassFromString(@"LSApplicationProxy") applicationProxyForIdentifier:bundleID];
    //NSString *caches = [[[[prox containerURL] path] stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:bundleID];
    
    //NSLog(@"[Provenance] caches: %@", caches);
    //NSError *error = nil;
    //NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[prox containerURL] path] error:&error];
    //NSLog(@"[Provenance] contents: %@ error :%@", contents, error);
    
}
*/
%new - (void)handleLegacyAirdropFile:(NSString *)adFile {
    
    NSArray *fileArray = [NSArray arrayWithContentsOfFile:adFile];
    NSLog(@"airdropper array: %@", fileArray);
    __block NSMutableArray *processArray = [NSMutableArray new];
    [fileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *newFile = [self movedFileToCache:obj];
        if (newFile)
            [processArray addObject:newFile];
    }];
}

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
    } else {
        NSLog(@"[Provenance] error %@ copying %@ to %@", error, fileName, newPath);
    }
    return nil;
}

%new - (void)importFileAtURL:(NSURL *)url {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSLog(@"[Provenance] host: %@ path: %@", url.host, url.path);
    NSString *cache = [self uploadDirectory];//[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Upload"];
    
    NSDictionary *attrs = [man attributesOfItemAtPath:cache error:nil];
    NSLog(@"[Provenance] cache attrs: %@", attrs);
    NSLog(@"[Provenance] cache path: %@", cache);
    
    NSString *newPath = [cache stringByAppendingPathComponent:url.path.lastPathComponent];
    NSString *originalPath = url.path;
    NSError *error = nil;
    [man copyItemAtPath:originalPath toPath:newPath error:&error];
    NSLog(@"copy error: %@", error);
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
/*
    [contents enumerateObjectsUsingBlock:^(NSString  * file, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *fullPath = [airdropFolder stringByAppendingPathComponent:file];
        NSString *newPaths = [cache stringByAppendingPathComponent:file];
        NSLog(@"fullPath: %@ to %@", fullPath, newPaths);
        [man copyItemAtPath:originalPath toPath:newPaths error:&error];
        NSLog(@"copy error: %@", error);
    }];
*/
    return YES;
}

%end

%ctor {
%init(AppDelegate = objc_getClass("Provenance.PVAppDelegate"));
}
