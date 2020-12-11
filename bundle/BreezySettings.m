

#import "BreezySettings.h"
#import <TVSettingsKit/TVSettingKit.h>
#import <TVSettingsKit/TSKTextInputSettingItem.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import "NSTask.h"
#import <objc/runtime.h>


@interface UITableViewCell (privates)
- (id)configurationState;
- (void)_applyBackgroundViewConfiguration:(id)config withState:(id)state;
//@property (nonatomic,copy) UIBackgroundConfiguration * backgroundConfiguration;
- (id)backgroundConfiguration;
- (void)setBackgroundConfiguration:(id)bgc;
-(id)defaultContentConfiguration;
- (void)setContentConfiguration:(id)bgc;
@end

@interface _UISystemBackgroundView: UIView
-(id)initWithConfiguration:(id)config;
@end

@interface UIBackgroundConfiguration: NSObject
+(id)listGroupedCellConfiguration;
- (instancetype)updatedConfigurationForState:(id)state;
@end

@interface UIColor (special)
+(id)tableCellGroupedBackgroundColor;
@end;

@interface LSApplicationProxy (More)
+(id)applicationProxyForIdentifier:(id)arg1;
-(BOOL)isContainerized;
-(NSString *)bundleIdentifier;
-(NSURL *)dataContainerURL;

@end

@interface LSApplicationWorkspace (More)

-(id)allInstalledApplications;
-(BOOL)openApplicationWithBundleID:(id)arg1;

@end


@interface BreezySettings() {
    BOOL _didFixStupid;
}
@property (nonatomic, strong) NSString *importsPath;
@property (nonatomic, strong) NSString *defaultBundleID;
@end

@implementation BreezySettings


- (void)restartSharingd {
    //+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[@"-9", @"sharingd"]];
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"BreezySettings viewDidAppear");
    
}

- (id)loadSettingGroups {
    
    NSLog(@"BreezySettings loadSettingGroups");
    
    id facade = [[objc_getClass("TSKPreferencesFacade") alloc] initWithDomain:@"com.nito.Breezy" notifyChanges:TRUE];
    NSMutableArray *_backingArray = [NSMutableArray new];
    TSKSettingItem *settingsItem = [TSKSettingItem toggleItemWithTitle:@"Toggle AirDrop Server" description:@"Turn on AirDrop to receive files through AirDrop from supported devices" representedObject:facade keyPath:@"airdropServerState" onTitle:nil offTitle:nil];
    [settingsItem setDefaultValue:@1];
    //NSLog(@"created settings item: %@", settingsItem);
    
    TSKSettingItem *restartSharingd = [TSKSettingItem actionItemWithTitle:@"Restart Sharingd" description:@"If AirDrop is rejecting your transfers, attempt to restart sharingd daemon." representedObject:facade keyPath:@"" target:self action:@selector(restartSharingd)];
    TSKSettingGroup *group = [TSKSettingGroup groupWithTitle:nil settingItems:@[settingsItem, restartSharingd]];
    [_backingArray addObject:group];
    [self setValue:_backingArray forKey:@"_settingGroups"];
    return _backingArray;
}

+(TSKPreviewViewController*)defaultPreviewViewController {
    static TSKPreviewViewController *_defaultPreviewViewController=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultPreviewViewController = [[TSKPreviewViewController alloc] init];
        NSLog(@"_defaultPreviewViewController => %@", _defaultPreviewViewController);
        NSString *imagePath = [[NSBundle bundleForClass:self.class] pathForResource:@"icon" ofType:@"png"];
        UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
        if (icon != nil) {
            TSKVibrantImageView *imageView = [[TSKVibrantImageView alloc] initWithImage:icon];
            [_defaultPreviewViewController setContentView:imageView];
        }
    });
    return _defaultPreviewViewController;
}

-(id)previewForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    TSKSettingGroup *currentGroup = self.settingGroups[indexPath.section];
    TSKSettingItem *currentItem = currentGroup.settingItems[indexPath.row];
    NSString *desc = [currentItem localizedDescription];
    TSKPreviewViewController *item = [self.class defaultPreviewViewController];
    [item setDescriptionText:desc];
    return item;
}

@end
