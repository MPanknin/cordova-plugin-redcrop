//
//  PECropView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@protocol MsgDelegate;

@interface PECropView : UIView

@property (nonatomic, weak) id<MsgDelegate> msgDelegate;

@property (nonatomic) UIImage *image;
@property (nonatomic, readonly) UIImage *croppedImage;
@property (nonatomic, readonly) CGRect zoomedCropRect;
@property (nonatomic, readonly) CGAffineTransform rotation;
@property (nonatomic, readonly) BOOL userHasModifiedCropArea;

@property (nonatomic) BOOL keepingCropAspectRatio;
@property (nonatomic) CGFloat cropAspectRatio;

@property (nonatomic) CGFloat maximumZoomScale;

@property (nonatomic) UILabel *footerLabel;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGRect imageCropRect;

@property (nonatomic) CGFloat rotationAngle;

@property (nonatomic, weak, readonly) UIRotationGestureRecognizer *rotationGestureRecognizer;



- (void)resetCropRect;
- (void)resetCropRectAnimated:(BOOL)animated;

- (void)setRotationAngle:(CGFloat)rotationAngle snap:(BOOL)snap;

- (void)setFooterLabel:(UILabel *)footerLabel;

@end

@protocol MsgDelegate <NSObject>
@optional
- (void) msg2Client:(NSString *)str;
@end

