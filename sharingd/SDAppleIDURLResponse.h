//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class NSDictionary;

__attribute__((visibility("hidden")))
@interface SDAppleIDURLResponse : NSObject
{
    NSDictionary *_responseInfo;	// 8 = 0x8
    long long _statusCode;	// 16 = 0x10
}

@property(readonly, nonatomic) long long statusCode; // @synthesize statusCode=_statusCode;
@property(readonly, nonatomic) NSDictionary *responseInfo; // @synthesize responseInfo=_responseInfo;
- (void).cxx_destruct;	// IMP=0x00000001001bc450
- (id)initWithHTTPUTLResponse:(id)arg1 data:(id)arg2;	// IMP=0x00000001001bc1dc

@end

