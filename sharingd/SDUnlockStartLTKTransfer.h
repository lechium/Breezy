//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Aug  6 2017 21:40:27).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <ProtocolBuffer/PBCodable.h>

#import "NSCopying-Protocol.h"

@interface SDUnlockStartLTKTransfer : PBCodable <NSCopying>
{
    unsigned int _version;	// 8 = 0x8
    CDStruct_f20694ce _has;	// 12 = 0xc
}

@property(nonatomic) unsigned int version; // @synthesize version=_version;
- (void)mergeFrom:(id)arg1;	// IMP=0x00000001000f771c
- (unsigned long long)hash;	// IMP=0x00000001000f76e0
- (_Bool)isEqual:(id)arg1;	// IMP=0x00000001000f762c
- (id)copyWithZone:(struct _NSZone *)arg1;	// IMP=0x00000001000f75b8
- (void)copyTo:(id)arg1;	// IMP=0x00000001000f7588
- (void)writeTo:(id)arg1;	// IMP=0x00000001000f7558
- (_Bool)readFrom:(id)arg1;	// IMP=0x00000001000f7550
- (id)dictionaryRepresentation;	// IMP=0x00000001000f7278
- (id)description;	// IMP=0x00000001000f71c4
@property(nonatomic) _Bool hasVersion;

@end
