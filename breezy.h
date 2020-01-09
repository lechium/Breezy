
extern id __LSGetInboxURLForAppIdentifier(id);

extern NSString * const FBSOpenApplicationOptionKeyDocumentOpen4LS; //@"__DocumentOpen4LS"
extern NSString * const FBSOpenApplicationOptionKeyActivateSuspended; //@"__ActivateSuspended"
extern NSString * const FBSOpenApplicationOptionKeyPayloadAnnotation; //@"__PayloadAnnotation"
extern NSString * const FBSOpenApplicationOptionKeyPayloadURL; //@"__PayloadURL"
extern NSString * const FBSOpenApplicationOptionKeyBrowserAppLinkState4LS;
extern NSString * const FBSOpenApplicationOptionKeyAppLink4LS;
extern NSString * const FBSOpenApplicationOptionKeyPayloadOptions; //@"__PayloadOptions"

typedef enum : NSUInteger {
    KBBreezyFileTypeLocal,
    KBBreezyFileTypeLink,
} KBBreezyFileType;


@interface LSBundleProxy: NSObject
-(NSString *)bundleIdentifier;
@end
@interface LSApplicationProxy: LSBundleProxy
+(id)applicationProxyForIdentifier:(id)arg1;
-(BOOL)isContainerized;
-(NSURL *)dataContainerURL;
-(NSURL *)resourcesDirectoryURL;

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
- (void)openItems:(NSArray *)items ofType:(KBBreezyFileType)fileType withApplication:(id)proxy;
- (NSURL *)inboxForIdentifier:(NSString *)identifier;
@end

@interface LSApplicationWorkspace: NSObject

+(id)defaultWorkspace;
- (NSArray *)applicationsAvailableForHandlingURLScheme:(id)scheme;
- (NSArray *)applicationsAvailableForOpeningDocument:(id)documentProxy;
-(BOOL)openApplicationWithBundleID:(id)arg1;
-(id)operationToOpenResource:(id)arg1 usingApplication:(id)arg2 uniqueDocumentIdentifier:(id)arg3 isContentManaged:(BOOL)arg4 sourceAuditToken:(id)arg5 userInfo:(id)arg6 options:(id)arg7 delegate:(id)arg8;
-(BOOL)openURL:(id)arg1 withOptions:(id)arg2;
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

/*
 `<NSMethodSignature: 0x282715280>
 number of arguments = 2
 frame size = 224
 is special struct return? NO
 return value: -------- -------- -------- --------
 type encoding (v) 'v'
 flags {}
 modifiers {}
 frame {offset = 0, offset adjust = 0, size = 0, size adjust = 0}
 memory {offset = 0, size = 0}
 argument 0: -------- -------- -------- --------
 type encoding (@) '@?'
 flags {isObject, isBlock}
 modifiers {}
 frame {offset = 0, offset adjust = 0, size = 8, size adjust = 0}
 memory {offset = 0, size = 8}
 argument 1: -------- -------- -------- --------
 type encoding (@) '@"NSError"'
 flags {isObject}
 modifiers {}
 frame {offset = 8, offset adjust = 0, size = 8, size adjust = 0}
 memory {offset = 0, size = 8}
 class 'NSError'
 
 */


@interface FBProcessManager : NSObject
- (void)_handleOpenApplicationRequest:(id)arg1 bundleID:(id)arg2 options:(id)arg3 withResult:(void(^)(NSError *error))arg4; //12.4 and lower
- (void)_openAppFromRequest:(id)arg1 bundleIdentifier:(id)arg2 URL:(id)arg3 completion:(void(^)(NSError *error))arg4; //13.2+
- (void)_openAppFromRequest:(id)arg1 bundleIdentifier:(id)arg2 URL:(id)arg3 withResult:(void(^)(NSError *error))arg4; //13.0 - ?
- (NSArray *)processesForBundleIdentifier:(NSString *)bundleId;
-(id)systemApplicationProcess; //FBApplicationProcess
+ (id)sharedInstance;
@end

@interface FBScene : NSObject
-(BOOL)_isInTransaction;
@end

@interface PBProcessManager : NSObject
+ (id)sharedInstance;
//12.4 only
@property(readonly, nonatomic) NSString *focusedProcessBundleIdentifier;
- (void)setFocusedProcess:(id)proc;
- (void)activateApplication:(id)arg1 openURL:(id)arg2 options:(id)arg3 suspended:(_Bool)arg4 completion:(id)arg5;    // IMP=0x00000001000fb210
- (void)activateApplication:(id)arg1 openURL:(id)arg2 suspended:(_Bool)arg3 completion:(id)arg4;
- (id)_foregroundScene;
@end

@interface FBSOpenApplicationOptions: NSObject

+ (instancetype)optionsWithDictionary:(NSDictionary *)dictionary;

@end


