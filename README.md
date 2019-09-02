# Breezy
Jailbreak implementation &amp; research for AirDrop on tvOS

**On 12+ you need a special entitlement added to your application for it to appear as an airdrop server: com.apple.private.airdrop.settings**

## How this works

Most of this functionality is used without tweak or modification on the UI end of things (to get AIrDrop advertising). However, when it comes to accepting the file and processing it, sharingd throws and exception and dies resulting in a failure to even receive the files to acheive any further processing. The file linked below is where the exception is thrown in sharingd, a partial reconstruction of the method that throws the exception.

[SDAirDropTransferManager.m](../master/Research/sharingd%20daemon/SDAirDropTransferManager.m)

tl;dr the transfer needs a "handler" to determine what to do with the file once the transfer is complete. if this handler is nil, it throws an exception and the transfer is killed.

```Objective-C
- (id)determineHandlerForTransfer:(id)transfer
```

Is where this handler is determined, so I target [here](../master/Breezy.xm#L32) first 

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

From there we cycle through the items and convert them to NSString's (URL's can't be sent in a NSDistributedNotification) And then post the notification that you listen for in your application.

From there you can move/copy the file to a new location and process it however you would like.

***I know this process is a hack, it was the quickest way to get this implemented in a short period of time, I do plan to make it more proper in the future as time permits. PR's welcome! :)**


## Discovering AirDrop in the background

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

### Receiving a notification about the AirDrop files being received:


```Objective-C

- (void)airDropReceived:(NSNotification *)n {
    
    NSDictionary *userInfo = [n userInfo];
    NSString *path = userInfo[@"Path"];
    
    NSString *fileName = path.lastPathComponent;
    //do your thing with the file
}

- (void)viewDidAppear:(BOOL)animated {
	
     //this could go in other places, just an example..

    [super viewDidAppear:animated];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(airDropReceived:) name:@"com.nito.AirDropper/airDropFileReceived" object:nil];
}
```

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


