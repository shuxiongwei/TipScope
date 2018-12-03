//
//  TSMotionManager.h
//  TipScope
//
//  Created by wsk on 16/8/29.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TSMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@end
