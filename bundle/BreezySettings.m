

#import "BreezySettings.h"
#import <TVSettingsKit/TSKTextInputSettingItem.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import "NSTask.h"


@interface LSApplicationProxy (More)
+(id)applicationProxyForIdentifier:(id)arg1;
-(BOOL)isContainerized;
-(NSURL *)dataContainerURL;
@end

@interface LSApplicationWorkspace (More)

-(id)allInstalledApplications;
-(BOOL)openApplicationWithBundleID:(id)arg1;

@end


@interface BreezySettings() {
    
}
@property (nonatomic, strong) NSString *importsPath;
@property (nonatomic, strong) NSString *defaultBundleID;
@end

@implementation BreezySettings


- (void)restartSharingd {
    //+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[@"-9", @"sharingd"]];
    
}



- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"BreezySettings viewWillAppear");
    
}

- (id)loadSettingGroups {


    id facade = [[NSClassFromString(@"TVSettingsPreferenceFacade") alloc] initWithDomain:@"com.nito.Breezy" notifyChanges:TRUE];
    NSMutableArray *_backingArray = [NSMutableArray new];
    TSKSettingItem *settingsItem = [TSKSettingItem toggleItemWithTitle:@"Toggle AirDrop Server" description:@"Turn on AirDrop to receive files through AirDrop from supported devices" representedObject:facade keyPath:@"airdropServerState" onTitle:nil offTitle:nil];
    //NSLog(@"created settings item: %@", settingsItem);
    
    TSKSettingItem *restartSharingd = [TSKSettingItem actionItemWithTitle:@"Restart Sharingd" description:@"If AirDrop is rejecting your transfers, attempt to restart sharingd daemon." representedObject:facade keyPath:@"" target:self action:@selector(restartSharingd)];
    TSKSettingGroup *group = [TSKSettingGroup groupWithTitle:nil settingItems:@[settingsItem, restartSharingd]];
    [_backingArray addObject:group];
    [self setValue:_backingArray forKey:@"_settingGroups"];
    
    return _backingArray;
    
}

-(id)previewForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSKPreviewViewController *item = [super previewForItemAtIndexPath:indexPath];
    TSKSettingGroup *currentGroup = self.settingGroups[indexPath.section];
    TSKSettingItem *currentItem = currentGroup.settingItems[indexPath.row];
    NSString *imagePath = [[NSBundle bundleForClass:self.class] pathForResource:@"icon" ofType:@"png"];
    UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
    if (icon != nil) {
        TSKVibrantImageView *imageView = [[TSKVibrantImageView alloc] initWithImage:icon];
        [item setContentView:imageView];
    }
    
    return item;
    
}


@end
