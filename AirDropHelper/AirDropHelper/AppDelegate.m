//
//  AppDelegate.m
//  AirDropHelper
//
//  Created by Kevin Bradley on 10/12/19.
//  Copyright © 2019 nito. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

@interface SFAirDropSharingViewControllerTV : UIViewController

-(id)initWithSharingItems:(id)arg1;
-(void)setCompletionHandler:(void (^)(NSError *error))arg1;
@end

@interface LSApplicationWorkspace: NSObject

-(id)allInstalledApplications;
- (NSArray *)applicationsOfType:(unsigned long long)arg1 ;
- (id)allApplications;
-(id)placeholderApplications;
-(id)unrestrictedApplications;
- (void)openApplicationWithBundleID:(NSString *)string;
+ (id)defaultWorkspace;
-(BOOL)uninstallApplication:(id)arg1 withOptions:(id)arg2;

@end

@interface UIApplication (hidden)
- (void)terminateWithSuccess;
@end

@interface NSURL (helper)

- (NSDictionary *)airdropDictionary;

@end

@implementation NSURL (helper)

- (NSDictionary *)airdropDictionary {

    NSString *fullPath = [self path];
    if (self.host.length > 0){
        fullPath = [NSString stringWithFormat:@"/%@/%@", [self host], [self path]];
    }
    NSString *sender = [[[self query] componentsSeparatedByString:@"="] lastObject];
    if (sender) return @{@"path": fullPath, @"sender": sender};
    return @{@"path": fullPath};
}

@end

@interface AppDelegate ()

@property (nonatomic, strong) NSDictionary *airDropDictionary;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *vc = [UIViewController new];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)launchApplication:(NSString *)bundleID {
    id defaultWorkspace = [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
    [defaultWorkspace performSelector:@selector(openApplicationWithBundleID:) withObject:(id)bundleID ];
}

- (void)showAirDropSharingView:(NSString *)filePath {
    
    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Sharing.framework"];
    [bundle load];
    
    NSString *suf = @"/System/Library/PrivateFrameworks/SharingUI.framework";
    if ([[NSFileManager defaultManager] fileExistsAtPath:suf]){
        NSBundle *sharingUI = [NSBundle bundleWithPath:suf];
        [sharingUI load];
    }
    
    UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSLog(@"url: %@", url);
    
    id sharingView = [[objc_getClass("SFAirDropSharingViewControllerTV") alloc] initWithSharingItems:@[url]];
    [sharingView setCompletionHandler:^(NSError *error) {
        
        NSLog(@"complete with error: %@", error);
        NSString *sender = self.airDropDictionary[@"sender"];
        if (sender) {
            [self launchApplication:sender];
            NSLog(@"return to sender: %@", sender);
        }
        [[UIApplication sharedApplication] terminateWithSuccess];
    }];
    NSLog(@"sharing view: %@", sharingView);
    
    [rvc presentViewController:sharingView animated:true completion:nil];
    
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    self.airDropDictionary  = [url airdropDictionary];
    NSLog(@"#### FR FR WEOUCHEA");
    NSLog(@"url: %@ app identifier: %@", self.airDropDictionary[@"path"], self.airDropDictionary[@"sender"]);
    NSString *filePath = self.airDropDictionary[@"path"];
    [self showAirDropSharingView:filePath];
    return TRUE;
}

@end
