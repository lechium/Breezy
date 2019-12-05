#import <UIKit/UIKit.h>
#import "TSKVibrantImageView.h"
#import "TSKPreviewViewController.h"

@interface TVSettingsPreferenceFacade : NSObject
{
    NSString *_domain;    // 16 = 0x10
    NSString *_containerPath;    // 24 = 0x18
}

@property(readonly, copy, nonatomic) NSString *containerPath; // @synthesize containerPath=_containerPath;
@property(readonly, copy, nonatomic) NSString *domain; // @synthesize domain=_domain;

- (id)valueForUndefinedKey:(id)arg1;    // IMP=0x0000000100011ce0
- (void)setValue:(id)arg1 forUndefinedKey:(id)arg2;    // IMP=0x0000000100011b98
- (id)_initWithDomain:(id)arg1 containerPath:(id)arg2 notifyChanges:(_Bool)arg3;    // IMP=0x0000000100011a44
- (id)initWithDomain:(id)arg1 notifyChanges:(_Bool)arg2;    // IMP=0x0000000100011a30
- (id)initWithDomain:(id)arg1 containerPath:(id)arg2;    // IMP=0x00000001000119d0

@end

@interface TSKSettingItem: NSObject

@property (nonatomic,readonly) id representedObject;
@property (nonatomic,copy) NSString * localizedValue;
@property (nonatomic,copy,readonly) NSString * keyPath;

+(id)childPaneItemWithBundle:(id)arg1 representedObject:(id)arg2 ;
+(id)valueForSettingItem:(id)arg1 ;
+(void)setValue:(id)arg1 forSettingItem:(id)arg2 ;
+(id)actionItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 target:(id)arg5 action:(SEL)arg6 ;
+(id)childPaneItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 childControllerClass:(Class)arg5 ;
+(id)childPaneItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 childControllerBlock:(/*^block*/id)arg5 ;
+(id)childPaneItemWithBundle:(id)arg1 ;
+(id)titleItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 ;
+(id)textInputItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 ;
+(id)toggleItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 onTitle:(id)arg5 offTitle:(id)arg6 ;
+(id)multiValueItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 availableValues:(id)arg5 ;
@end

@interface TSKSettingGroup : TSKSettingItem
@property (nonatomic,copy) NSArray * settingItems;
+(id)groupWithTitle:(id)arg1 settingItems:(id)arg2;
@end

@interface TSKTableViewController : UITableViewController

@end

@interface TSKViewController: TSKTableViewController

-(id)loadSettingGroups;
@property (nonatomic,copy,readonly) NSArray * settingGroups;
@end
