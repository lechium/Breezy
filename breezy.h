

@interface _LSLazyPropertyList : NSObject

@property (readonly) NSDictionary * propertyList;
+(BOOL)supportsSecureCoding;
+(id)lazyPropertyListWithPropertyListData:(id)arg1 ;
+(id)lazyPropertyList;
+(id)lazyPropertyListWithPropertyListURL:(id)arg1 ;
+(id)lazyPropertyListWithPropertyList:(id)arg1 ;
+(id)lazyPropertyListWithContext:(id)arg1 unit:(unsigned)arg2 ;
+(id)lazyPropertyListWithLazyPropertyLists:(id)arg1 ;
-(id)copyWithZone:(NSZone*)arg1 ;
-(id)init;
-(void)encodeWithCoder:(id)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(NSDictionary *)propertyList;
-(id)objectForPropertyListKey:(id)arg1 ofClass:(Class)arg2 ;
-(BOOL)_getPropertyList:(id*)arg1 ;
-(BOOL)_getValue:(id*)arg1 forPropertyListKey:(id)arg2 ;
-(id)_filterValueFromPropertyList:(id)arg1 ofClass:(Class)arg2 valuesOfClass:(Class)arg3 ;
-(id)objectsForPropertyListKeys:(id)arg1 ;
-(id)objectForPropertyListKey:(id)arg1 ofClass:(Class)arg2 valuesOfClass:(Class)arg3 ;
@end

@interface LSBundleProxy: NSObject
-(NSString *)bundleIdentifier;
@end
@interface LSApplicationProxy: LSBundleProxy
+(id)applicationProxyForIdentifier:(id)arg1;
-(BOOL)isContainerized;
-(NSURL *)dataContainerURL;
@end

@interface PBDialogContext : NSObject
@property (nonatomic,readonly) id provider;              //@synthesize provider=_provider - In the implementation block
@property (nonatomic,readonly) NSString * identifier;                               //@synthesize identifier=_identifier - In the implementation block
+(id)contextWithViewController:(id)arg1 ;
+(id)contextWithViewService:(id)arg1 ;
+(id)contextWithViewServiceName:(id)arg1 className:(id)arg2 ;
-(void)_invalidate;
-(NSString *)identifier;
-(id)provider;
-(id)initWithIdentifier:(id)arg1 provider:(id)arg2 ;

@end

@interface PBDialogManager : NSObject
+(id)sharedInstance;
-(NSMutableDictionary *)identifiersToContexts;
-(NSMutableArray *)hiddenDialogAssertions;
-(void)overlayController:(id)arg1 willPresentSession:(id)arg2 ;
-(void)overlayController:(id)arg1 didPresentSession:(id)arg2 ;
-(void)overlayController:(id)arg1 willDismissSession:(id)arg2 withContext:(id)arg3 ;
-(void)overlayController:(id)arg1 didDismissSession:(id)arg2 ;
-(void)overlayController:(id)arg1 didCancelSession:(id)arg2 withContext:(id)arg3 ;
-(id)overlayController;
-(void)presentDialogWithContext:(id)arg1 options:(id)arg2 completion:(/*^block*/id)arg3 ;
-(void)dismissDialogWithContext:(id)arg1 options:(id)arg2 completion:(/*^block*/id)arg3 ;
-(BOOL)dismissActiveDialogAnimated:(BOOL)arg1 ;
-(void)dismissDialogWithContext:(id)arg1 options:(id)arg2 animated:(BOOL)arg3 completion:(/*^block*/id)arg4 ;
-(void)_setNotifyStateThatPineBoardIsShowingAnAlert:(BOOL)arg1 ;
-(BOOL)dismissActiveDialog;
@end

@interface PBContentPresentingContainmentViewController: UIViewController

@property (nonatomic,readonly) BOOL allowsInteraction;
@property (assign,nonatomic) BOOL acceptsEventFocus;
@property (nonatomic,readonly) UIViewController * childViewController;
@property (nonatomic,readonly) BOOL expectsEventForwarding;
@property (assign,nonatomic) id contentDelegate;
@property (getter=isInterruptible,nonatomic,readonly) BOOL interruptible;
-(id)initWithChildViewController:(id)arg1 allowsInteraction:(BOOL)arg2 expectsEventForwarding:(BOOL)arg3;
-(void)presentContentAnimated:(BOOL)arg1 clientOptions:(id)arg2 withCompletion:(id)arg3 ;
-(void)dismissContentAnimated:(BOOL)arg1 clientOptions:(id)arg2 withCompletion:(id)arg3 ;

@end

@interface PBAppDelegate: NSObject
- (void)showSystemAlertFromAlert:(id)alert;
- (void)postBulletinForFile:(NSString *)file;
- (void)sendBulletinWithMessage:(NSString *)message title:(NSString *)title;
@end

@interface PBAppDelegate (science)

@property (nonatomic) NSOperationQueue *openOperationQueue;
@property (nonatomic) NSMutableArray *operationArray;
- (void)runNextOperation;
@end

@interface LSApplicationWorkspace: NSObject

+(id)defaultWorkspace;
- (NSArray *)applicationsAvailableForHandlingURLScheme:(id)scheme;
- (NSArray *)applicationsAvailableForOpeningDocument:(id)documentProxy;
-(BOOL)openApplicationWithBundleID:(id)arg1;
-(id)operationToOpenResource:(id)arg1 usingApplication:(id)arg2 uniqueDocumentIdentifier:(id)arg3 isContentManaged:(BOOL)arg4 sourceAuditToken:(id)arg5 userInfo:(id)arg6 options:(id)arg7 delegate:(id)arg8;
@end
@interface NSProgress (science)
- (BOOL)isFinished;
@end
@interface PBWindowManager: NSObject
+ (id)sharedInstance;
- (void)presentDialogViewController:(id)dialog;
- (void)dismissDialogViewController:(id)view;
@end
@interface PBUserNotificationViewControllerAlert: UIViewController
-(id)initWithTitle:(id)arg1 text:(id)arg2;
-(void)addButtonWithTitle:(id)arg1 type:(unsigned long long)arg2 handler:(void (^)(void))handler;
@property NSString *text;
@end
@interface LSDocumentProxy: NSObject
+(id)documentProxyForName:(id)arg1 type:(id)arg2 MIMEType:(id)arg3 ;
-(id)applicationsAvailableForOpeningWithTypeDeclarer:(BOOL)arg1 style:(unsigned char)arg2 XPCConnection:(id)arg3 error:(id*)arg4;
-(id)applicationsAvailableForOpeningWithStyle:(unsigned char)arg1 limit:(unsigned long long)arg2 XPCConnection:(id)arg3 error:(id*)arg4 ; //13.x
@end
@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end
@interface SDAirDropHandlerGenericFiles: NSObject //its not but its fine.
- (id)initWithTransfer:(id)arg1 bundleIdentifier:(id)arg2;
- (void)activate;
@end
@interface SFAirDropTransfer: NSObject
-(NSProgress *)transferProgress;
-(id)metaData;
@end

@interface SFAirDropTransferMetaData : NSObject

-(NSArray *)rawFiles;
-(NSDictionary *)itemsDescriptionAdvanced;

@end
