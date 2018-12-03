//
//  TSVideoPreview.h
//  TipScope
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TSVideoPreview : UIView

@property (strong, nonatomic) AVCaptureSession *captureSessionsion;

/**
 对焦或曝光

 @param point 焦点
 @return 返回值
 */
- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

@end
