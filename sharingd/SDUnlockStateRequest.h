//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <ProtocolBuffer/PBRequest.h>

#import "NSCopying-Protocol.h"

@interface SDUnlockStateRequest : PBRequest <NSCopying>
{
    unsigned int _version;	// 8 = 0x8
    CDStruct_f20694ce _has;	// 12 = 0xc
}

@property(nonatomic) unsigned int version; // @synthesize version=_version;
- (void)mergeFrom:(id)arg1;	// IMP=0x00000001001328bc
- (unsigned long long)hash;	// IMP=0x0000000100132880
- (_Bool)isEqual:(id)arg1;	// IMP=0x00000001001327cc
- (id)copyWithZone:(struct _NSZone *)arg1;	// IMP=0x0000000100132758
- (void)copyTo:(id)arg1;	// IMP=0x0000000100132728
- (void)writeTo:(id)arg1;	// IMP=0x00000001001326f8
- (_Bool)readFrom:(id)arg1;	// IMP=0x00000001001326f0
- (id)dictionaryRepresentation;	// IMP=0x0000000100132418
- (id)description;	// IMP=0x0000000100132364
@property(nonatomic) _Bool hasVersion;

@end
