//
//  TSCameraView.h
//  TipScope
//
//  Created by 佰道聚合 on 2017/7/5.
//  Copyright © 2017年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSVideoPreview.h"

@class TSCameraView;
@protocol TSCameraViewDelegate <NSObject>
@optional;

/**
 转换摄像头

 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)swicthCameraAction:(TSCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 闪光灯

 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)flashLightAction:(TSCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 补光
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)torchLightAction:(TSCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 聚焦
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)focusAction:(TSCameraView *)cameraView point:(CGPoint)point succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 曝光
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)exposAction:(TSCameraView *)cameraView point:(CGPoint)point succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 自动聚焦、曝光
 
 @param cameraView 自身
 @param succ 成功回调
 @param fail 失败回调
 */
- (void)autoFocusAndExposureAction:(TSCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;

/**
 取消
 
 @param cameraView 自身
 */
- (void)cancelAction:(TSCameraView *)cameraView;

/**
 拍照
 
 @param cameraView 自身
 */
- (void)takePhotoAction:(TSCameraView *)cameraView;

/**
 停止录视频
 
 @param cameraView 自身
 */
- (void)stopRecordVideoAction:(TSCameraView *)cameraView;

/**
 开始录视频
 
 @param cameraView 自身
 */
- (void)startRecordVideoAction:(TSCameraView *)cameraView;

/**
 改变拍摄类型
 
 @param cameraView 自身
 @param type 拍摄类型
 */
- (void)didChangeTypeAction:(TSCameraView *)cameraView type:(NSInteger)type;

/**
 预览图片或视频
 
 @param cameraView 自身
 @param type 资源类型
 */
- (void)reviewCoverImageOrVideo:(TSCameraView *)cameraView resourceType:(NSInteger)type;

/**
 设置相机的变焦参数

 @param cameraView 自身
 @param factor 变焦参数
 */
- (void)setDeviceZoomFactor:(TSCameraView *)cameraView zoomFactor:(CGFloat)factor;

/**
 设置相机的对焦参数

 @param cameraView 自身
 @param factor 对焦参数
 */
- (void)setDeviceFocusFactor:(TSCameraView *)cameraView focusFactor:(CGFloat)factor;

/**
 设置手电筒亮度参数

 @param cameraView 自身
 @param factor 亮度参数
 */
- (void)setDeviceForchFactor:(TSCameraView *)cameraView focusFactor:(CGFloat)factor;

- (void)setDeviceExposureDurationAndIsoFactor:(TSCameraView *)cameraView durationFactor:(CGFloat)duration isoFactor:(CGFloat)iso;

/**
 设置曝光倾斜

 @param cameraView 自身
 @param factor 倾斜参数
 */
- (void)setDeviceExposureBiasFactor:(TSCameraView *)cameraView biasFactor:(CGFloat)factor;

/**
 设置白平衡增益
 
 @param cameraView 自身
 @param factor 白平衡参数
 */
- (void)setDeviceBalanceFactor:(TSCameraView *)cameraView redFactor:(CGFloat)red greenFactor:(CGFloat)green blueFactor:(CGFloat)blue;

/**
 获取曝光的最小和最大时长
 
 @param cameraView 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(TSCameraView *)cameraView;

/**
 获取曝光的最小和最大ISO参数
 
 @param cameraView 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(TSCameraView *)cameraView;

/**
 获取曝光的最小和最大倾斜
 
 @param cameraView 自身
 @return 返回值
 */
- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(TSCameraView *)cameraView;

/**
 获取最大的白平衡增益
 
 @param cameraView 自身
 @return 返回值
 */
- (CGFloat)getDeviceMaxBalanceFactor:(TSCameraView *)cameraView;

@end

@interface TSCameraView : UIView

@property(nonatomic, weak) id <TSCameraViewDelegate> delegate;
@property(nonatomic, strong, readonly) TSVideoPreview *previewView;
@property(nonatomic, assign, readonly) NSInteger type; // 1：拍照 2：视频

/**
 改变手电筒

 @param on 关或开
 */
- (void)changeTorch:(BOOL)on;

/**
 刷新预览图片
 */
- (void)resetCoverBtnImage;

@end
