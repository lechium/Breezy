# Breezy
Jailbreak implementation &amp; research for AirDrop on tvOS. 

## Unified implementation

In the latest update the implementation has been improved and standardized to be more consistent with what you expect / experience on iOS and macOS when adding AirDrop support. Utilizing [UTI types](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_intro/understand_utis_intro.html#//apple_ref/doc/uid/TP40001319-CH201-SW1) and Document types to enable users to discern what application (if there are multiple) will open / import the files.

Below you will find some resources on how to edit your Info.plist file to add AirDrop receiver support to your app.

It is also necessary to handle opening file URL's (done the same way it is in iOS) to handle the files being fed to your through launch services.

Will use my changes to RetroArch here as the implementation example:

Example of an incoming notification

```[AirPhoto] 
    app: <UIApplication: 0x14be16ed0> app 
    openURL: file:///Library/Caches/com.nito.AirPhoto/Screen%20Shot%202019-12-17%20at%206.47.15%20PM.png url, 
    options: {
    UIApplicationOpenURLOptionsAnnotationKey =     {
        LSDocumentDropCount = 13;
        LSDocumentDropIndex = 0;
        LSMoveDocumentOnOpen = 0;
    };
    UIApplicationOpenURLOptionsOpenInPlaceKey = 0;
    UIApplicationOpenURLOptionsSourceApplicationKey = "com.apple.PineBoard";
}
```
You will notice a LSDocumentDropCount & LSDocumentDropIndex key, these are special keys we add so you can either support the files in a cluster once they are all received, OR you can process them one at a time. This part is completely up to you on implementation. For instance nitoTV wants to process DEB files in a cluster because they may include dependencies needed for the packages to install. However, the drawback is things will not start visibly processing until it has received ALL of the files.


```Objective-C

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSLog(@"[RetroArchTV] host: %@ path: %@", url.host, url.path);
    NSString *filename = (NSString*)url.path.lastPathComponent;
    NSError     *error = nil;
    
    NSString *newDocs = [self outputPathForFile:filename];
    if (![man fileExistsAtPath:newDocs]){
        NSLog(@"[RetroArchTV] %@ does not exist! attempting to create it", newDocs);
        [man createDirectoryAtPath:newDocs withIntermediateDirectories:TRUE attributes:nil error:nil];
    }
    [man moveItemAtPath:[url path] toPath:[newDocs stringByAppendingPathComponent:filename] error:&error];

    if (error) { //this will error out on chimera
        NSLog(@"[RetroArchTV] move file error error: %@", [error description]);
            printf("%s\n", [[error description] UTF8String]);
                [man copyItemAtPath:[url path] toPath:[newDocs stringByAppendingPathComponent:filename] error:&error];
    }
    return true;
}

```
This [Info.plist](https://github.com/lechium/RetroArch/blob/master/pkg/apple/tvOS/Info.plist#L9) will give you the info necessary to see how "all documents" support was added (not recommended to add ALL documents) 

***NOTE: Obsolete Legacy Instructions***

You can also reference the file in this repo: [VLC-tvOS-Info.plist](../master/VLC-tvOS-Info.plist) to see how I took the Info.plist from VLC for iOS and grabbed the necessary keys and added them to the tvOS version. Just replaced the old Info.plist inside the original with this one, ran uicache and was good to go! 

### NEW HOTNESS

To add VLC support (to show in the listings of Applications available- more work is needed for handling openURL:) there is a new key added to the preferences file in ***/var/mobile/Library/Preferences/com.nito.Breezy.plist*** called ***appMimicMap*** which is a dictionary of arrays. The keys of the dictionary are the applications you want to mimic the AirDrop settings of, ie ***@{@"com.nito.Ethereal":@[@"org.videolan.vlc-ios"]}** are the default values. This means that ***org.videolan.vlc-ios*** will mimic the settings of Ethereal.  [Breezy.xm](../master/Breezy.xm#L101-L138)

## Exporting files using AirDrop

### AirDropHelper

AirDropHelper is a headerless application that uses a URL scheme (airdropper://) to receive files from any other application / tweak or command line utility on the device and will handle presenting the standard AirDrop sharing UI

### Calling from an application (whether original or tweaked)

```Objective-C

    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"airdropper://%@?sender=%@", @"/path/to/file", bundleID]];
    [[UIApplication sharedApplication] openURL:url];
```

### Calling from a CLI tool or Daemon (anything without a user interface)

```Objective-C

#import <objc/runtime.h>

@interface LSApplicationWorkspace: NSObject
- (BOOL)openURL:(id)string;
+ (id)defaultWorkspace;

@end

- (BOOL)sendFileToBreezy:(NSString *)theFile {

//create URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"airdropper://%@", theFile]];

//load Mobile Core Services framework 
    [[NSBundle bundleWithPath:@"/System/Library/Frameworks/MobileCoreServices.framework"] load];
//load URL
    [[objc_getClass("LSApplicationWorkspace") defaultWorkspace] openURL:url];

}

```

Thats it! 

As long as you add 
```
com.nito.breezy (>=2.5-1)
``` 
to your dependencies, this will open an AirDrop sharing dialog with whatever file you feed it with the call to 

```Objective-C 
[[UIApplication sharedApplication] openURL:url]
```

This insanely simple application is explained below.

as previously mentioned AirDropHelper is a headless application (full fledged Application with a view controller heirarchy, just no visible icon on the home screen)

This is achieved by adding the following to the Info.plist file: 

[Info.plist](../master/AirDropHelper/AirDropHelper/Info.plist#L54-L57)

```
<key>SBAppTags</key>
    <array>
    <string>hidden</string>
</array>
```

I abuse the same URL scheme system that determines where https://mywebsite.com is open in your default browser. 

[Info.plist](../master/AirDropHelper/AirDropHelper/Info.plist#L31-L49)

airdropper:// is the custom scheme AirDropHelper listens for. From there its as simple as implementing the standard methods in AppDelegate.m to handle URL's opening and calling a custom method to display the standard UIViewController for sharing via AirDrop from the private Sharing (or SharingUI) framework. 

```Objective-C
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    NSLog(@"url: %@ app identifier: %@", url.host, url.path.lastPathComponent);
    NSString *filePath = [url path];
    [self showAirDropSharingView:filePath];
    return TRUE;
}

- (void)showAirDropSharingView:(NSString *)filePath {

    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Sharing.framework"];
    [bundle load];
    UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSLog(@"url: %@", url);

    id sharingView = [[objc_getClass("SFAirDropSharingViewControllerTV") alloc] initWithSharingItems:@[url]];
    [sharingView setCompletionHandler:^(NSError *error) {

        NSLog(@"complete with error: %@", error);
        //quit the application when we are done.
        [[UIApplication sharedApplication] terminateWithSuccess];
    }];

    [rvc presentViewController:sharingView animated:true completion:nil];

}

```
illustrated in [AppDelegate.m](../master/AirDropHelper/AirDropHelper/AppDelegate.m#L56-L84)

The only other missing piece of the puzzle is signing the application with our own special entitlements specifically
"com.apple.private.airdrop.discovery"

## Provenance support (provscience folder)

There are a few reasons I opted for code injection to add support to Provenance, its written in swift and has tons of dependencies both managed by cocoapods and carthage and is very difficult & time consuming to build, I have opted to add AirDrop support through tweaking the application. The copies that I distribute have the Info.plist files augmented to support all the BIOS and ROM files, and then Tweak.x takes care of the rest, (handling the openURL:... calls)

## VLC Support (vlcscience folder)

Due to the fact VLC is an App Store app, we NEED to tweak it to inject support, plus this is such a popular app I didn't mind including this as part of Breezy (it should probably be a separate module) Same thing applies here, using code injection to add openURL: calls and moving the files into the folder where VLC will detect them. The other injection is done in Breezy.xm to avoid needing to modify the Info.plist file to advertise what UTI's are support (covered elsewhere in this README)

## Abusing sharingd

**On 12+ you need a special entitlement added to your application for it to appear as an airdrop server: com.apple.private.airdrop.settings**

## How this works

The core functionality of Breezy is mostly achieved through stock features in Sharing[UI].framework (including the sharing UI and toggling  AirDrop sharing state) 

With vanilla / stock implementation sharingd will throw an exception when AirDropped files are received, halting the process in its tracks.

The file linked below is where the exception is thrown in sharingd, a partial reconstruction of the method that throws the exception.

[SDAirDropTransferManager.m](../master/Research/sharingd%20daemon/SDAirDropTransferManager.m)

tl;dr the transfer needs a "handler" to determine what to do with the file once the transfer is complete. if this handler is nil, it throws an exception and the transfer is killed. (this exception is only thrown on versions < 13, just mentioned for posterity, not incredibly relevant)

```Objective-C
- (id)determineHandlerForTransfer:(id)transfer
```

Is where this handler is determined, so I target [here](../master/Breezy.xm#L77) first 

There's an issue with consent to receive files to your AppleTV from other AirDropped devices, this is handled by a read only properties in **SFAirDropTransferMetaData**

```Objective-C
    SFAirDropTransferMetaData *meta = [transfer metaData];
   [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_verifiableIdentity"];
   [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_canAutoAccept"];
```

### Handling consent

Consent is only necessary if the user sending the file isn't identical to a user account signed in to your AppleTV.

* Ethan Arbuckle is responsible for the awesome work related to this, I'm writing up how it works post mortem many months after he did it. 

Additional hooks & function additions were necessary inside of ***SDAirDropTransferManager*** to handle file sending consent,  a hook is added in ***- (id)init*** to add a new ***NSDistributedNotificationCenter*** observer specifically for new selector ***- (void)handleBreezyAirdropPermissionResponse:(id)notification***

We will return to this function in a moment after exploring the rest of this process.

If we are getting a nil handler in ***- (id)determineHandlerForTransfer:(id)transfer*** then we construct our own and return it, therefore the exception is no longer thrown from ***- (void)askEventForRecordID:(id)recordID withResults:(id)results*** in ***SDAirDropTransferManager***

```Objective-C
    id genericHandler = [[objc_getClass("SDAirDropHandlerGenericFiles") alloc] initWithTransfer:transfer bundleIdentifier:@"com.nito.nitoTV4"];
    ((void (*)(id, SEL))objc_msgSend)(genericHandler, NSSelectorFromString(@"prepareOrPerformOpenAction")); //new consent related additions
    ((void (*)(id, SEL))objc_msgSend)(genericHandler, NSSelectorFromString(@"updatePossibleActions")); //ditto
    [genericHandler activate];
    return genericHandler;
```

From here [- (void)askEventForRecordID:(id)recordID withResults:(id)results](../master/Breezy.xm#L90) will get triggered and a payload dictionary is constructed with the necessary data to send to ***PineBoard's*** [new function](../master/Breezy.xm#L210) mentioned above  

Before sending the data the payload is [blessed](../master/Breezy.xm#L12) to make sure its being sent from ***sharingd*** and not some rogue process. 

Ask for event is where the user is actually presented with the dialog, depending on if the Accepted or Denied it will either send action type ***KBBreezyButtonActionAccept*** or ***KBBreezyButtonActionDeny***

This alert will be presented via the same new function in ***PineBoard*** that we added to present our alert with application choices to open files in when necessary ***- (void)showSystemAlertFromAlert:(id)alert*** sending out the payload that is constructed with ***KBBreezyRequestPermission*** context.

After the action is processed it will fire the notification ***KBBreezyAirdropPresentAlert*** with context type ***KBBreezyRespondToPermission***

***- (void)showSystemAlertFromAlert:(id)alert***  will ignore this context but ***- (void)handleBreezyAirdropPermissionResponse:(id)notification*** will gladly accept it.

```Objective-C
    NSString *selectedActionIdentifier = payload[KBBreezyAlertSelectedAction];
    id selectedAction = nil;

    SFAirDropTransfer *transfer = ((NSDictionary *(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"transferIdentifierToTransfer"))[recordID];
    NSArray *possibleActions = ((NSArray *(*)(id, SEL))objc_msgSend)(transfer, NSSelectorFromString(@"possibleActions"));

    // Determine which action is intended
    if ([selectedActionIdentifier isEqualToString:KBBreezyButtonActionAccept]) {
        // Accept is the first "possible action"
        selectedAction = possibleActions[0];
    }
    else if ([selectedActionIdentifier isEqualToString:KBBreezyButtonActionDeny]) {
        selectedAction = [transfer valueForKey:@"_cancelAction"];
    }

    // Perform selected action
    ((void (*)(id, SEL, id, id))objc_msgSend)(self, NSSelectorFromString(@"transfer:actionTriggeredForAction:"), transfer, selectedAction);
    ((void (*)(id, SEL, id))objc_msgSend)(self, NSSelectorFromString(@"transferUserResponseUpdated:"), transfer);
```

If the transfer is accepted it will initiate and the rest of the process is explained below

Once the transfer is initiated it repeatedly calls ***-(void)updateWithInformation:(NSDictionary*)info*** on the transfer ***SFAirDropTransfer***

there is a key of NSURL's called ***Items*** once that is populated, you know the items are processed successully.

Said dictionary looks like this
```-[<SFAirDropTransfer: 0x102fad240> updateWithInformation:{
    AutoAccept = 1;
    BundleID = "com.apple.finder";
    BytesCopied = 86582768;
    "Content-Type" = "application/x-dvzip";
    Files =     (
                {
        ConvertMediaFormats = 0;
        FileBomPath = "./electraTV_1.3.2.ipa";
        FileIsDirectory = 0;
        FileName = "electraTV_1.3.2.ipa";
        FileType = "com.apple.itunes.ipa";
            }
    );
    FilesCopied = 0;
    Items =     (
            "file:///var/mobile/Downloads/com.apple.AirDrop/B9C79A0B-CD86-45D3-8F28-830401CFDBB6/Files/electraTV_1.3.2.ipa"
    );
    SenderCompositeName = "Kevin Bradley";
    SenderComputerName = XXXXX;
    SenderEmail = "XXXXXXX";
    SenderFirstName = Kevin;
    SenderID = XXXXXXX;
    SenderIcon = <89504e47 0d0a1a0a 0000000d 49484452 000000fa 000000fa 08060000 0088ec5a 3d000000 01735247 4200aece 1ce90000 001c6944 4f540000 00020000 00000000 007d0000 00280000 007d0000 007d0000 0ecbdf9c ec3e0000 0e974944 41547801 ec5d0bac 1d5515bd b4b528c5 f22d890a 1a032526 52b5368a 34942616 29d<…>
    });
```

When the transfer is finished [-(void)finishedEventForRecordID:(id)recordID withResults:(id)arg](../master/Breezy.xm#L163) is triggered and the final payload is constructed to send to [- (void)showSystemAlertFromAlert:(id)alert](../master/Breezy.xm#L385) with context type ***KBBreezyOpenAirDropFiles*** 

From there we cycle through the items and convert them to NSString's (URL's can't be sent in a NSDistributedNotification) And then post a notification that is listened for inside of hooks into PineBoard (this is currently necessary to get access to the dialog/windowing classes we need to use to show the user an alert with options to choose from)

## PineBoard 

There are various reasons we need to inject into PineBoard to get this process to work. 

1. Presenting Alert Views system wide (this may be possible other ways, but this works for now)
2. Interacting with PBProcessManager to open documents inside their targeted applications.


```Objective-C 
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    _Bool orig = %orig;
    %log;
    id notificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [notificationCenter addObserver:self  selector:@selector(showSystemAlertFromAlert:) name:@"com.breezy.kludgeh4x" object:nil]; //still need to get rid of this ugly eyesore
    return orig;
    
}
```

***- (void)showSystemAlertFromAlert:(id)alert*** will show an alert if there is more than one application that is capable of opening the files / urls that were airdropped, otherwise it will automatically open URL's (tested 12.4-13.2) as necessary in the targeted application in a new function added

```Objective-C 
%new - (void)openItems:(NSArray *)items ofType:(KBBreezyFileType)fileType withApplication:(id)proxy
```

To accomodate differing sandbox permissions and patches in chimera vs checkra1n, we now import the files into a different directory to make sure they can be read by the receiving application.

```Objective-C
%new - (NSString *)importFile:(NSString *)inputFile withApp:(id)proxy 
```

 A combination of **FrontBoard(Services)** framework and **PineBoard** application are used to open the URLs in their target applications. A ***FBSystemServiceOpenApplicationRequest*** is created from a special ***NSDictionary*** that is crafted into an instance of ***FBSOpenApplicationOptions***. from there ***PBProcessManager*** is utilized in different ways depending on OS version to open the files / URLs in the targeted application.
 
 Using these custom calls from within PineBoard enables us to bypass restrictions in launch services on which applications can open certain file types, but it also makes this project less 'portable' to iOS to augment any of the features missing over there, i think this is a worthwhile sacrifice personally.


## Preference loader bundle

Handles whether or not AirDrop sharing is turned on or off, and gives ability to restart sharingd in case injection didn't happen properly during installation. (bundle/BreezySettngs.m)

Preferences are synced using a ***DistributedSynchronizationHandler***, this is done as follows:

```Objective-C
    id facade = [[objc_getClass("TVSettingsPreferenceFacade") alloc] initWithDomain:@"com.nito.Breezy" notifyChanges:TRUE];
   ...
   TSKSettingItem *settingsItem = [TSKSettingItem toggleItemWithTitle:@"Toggle AirDrop Server" description:@"Turn on AirDrop to receive files through AirDrop from supported devices" representedObject:facade keyPath:@"airdropServerState" onTitle:nil offTitle:nil];

```
TVSettingsPreferenceFacade registers a domain and specifies to notify changes, then a TSKSettingsItem 'toggleItem' handles the on off state and sending the notification through. The Daemon explained below handles receives a notification and changes the settings accordingly.


## Daemon

The daemon (breezyd) has a 2 responsibilities:

1. Toggle whether or not AirDrop is available on/off based on a DistributedSynchronizationHandler
2. Setting up said DistributedSynchronizationHandler to sync preferences between breezy preference bundle and its daemon

### Toggle AirDrop state 

To toggle the AirDrop state an instace of SFAirDropDiscoveryController from the Sharing[UI] framework is created & saved as a property. To toggle AirDrop 'discoverable mode' I call setDiscoverableMode: on 'discoveryController' (our property for SFAirDropDiscoveryController) to SDAirDropDiscoverableModeOff or SDAirDropDiscoverableModeEveryone respectively.

### DistributedSynchronizationHandler

This is how to listen for changes from a preferenceloader bundle
```Objective-C
- (void)setupListener {
    [TVSPreferences addObserverForDomain:@"com.nito.Breezy" withDistributedSynchronizationHandler:^(id object) {
    [self preferencesUpdated];
}];
}
```
and preferenceUpdates tracks what the discovery mode is set to and either turns AirDrop on or off and updates the preferences accordingly.

## More tvOS AirDrop Info 

[Go Here](https://wiki.awkwardtv.org/wiki/AirDrop_Central)

**The information listed below is for posterity / explaining how the daemon works, you don't need to listen for this manually at all.**

### Discovering AirDrop in the background

```Objective-C

typedef enum : NSUInteger {
    SDAirDropDiscoverableModeOff,
    SDAirDropDiscoverableModeContactsOnly,
    SDAirDropDiscoverableModeEveryone,
} SDAirDropDiscoverableMode;

@interface SFAirDropDiscoveryController: UIViewController
- (void)setDiscoverableMode:(long long)mode;
- (long long)discoverableMode;
- (id)discoverableModeToString:(long long)mode;
@end

@interface AirDropListener ()
@property (nonatomic, strong) SFAirDropDiscoveryController *discoveryController;
@end

@interface AirDropListener: NSObject
- (void)disableAirDrop;
- (void)setupAirDrop;
@end

@implementation AirDropListener

//in case you want to display this anywhere
- (NSString *)displayNameForAirDropMode {

    long long mode = [self.discoveryController discoverableMode];
    return [self.discoveryController discoverableModeToString:mode];

}

- (void)disableAirDrop {

    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.nito.AirDropper/airDropFileReceived" object:nil];
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeOff];

}

- (void)setupAirDrop {

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(airDropReceived:) name:@"com.nito.AirDropper/airDropFileReceived" object:nil];
    if (!self.discoveryController){
        self.discoveryController = [[SFAirDropDiscoveryController alloc] init] ;
    }
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeEveryone];

}

@end

```

**This information is for posterity only, you no longer need to do this**

## Calling the AirDrop server view

```Objective-C

- (void)showAirDropSharingSheet {
    
    SFAirDropReceiverViewController *rec = [[SFAirDropReceiverViewController alloc] init];
    [rec setOverriddenInstructionsText:@"Drop whatever you want b"]; //this doesn't actually work.. regardless of when you set it.
    [self presentViewController:rec animated: YES completion: nil];
    
    //use KVO to get the label
    UILabel *ourLabel = [rec valueForKey:@"_instructionsLabel"];
    //grab this to retain appearance
    UIFont *ogFont = [ourLabel font];
    //obviously only one of these calls is necessary, probably just the one before the fact
    [ourLabel setFont:ogFont];
    [ourLabel setText:@"Drop whatever you want b"];
    [ourLabel setFont:ogFont];
    [rec startAdvertising]; //this is how we show we are available to AirDrop clients

    
}
```
**This information is for posterity only, use the helper with airdropper:// url scheme to 'export' files**

**On 12+ you need a special entitlement added to your application for it to discover other airdrop devices: com.apple.private.airdrop.discovery**

## Sending a file to another AirDrop capable device

```Objective-C

@interface SFAirDropSharingViewControllerTV : UIViewController
-(id)initWithSharingItems:(id)arg1;
-(void)setCompletionHandler:(void (^)(NSError *error))arg1;
@end

- (void)airdropFile:(NSString *)file {
    
    NSURL *url = [NSURL fileURLWithPath:file];    
    SFAirDropSharingViewControllerTV *sharingView = [[SFAirDropSharingViewControllerTV alloc] initWithSharingItems:@[url]];
    [sharingView setCompletionHandler:^(NSError *error) {
   	    [self dismissViewControllerAnimated:true completion:nil];
    }];
    [self presentViewController:sharingView animated:true completion:nil];
    
}

```


