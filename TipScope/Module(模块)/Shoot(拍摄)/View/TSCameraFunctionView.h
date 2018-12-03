//
//  TSCameraFunctionView.h
//  TipScope
//
//  Created by 舒雄威 on 2018/8/30.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TSFrameType) {
    TSNoneFrame,        //隐藏
    TSTitleFrame,       //只显示标题
    TSSingleFrame,      //显示标题和单个滑块
    TSMultipleFrame     //显示标题和多个滑块
};


@class TSCameraFunctionView;
@protocol MICameraFunctionViewDelegate <NSObject>
@optional;

/**
 获取曝光的最小和最大时长
 
 @param func 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(TSCameraFunctionView *)func;

/**
 获取曝光的最小和最大ISO参数
 
 @param func 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(TSCameraFunctionView *)func;

/**
 获取曝光的最小和最大倾斜

 @param func 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(TSCameraFunctionView *)func;

/**
 获取最大的白平衡增益
 
 @param func 自身
 @return 返回值
 */
- (CGFloat)getDeviceMaxBalanceFactor:(TSCameraFunctionView *)func;

@end


@interface TSCameraFunctionView : UIView

@property (nonatomic, copy) void (^changeTorchFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeFocalFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeFocusFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeExposureDurationAndIsoFactor)(CGFloat duration, CGFloat iso);
@property (nonatomic, copy) void (^changeExposureBiasFactor)(CGFloat factor);
@property (nonatomic, copy) void (^changeBalanceFactor)(CGFloat red, CGFloat green, CGFloat blue);

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;
- (void)showOrHide:(TSFrameType)type;

@end
