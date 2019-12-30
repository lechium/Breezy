#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "../MediaRemote/MediaRemote.h"
#import "TVSPreferences.h"
/*
@interface TVSPreferences : NSObject
+(id)preferencesWithDomain:(id)arg1;
+(id)addObserverForDomain:(id)arg1 withDistributedSynchronizationHandler:(void (^)(id object))arg1;
 
@end
*/


 @interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)removeObserver:(id)observer;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

typedef enum : NSUInteger {
    SDAirDropDiscoverableModeOff,
    SDAirDropDiscoverableModeContactsOnly,
    SDAirDropDiscoverableModeEveryone,
} SDAirDropDiscoverableMode;

@interface SFAirDropDiscoveryController: UIViewController
- (void)setDiscoverableMode:(NSInteger)mode;
@end;

#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#define APPLICATION_IDENTIFIER "com.nito.Breezy"

@interface breezyHelper: NSObject

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) id discoveryController;

+ (id)sharedHelper;

@end

@implementation breezyHelper



- (void)reloadSettings {
    // Reload settings.
    NSLog(@"*** [breezyd] :: Reloading settings");
    CFPreferencesAppSynchronize(CFSTR(APPLICATION_IDENTIFIER));
    
    CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR(APPLICATION_IDENTIFIER), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    if (!keyList) {
        self.settings = [NSMutableDictionary dictionary];
    } else {
        CFDictionaryRef dictionary = CFPreferencesCopyMultiple(keyList, CFSTR(APPLICATION_IDENTIFIER), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        
        self.settings = [(__bridge NSDictionary *)dictionary copy];
        NSLog(@"settings: %@", self.settings);
        CFRelease(dictionary);
        CFRelease(keyList);
    }
}

- (id)getPreferenceKey:(NSString*)key {
    return [self.settings objectForKey:key];
}

- (void)disableAirDrop {
    
    DLog(@"AirDrop Disabled!");
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeOff];
}

- (void)setupAirDrop {
   
    NSString *suf = @"/System/Library/PrivateFrameworks/SharingUI.framework";
    if ([[NSFileManager defaultManager] fileExistsAtPath:suf]){
        NSBundle *sharingUI = [NSBundle bundleWithPath:suf];
        [sharingUI load];
    }
    if ([self.discoveryController discoverableMode] == SDAirDropDiscoverableModeEveryone) return;
    DLog(@"AirDrop Enabled!");

    self.discoveryController = [[NSClassFromString(@"SFAirDropDiscoveryController") alloc] init] ;
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeEveryone];
    
}

- (void)preferencesUpdated {
    
    NSString *stateKey = @"airdropServerState";
    TVSPreferences *prefs = [TVSPreferences preferencesWithDomain:@"com.nito.Breezy"];
    BOOL serverRunning = [prefs boolForKey:stateKey];
    if (serverRunning){
        [self setupAirDrop];
    } else {
        [self disableAirDrop];
    }
}

- (void)setupListener {
    
    [TVSPreferences addObserverForDomain:@"com.nito.Breezy" withDistributedSynchronizationHandler:^(id object) {
        [self preferencesUpdated];
    }];
    
}


+ (id)sharedHelper
{
    static dispatch_once_t onceToken;
    
    static breezyHelper *shared = nil;
    if(shared == nil)
    {
        dispatch_once(&onceToken, ^{
            shared = [[breezyHelper alloc] init];
            [shared setupListener];
            [shared reloadSettings];
            [shared preferencesUpdated];
        });
    }
    return shared;
}


@end


int main(int argc, char* argv[])
{
    DLog(@"\breezyd: LOADED\n\n");
    
    breezyHelper *helper = [breezyHelper sharedHelper];
  
    [helper setupAirDrop];
    
    CFRunLoopRun();
    return 0;
}

