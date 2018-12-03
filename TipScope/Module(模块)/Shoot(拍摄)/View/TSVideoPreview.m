//
//  TSVideoPreview.m
//  TipScope
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "TSVideoPreview.h"

@implementation TSVideoPreview

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    
    return self;
}

- (AVCaptureSession*)captureSessionsion {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setCaptureSessionsion:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

@end
