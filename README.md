# Breezy
Jailbreak implementation &amp; research for AirDrop on tvOS. 

## Unified implementation

In the latest updated the implementation has been improved and standardized to be more consistent with what you expect / experience on iOS and macOS when adding AirDrop support. Utilizing [UTI types](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_intro/understand_utis_intro.html#//apple_ref/doc/uid/TP40001319-CH201-SW1) and Document types to enable users to discern what application (if there are multiple) will open / import the files.

tldr: it is no longer necessary to listen for distributed notifications to get AirDrop server support added to your application! 

Below you will find some resources on how to edit your Info.plist file to add AirDrop receiver support to your app.

It is also necessary to handle opening file URL's (done the same way it is in iOS) to handle the files being fed to your through launch services.

Will use my changes to RetroArch here as the implementation example:

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

You can also reference the file in this repo: [VLC-tvOS-Info.plist](../master/VLC-tvOS-Info.plist) to see how I took the Info.plist from VLC for iOS and grabbed the necessary keys and added them to the tvOS version. Just replaced the old Info.plist inside the original with this one, ran uicache and was good to go!

Currently there is a stop gap implementation to get VLC to support AirDropped files through code injection & piggybacking off the files that Ethereal supports. This is thoroughly documented inside [Breezy.xm](../master/Breezy.xm#L158)

## Exporting files using AirDrop

### AirDropHelper

AirDropHelper is a headerless application uses a URL scheme (airdropper://) to receive files from any other application / tweak or command line utility on the device and will handle presenting the standard AirDrop sharing UI

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

    id sharingView = [[NSClassFromString(@"SFAirDropSharingViewControllerTV") alloc] initWithSharingItems:@[url]];
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

Is where this handler is determined, so I target [here](../master/Breezy.xm#L101) first 

There's an issue with consent to receive files to your AppleTV from other AirDropped devices, this is handled by a read only properties in **SFAirDropTransferMetaData**

```Objective-C
    SFAirDropTransferMetaData *meta = [transfer metaData];
   [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_verifiableIdentity"];
   [meta setValue:[NSNumber numberWithBool:TRUE] forKey:@"_canAutoAccept"];
```

**For now this is forcing consent without any user interaction, while its a nice UX it's a bad workaround that will be reconcilled ASAP.**

If we are getting a nil handler in ***- (id)determineHandlerForTransfer:(id)transfer*** then we construct our own and return it, therefore the exception is no longer thrown from ***- (void)askEventForRecordID:(id)recordID withResults:(id)results*** in ***SDAirDropTransferManager***

```Objective-C
    id genericHandler = [[NSClassFromString(@"SDAirDropHandlerGenericFiles") alloc] initWithTransfer:transfer bundleIdentifier:@"com.nito.nitoTV4"];
    [genericHandler activate];
    return genericHandler;
```
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

From there we cycle through the items and convert them to NSString's (URL's can't be sent in a NSDistributedNotification) And then post a notification that is listened for inside of hooks into PineBoard (this is currently necessary to get access to the dialog/windowing classes we need to use to show the user an alert with options to choose from)

## PineBoard 

```Objective-C 
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    _Bool orig = %orig;
    %log;
    id notificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [notificationCenter addObserver:self  selector:@selector(showSystemAlertFromAlert:) name:@"com.breezy.kludgeh4x" object:nil]; //still need to get rid of this ugly eyesore
    return orig;
    
}
```

***showSystemAlertFromAlert*** will show an alert if there is more than one application that is capable of opening the files / urls that were airdropped, otherwise it will automatically open URL's (tested 12.4-13.2) as necessary in the targeted application in a new function added

```Objective-C 
%new - (void)openItems:(NSArray *)items ofType:(KBBreezyFileType)fileType withApplication:(id)proxy
```
there a combination of **FrontBoard(Services)** and **PineBoard** are used to actually open the urls in their target applications. A ***FBSystemServiceOpenApplicationRequest*** is created from a special ***NSDictionary*** that is crafted into an instance of ***FBSOpenApplicationOptions***. from there ***PBProcessManager*** is utlized in different ways depending on OS version to open the files / URLs in the targeted application.


## Preference loader bundle

Handles whether or not AirDrop sharing is turned on or off, and gives ability to restart sharingd in case injection didn't happen properly during installation. (bundle/BreezySettngs.m)

Preferences are synced using a DistributedSynchronizationHandler, this is done as follows:

```Objective-C
    id facade = [[NSClassFromString(@"TVSettingsPreferenceFacade") alloc] initWithDomain:@"com.nito.Breezy" notifyChanges:TRUE];
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


