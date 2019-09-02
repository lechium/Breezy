# Breezy
Jailbreak implementation &amp; research for AirDrop on tvOS

**On 12+ you need a special entitlement added to your application for it to appear as an airdrop server: com.apple.private.airdrop.settings**

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
self.discoveryController = [[SFAirDropDiscoveryController alloc] init] ;
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


