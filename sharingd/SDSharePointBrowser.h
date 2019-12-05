//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

#import "SDBonjourResolverDelegate-Protocol.h"
#import "SDRemoteDiscDelegate-Protocol.h"

@class NSArray, NSDictionary, NSMutableDictionary, NSMutableSet, NSNumber, NSString, NSTimer, NSURL, SDBonjourResolver, SDRemoteDisc, SDStatusMonitor;
@protocol SDSharePointBrowserDelegate;

__attribute__((visibility("hidden")))
@interface SDSharePointBrowser : NSObject <SDBonjourResolverDelegate, SDRemoteDiscDelegate>
{
    void *_session;	// 8 = 0x8
    _Bool _askFirst;	// 16 = 0x10
    _Bool _passwordOnly;	// 17 = 0x11
    _Bool _sharesMounted;	// 18 = 0x12
    _Bool _resolveService;	// 19 = 0x13
    NSNumber *_diskFlags;	// 24 = 0x18
    NSString *_authType;	// 32 = 0x20
    NSString *_askToken;	// 40 = 0x28
    NSString *_askStatus;	// 48 = 0x30
    NSString *_askDevice;	// 56 = 0x38
    NSString *_browserID;	// 64 = 0x40
    NSString *_serverName;	// 72 = 0x48
    NSString *_changeCount;	// 80 = 0x50
    NSString *_neighborhood;	// 88 = 0x58
    NSTimer *_destroyTimer;	// 96 = 0x60
    int _error;	// 104 = 0x68
    unsigned long long _flags;	// 112 = 0x70
    SDRemoteDisc *_remoteDisc;	// 120 = 0x78
    SDStatusMonitor *_monitor;	// 128 = 0x80
    SDBonjourResolver *_resolver;	// 136 = 0x88
    NSDictionary *_sharePoints;	// 144 = 0x90
    NSDictionary *_fileShares;	// 152 = 0x98
    NSDictionary *_printerShares;	// 160 = 0xa0
    NSMutableSet *_mountedVolumes;	// 168 = 0xa8
    NSMutableDictionary *_queries;	// 176 = 0xb0
    _Bool _shouldNotify;	// 184 = 0xb8
    int _connectionState;	// 188 = 0xbc
    NSURL *_serverURL;	// 192 = 0xc0
    NSArray *_protocols;	// 200 = 0xc8
    NSString *_userName;	// 208 = 0xd0
    NSString *_hostName;	// 216 = 0xd8
    NSString *_protocol;	// 224 = 0xe0
    NSNumber *_portNumber;	// 232 = 0xe8
    NSString *_typeIdentifier;	// 240 = 0xf0
    struct _DNSServiceRef_t *_connection;	// 248 = 0xf8
    id <SDSharePointBrowserDelegate> _delegate;	// 256 = 0x100
}

+ (id)browserForID:(id)arg1;	// IMP=0x00000001000b5d3c
@property __weak id <SDSharePointBrowserDelegate> delegate; // @synthesize delegate=_delegate;
@property(readonly) int connectionState; // @synthesize connectionState=_connectionState;
@property(readonly) struct _DNSServiceRef_t *connection; // @synthesize connection=_connection;
@property(readonly) _Bool shouldNotify; // @synthesize shouldNotify=_shouldNotify;
@property(retain) NSString *typeIdentifier; // @synthesize typeIdentifier=_typeIdentifier;
@property(retain) NSNumber *portNumber; // @synthesize portNumber=_portNumber;
@property(retain) NSString *protocol; // @synthesize protocol=_protocol;
@property(retain) NSString *hostName; // @synthesize hostName=_hostName;
@property(retain) NSString *userName; // @synthesize userName=_userName;
@property(retain) NSArray *protocols; // @synthesize protocols=_protocols;
@property(retain) NSURL *serverURL; // @synthesize serverURL=_serverURL;
- (void).cxx_destruct;	// IMP=0x00000001000b8a60
- (void)stop;	// IMP=0x00000001000b8814
- (void)checkNetAuthSession:(id)arg1;	// IMP=0x00000001000b8738
- (void)start;	// IMP=0x00000001000b85ec
- (void)removeObservers;	// IMP=0x00000001000b859c
- (void)addObservers;	// IMP=0x00000001000b84d8
- (void)mountPointsChanged:(id)arg1;	// IMP=0x00000001000b83b0
- (void)bonjourResolverDidChange:(id)arg1;	// IMP=0x00000001000b8284
- (void)closeSession;	// IMP=0x00000001000b8058
- (void)cancelResolve;	// IMP=0x00000001000b7ff8
- (void)setError:(int)arg1 state:(int)arg2 notify:(_Bool)arg3;	// IMP=0x00000001000b7f8c
- (void)setConnectionState:(int)arg1;	// IMP=0x00000001000b7f7c
- (void)setShouldNotify:(_Bool)arg1;	// IMP=0x00000001000b7f6c
- (void)setError:(int)arg1;	// IMP=0x00000001000b7f5c
- (void)setMountInfo:(struct __CFDictionary *)arg1;	// IMP=0x00000001000b7f58
- (_Bool)singlePasswordEnabled:(id)arg1;	// IMP=0x00000001000b7f34
- (_Bool)shouldAskFirst:(id)arg1;	// IMP=0x00000001000b7f10
- (_Bool)getBooleanValue:(struct __CFDictionary *)arg1 forKey:(struct __CFString *)arg2;	// IMP=0x00000001000b7ec4
- (void)setNetbiosName:(id)arg1;	// IMP=0x00000001000b7e24
- (void)setBonjourInfo:(id)arg1 domain:(id)arg2 resolveService:(_Bool)arg3;	// IMP=0x00000001000b7d08
- (void)setSharePoints:(id)arg1;	// IMP=0x00000001000b7cf4
- (void)enumerateShares;	// IMP=0x00000001000b7cf0
- (void)setProtocolUserName;	// IMP=0x00000001000b7c18
- (void)openSession;	// IMP=0x00000001000b7a64
- (void)openNetAuthSession;	// IMP=0x00000001000b7a60
- (id)netAuthURL;	// IMP=0x00000001000b7944
- (id)netAuthProtocol;	// IMP=0x00000001000b7874
- (id)fullNameForScheme:(id)arg1 hostName:(id)arg2;	// IMP=0x00000001000b779c
- (void)stopTXTRecordMonitor:(id)arg1;	// IMP=0x00000001000b76dc
- (void)startTXTRecordMonitor:(id)arg1;	// IMP=0x00000001000b731c
- (void)remoteDiscStatusDidChange:(id)arg1;	// IMP=0x00000001000b725c
- (void)addSharePoint:(id)arg1 diskName:(struct __CFString *)arg2 diskFlags:(struct __CFNumber *)arg3 diskID:(struct __CFString *)arg4 diskType:(struct __CFString *)arg5 protocol:(struct __CFString *)arg6 mountPath:(struct __CFString *)arg7;	// IMP=0x00000001000b7150
- (id)mountedSharePointsForProtocol:(id)arg1;	// IMP=0x00000001000b6e88
- (id)sharePointsFromMountPoints:(id)arg1;	// IMP=0x00000001000b6ca8
- (void)handleTXTRecordCallBack:(unsigned int)arg1 error:(int)arg2 txtLen:(unsigned short)arg3 txtRecord:(const void *)arg4 context:(id)arg5;	// IMP=0x00000001000b6994
- (_Bool)isPartialVolumeList;	// IMP=0x00000001000b6968
- (void)buildShares:(_Bool)arg1;	// IMP=0x00000001000b67fc
- (void)addTXTRecordSharesToCache:(id)arg1 printerShares:(id)arg2;	// IMP=0x00000001000b5f44
- (void)addSharesToCache:(id)arg1 newFileShares:(id)arg2 newPrinterShares:(id)arg3;	// IMP=0x00000001000b5f40
- (_Bool)isNetAuthSupportedProtocol:(id)arg1;	// IMP=0x00000001000b5ecc
- (void)notifyClient;	// IMP=0x00000001000b5e7c
@property(readonly) void *URLMountSession;
@property(readonly) NSArray *printerNodes;
@property(readonly) NSArray *fileNodes;
- (void)dealloc;	// IMP=0x00000001000b5d50
- (id)initWithProtocol:(id)arg1 authType:(id)arg2 flags:(unsigned long long)arg3;	// IMP=0x00000001000b598c

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
