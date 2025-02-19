/*
* This header is generated by classdump-dyld 1.0
* on Sunday, July 22, 2018 at 11:13:54 PM Mountain Standard Time
* Operating System: Version 11.3 (Build 15L211)
* Image Source: /System/Library/PrivateFrameworks/TVSettingKit.framework/TVSettingKit
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/

#import "TSKPreviewingDelegate.h"


@protocol TSKPreviewing <NSObject>
@property (weak,nonatomic) id<TSKPreviewingDelegate> previewingDelegate; 
@required
//-(id<TSKPreviewingDelegate>)previewingDelegate;
-(id)defaultIndexPathForPreview;
-(id)previewForItemAtIndexPath:(id)arg1;
-(id)sourceViewForSlideTransition;
-(BOOL)hasFullscreenPreview;
//-(void)setPreviewingDelegate:(id)arg1;

@end

