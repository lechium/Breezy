//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

#import "SDNodeBrowserDelegate-Protocol.h"

@class NSNumber, NSString;
@protocol OS_os_transaction, OS_xpc_object, SDNetworkBrowserDelegate;

__attribute__((visibility("hidden")))
@interface SDNetworkBrowser : NSObject <SDNodeBrowserDelegate>
{
    struct __SFNode *_rootNode;	// 8 = 0x8
    long long _mode;	// 16 = 0x10
    struct __CFDictionary *_nodeBrowsers;	// 24 = 0x18
    NSObject<OS_os_transaction> *_transaction;	// 32 = 0x20
    NSString *_kind;	// 40 = 0x28
    NSString *_objectKey;	// 48 = 0x30
    NSObject<OS_xpc_object> *_boostMessage;	// 56 = 0x38
    id <SDNetworkBrowserDelegate> _delegate;	// 64 = 0x40
    NSObject<OS_xpc_object> *_connection;	// 72 = 0x48
    NSNumber *_isEntitled;	// 80 = 0x50
}

@property(retain) NSNumber *isEntitled; // @synthesize isEntitled=_isEntitled;
@property(retain) NSObject<OS_xpc_object> *connection; // @synthesize connection=_connection;
@property __weak id <SDNetworkBrowserDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain) NSObject<OS_xpc_object> *boostMessage; // @synthesize boostMessage=_boostMessage;
@property(copy) NSString *objectKey; // @synthesize objectKey=_objectKey;
@property(readonly, copy) NSString *kind; // @synthesize kind=_kind;
- (void).cxx_destruct;	// IMP=0x0000000100092304
- (void)invalidate;	// IMP=0x00000001000920f0
- (int)closeNode:(struct __SFNode *)arg1;	// IMP=0x0000000100092054
- (int)removeNode:(struct __SFNode *)arg1;	// IMP=0x0000000100091fdc
- (int)addNode:(struct __SFNode *)arg1;	// IMP=0x0000000100091f64
@property long long mode;
- (id)sidebarChildren;	// IMP=0x0000000100091e6c
- (id)childrenForNode:(struct __SFNode *)arg1;	// IMP=0x0000000100091de0
- (struct __SFNode *)copyRootNode;	// IMP=0x0000000100091dbc
- (int)openNode:(struct __SFNode *)arg1 forProtocol:(id)arg2 flags:(unsigned long long)arg3;	// IMP=0x0000000100091c74
- (void)nodeBrowser:(id)arg1 nodesChangedForParent:(struct __SFNode *)arg2 protocol:(id)arg3 error:(int)arg4;	// IMP=0x0000000100091bf4
- (void)dealloc;	// IMP=0x0000000100091b80
- (id)initWithKind:(id)arg1 rootNode:(struct __SFNode *)arg2;	// IMP=0x0000000100091a68

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
