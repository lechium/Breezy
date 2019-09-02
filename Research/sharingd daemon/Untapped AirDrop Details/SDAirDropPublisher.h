//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class NSMutableDictionary, NSNumber, SDStatusMonitor;
@protocol OS_dispatch_source, SDAirDropPublisherDelegate;

__attribute__((visibility("hidden")))
@interface SDAirDropPublisher : NSObject
{
    NSNumber *_port;	// 8 = 0x8
    long long _retryCount;	// 16 = 0x10
    struct __SecIdentity *_identity;	// 24 = 0x18
    struct __CFNetService *_service;	// 32 = 0x20
    SDStatusMonitor *_monitor;	// 40 = 0x28
    NSObject<OS_dispatch_source> *_restartTimer;	// 48 = 0x30
    NSMutableDictionary *_txtRecord;	// 56 = 0x38
    NSMutableDictionary *_properties;	// 64 = 0x40
    id <SDAirDropPublisherDelegate> _delegate;	// 72 = 0x48
}

@property __weak id <SDAirDropPublisherDelegate> delegate; // @synthesize delegate=_delegate;
- (void).cxx_destruct;	// IMP=0x000000010004f33c
- (void)invalidate;	// IMP=0x000000010004f2b8
- (void)stop;	// IMP=0x000000010004f178
- (void)start;	// IMP=0x000000010004f110
- (void)publish;	// IMP=0x000000010004ee14
- (void)removeObservers;	// IMP=0x000000010004edc4
- (void)addObservers;	// IMP=0x000000010004ed28
- (void)somethingChanged:(id)arg1;	// IMP=0x000000010004ed1c
- (void)updateTXTRecordAndNotify;	// IMP=0x000000010004e8d4
- (void)setMyPictureAndHash;	// IMP=0x000000010004e65c
- (void)publishCallBack:(CDStruct_87dc826d *)arg1;	// IMP=0x000000010004e398
- (void)dealloc;	// IMP=0x000000010004e338
- (id)initWithPort:(id)arg1 identity:(struct __SecIdentity *)arg2;	// IMP=0x000000010004e110

@end
