//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class CUSystemMonitor, RPCompanionLinkClient, SDStatusMonitor, SFDeviceDiscovery;
@protocol OS_dispatch_queue;

__attribute__((visibility("hidden")))
@interface SDMediaHandoffAgent : NSObject
{
    RPCompanionLinkClient *_clinkClient;	// 8 = 0x8
    SFDeviceDiscovery *_deviceDiscovery;	// 16 = 0x10
    struct NSMutableDictionary *_devices;	// 24 = 0x18
    SDStatusMonitor *_statusMonitor;	// 32 = 0x20
    CUSystemMonitor *_systemMonitor;	// 40 = 0x28
    struct NSMutableDictionary *_triggeredDevices;	// 48 = 0x30
    _Bool _prefEnabled;	// 56 = 0x38
    _Bool _preventNotifications;	// 57 = 0x39
    NSObject<OS_dispatch_queue> *_dispatchQueue;	// 64 = 0x40
}

@property(nonatomic) _Bool preventNotifications; // @synthesize preventNotifications=_preventNotifications;
@property(retain, nonatomic) NSObject<OS_dispatch_queue> *dispatchQueue; // @synthesize dispatchQueue=_dispatchQueue;
- (void).cxx_destruct;	// IMP=0x00000001000ab3dc
- (void)testUI:(id)arg1;	// IMP=0x00000001000ab3a4
- (void)_deviceUntrigger:(id)arg1;	// IMP=0x00000001000ab2a4
- (void)_deviceTriggerIfNeeded:(id)arg1;	// IMP=0x00000001000ab04c
- (_Bool)_deviceCanTrigger:(id)arg1;	// IMP=0x00000001000aaf48
- (void)_deviceLost:(id)arg1;	// IMP=0x00000001000aae44
- (void)_deviceFound:(id)arg1;	// IMP=0x00000001000aacf0
- (void)_deviceChanged:(id)arg1;	// IMP=0x00000001000aabd8
- (_Bool)_discoveryShouldStart;	// IMP=0x00000001000aabd0
- (void)_discoveryEnsureStopped;	// IMP=0x00000001000aaadc
- (void)_discoveryEnsureStarted;	// IMP=0x00000001000aa784
- (id)_clinkDeviceForSFDevice:(id)arg1;	// IMP=0x00000001000aa4bc
- (void)_clinkDeviceLost:(id)arg1;	// IMP=0x00000001000aa4b0
- (void)_clinkDeviceFound:(id)arg1;	// IMP=0x00000001000aa4a4
- (void)_clinkDeviceChanged:(id)arg1;	// IMP=0x00000001000aa498
- (void)_clinkEnsureStopped;	// IMP=0x00000001000aa3e8
- (void)_clinkEnsureStarted;	// IMP=0x00000001000aa094
- (_Bool)_clinkShouldStart;	// IMP=0x00000001000aa084
- (void)_commonScreenStateChanged;	// IMP=0x00000001000a9fc0
- (void)_commonEnsureStopped;	// IMP=0x00000001000a9eb4
- (void)_commonEnsureStarted;	// IMP=0x00000001000a9c50
- (void)_update;	// IMP=0x00000001000a99e4
- (void)prefsChanged;	// IMP=0x00000001000a97cc
- (void)_invalidate;	// IMP=0x00000001000a9724
- (void)invalidate;	// IMP=0x00000001000a96b4
- (void)activate;	// IMP=0x00000001000a95dc
- (id)description;	// IMP=0x00000001000a9494
- (id)init;	// IMP=0x00000001000a9428

@end

