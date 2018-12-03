//
//  TSShootViewController.m
//  TipScope
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "TSShootViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>
#import "TSCameraView.h"
#import "TSMotionManager.h"

@interface TSShootViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, TSCameraViewDelegate>

{
    AVCaptureSession          *_session; // 会话
    AVCaptureDeviceInput      *_deviceInput; // 输入
    // 输出
    AVCaptureConnection       *_videoConnection;
    AVCaptureConnection       *_audioConnection;
    AVCaptureVideoDataOutput  *_videoOutput;
    AVCaptureStillImageOutput *_imageOutput;
    
    // 视频
    NSURL                     *_movieURL;
    AVAssetWriter             *_movieWriter;
    AVAssetWriterInput          *_movieAudioInput;
    AVAssetWriterInput        *_movieVideoInput;
    
    BOOL                       _readyToRecordVideo;
    BOOL                       _readyToRecordAudio;
    BOOL                       _recording;
    dispatch_queue_t           _movieWritingQueue;
}

@property(nonatomic, strong) TSCameraView *cameraView;
@property(nonatomic, strong) TSMotionManager *motionManager;
@property(nonatomic, strong) AVCaptureDevice *activeCamera; //当前输入设备
//不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;
@property(nonatomic, assign) AVCaptureVideoOrientation referenceOrientation; //视频播放方向

@end


@implementation TSShootViewController

#pragma mark - 生命周期
- (instancetype)init {
    if (self = [super init]) {
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentPath, @"movie.mov"]];
        _motionManager = [[TSMotionManager alloc] init];
        _referenceOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.cameraView = [[TSCameraView alloc] initWithFrame:self.view.bounds];
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    
    NSError *error;
    [self setupSession:&error];
    if (!error) {
        [self.cameraView.previewView setCaptureSessionsion:_session];
        [self startCaptureSession];
    } else {
        [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
    }
}

#pragma mark - 相机配置
//会话
- (void)setupSession:(NSError **)error {
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

//输入
- (void)setupSessionInputs:(NSError **)error {
    //视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
    
    //音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
    if ([_session canAddInput:audioIn]){
        [_session addInput:audioIn];
    }
}

//输出
- (void)setupSessionOutputs:(NSError **)error {
    dispatch_queue_t captureQueue = dispatch_queue_create("com.cc.captureQueue", DISPATCH_QUEUE_SERIAL);
    
    //视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOut]) {
        [_session addOutput:videoOut];
    }
    _videoOutput = videoOut;
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    //音频输出
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:audioOut]) {
        [_session addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    //静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
}

//音频源数据写入配置
- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    NSData *currentChannelLayoutData = aclSize > 0 ? [NSData dataWithBytes:currentChannelLayout length:aclSize] : [NSData data];
    NSDictionary *audioCompressionSettings = @{AVFormatIDKey: [NSNumber numberWithInteger: kAudioFormatMPEG4AAC],
                                               AVSampleRateKey: [NSNumber numberWithFloat: currentASBD->mSampleRate],
                                               AVChannelLayoutKey: currentChannelLayoutData,
                                               AVNumberOfChannelsKey: [NSNumber numberWithInteger: currentASBD->mChannelsPerFrame],
                                               AVEncoderBitRatePerChannelKey: [NSNumber numberWithInt: 64000]};
    
    if ([_movieWriter canApplyOutputSettings:audioCompressionSettings forMediaType: AVMediaTypeAudio]) {
        _movieAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings:audioCompressionSettings];
        _movieAudioInput.expectsMediaDataInRealTime = YES;
        if ([_movieWriter canAddInput:_movieAudioInput]) {
            [_movieWriter addInput:_movieAudioInput];
        } else {
            [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
            return NO;
        }
    } else {
        [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
        return NO;
    }
    return YES;
}

//视频源数据写入配置
- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    CGFloat bitsPerPixel = numPixels < (640 * 480) ? 4.05 : 11.0;
    NSDictionary *compression = @{AVVideoAverageBitRateKey: [NSNumber numberWithInteger: numPixels * bitsPerPixel],
                                  AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInteger:30]};
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                               AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
                                               AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
                                               AVVideoCompressionPropertiesKey: compression};
    
    if ([_movieWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        _movieVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        _movieVideoInput.expectsMediaDataInRealTime = YES;
        _movieVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_movieWriter canAddInput:_movieVideoInput]) {
            [_movieWriter addInput:_movieVideoInput];
        } else {
            [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
            return NO;
        }
    } else {
        [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
        return NO;
    }
    return YES;
}

#pragma mark - 会话控制
//开启捕捉
- (void)startCaptureSession {
    if (!_movieWritingQueue) {
        _movieWritingQueue = dispatch_queue_create("Movie.Writing.Queue", DISPATCH_QUEUE_SERIAL);
    }
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

//停止捕捉
- (void)stopCaptureSession {
    if (_session.isRunning) {
        [_session stopRunning];
    }
}

#pragma mark - 拍摄照片
- (void)takePictureImage {
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
            return;
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *documentPath = [TSHelpTool getDocumentPath];
        NSString *imgPath = [NSString stringWithFormat:@"%@/image.png", documentPath];
        if ([manager fileExistsAtPath:imgPath]) {
            [manager removeItemAtPath:imgPath error:nil];
        }
        [imageData writeToFile:imgPath atomically:YES];
        
        [self->_cameraView resetCoverBtnImage];
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    }];
}

#pragma mark - 录制视频
//开始录制
- (void)startRecording {
    [self removeFile:_movieURL];
    dispatch_async(_movieWritingQueue, ^{
        if (!self->_movieWriter) {
            NSError *error;
            self->_movieWriter = [[AVAssetWriter alloc] initWithURL:self->_movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
            !error?:[TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }
        self->_recording = YES;
    });
}

//停止录制
- (void)stopRecording {
    _recording = NO;
    _readyToRecordVideo = NO;
    _readyToRecordAudio = NO;
    
    dispatch_async(_movieWritingQueue, ^{
        [self->_movieWriter finishWritingWithCompletionHandler:^() {
            if (self->_movieWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self saveMovieToCameraRoll];
                });
            } else {
                [TSToastAlertView showAlertViewWithMessage:self->_movieWriter.error.localizedDescription];
            }
            self->_movieWriter = nil;
        }];
    });
}

// 保存视频
- (void)saveMovieToCameraRoll {
    if (TSIOS9) {
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) return;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                if (@available(iOS 9.0, *)) {
                    PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:self->_movieURL options:nil];
                } else {
                    // Fallback on earlier versions
                }
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                success?:[TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc]init];
        [lab writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
            !error?:[TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentPath = [TSHelpTool getDocumentPath];
    NSString *videoPath = [NSString stringWithFormat:@"%@/video.mov", documentPath];
    if ([manager fileExistsAtPath:videoPath]) {
        [manager removeItemAtPath:videoPath error:nil];
    }
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"movie.mov"];
    [manager copyItemAtPath:tempPath toPath:videoPath error:nil];

    [_cameraView resetCoverBtnImage];
}

#pragma mark - 输出代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_recording && _movieWriter) {
        CFRetain(sampleBuffer);
        dispatch_async(_movieWritingQueue, ^{
            if (connection == self->_videoConnection) {
                if (!self->_readyToRecordVideo) {
                    self->_readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                }
                if ([self inputsReadyToRecord]) {
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
            } else if (connection == self->_audioConnection) {
                if (!self->_readyToRecordAudio) {
                    self->_readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                }
                if ([self inputsReadyToRecord]) {
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
                }
            }
            CFRelease(sampleBuffer);
        });
    }
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType {
    if (_movieWriter.status == AVAssetWriterStatusUnknown) {
        if ([_movieWriter startWriting]) {
            [_movieWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
        }
    }
    if (_movieWriter.status == AVAssetWriterStatusWriting) {
        if (mediaType == AVMediaTypeVideo) {
            if (!_movieVideoInput.readyForMoreMediaData) {
                return;
            }
            if (![_movieVideoInput appendSampleBuffer:sampleBuffer]) {
                [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
            }
        } else if (mediaType == AVMediaTypeAudio) {
            if (!_movieAudioInput.readyForMoreMediaData) {
                return;
            }
            if (![_movieAudioInput appendSampleBuffer:sampleBuffer]) {
                [TSToastAlertView showAlertViewWithMessage:_movieWriter.error.localizedDescription];
            }
        }
    }
}

- (BOOL)inputsReadyToRecord {
    return _readyToRecordVideo && _readyToRecordAudio;
}

#pragma mark - 输入设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - MICameraViewDelegate
//聚焦
- (void)focusAction:(TSCameraView *)cameraView point:(CGPoint)point succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    id error = [self focusAtPoint:point];
    error?!fail?:fail(error):!succ?:succ();
}

//曝光
- (void)exposAction:(TSCameraView *)cameraView point:(CGPoint)point succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    id error = [self exposeAtPoint:point];
    error?!fail?:fail(error):!succ?:succ();
}

//自动聚焦、曝光
- (void)autoFocusAndExposureAction:(TSCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    id error = [self resetFocusAndExposureModes];
    error?!fail?:fail(error):!succ?:succ();
}

//转换摄像头
- (void)swicthCameraAction:(TSCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    id error = [self switchCameras];
    error?!fail?:fail(error):!succ?:succ();
}

//闪光灯
-(void)flashLightAction:(TSCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    id error = [self changeFlash:[self flashMode] == AVCaptureFlashModeOn?AVCaptureFlashModeOff:AVCaptureFlashModeOn];
    error?!fail?:fail(error):!succ?:succ();
}

//手电筒
- (void)torchLightAction:(TSCameraView *)cameraView succ:(void (^)(void))succ fail:(void (^)(NSError *))fail {
    id error = [self changeTorch:[self torchMode] == AVCaptureTorchModeOn?AVCaptureTorchModeOff:AVCaptureTorchModeOn];
    error?!fail?:fail(error):!succ?:succ();
}

//取消拍照
- (void)cancelAction:(TSCameraView *)cameraView {
    [self.navigationController popViewControllerAnimated:YES];
}

//转换类型
- (void)didChangeTypeAction:(TSCameraView *)cameraView type:(NSInteger)type {
    
}

//拍照
- (void)takePhotoAction:(TSCameraView *)cameraView {
    [self takePictureImage];
}

//开始录像
- (void)startRecordVideoAction:(TSCameraView *)cameraView {
    [self startRecording];
}

//停止录像
- (void)stopRecordVideoAction:(TSCameraView *)cameraView {
    [self stopRecording];
}

//预览图片或视频
- (void)reviewCoverImageOrVideo:(TSCameraView *)cameraView resourceType:(NSInteger)type {

    //跳转系统相册(私有API)
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"photos-redirect://"]];
    
    if (type == 0) {
        
    } else {
       
    }
}

- (void)setDeviceZoomFactor:(TSCameraView *)cameraView zoomFactor:(CGFloat)factor {
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    device.videoZoomFactor = factor;
    [device unlockForConfiguration];
}

- (void)setDeviceFocusFactor:(TSCameraView *)cameraView focusFactor:(CGFloat)factor {
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    [device setFocusModeLockedWithLensPosition:factor completionHandler:nil];
    [device unlockForConfiguration];
}

- (void)setDeviceForchFactor:(TSCameraView *)cameraView focusFactor:(CGFloat)factor {
    if (factor < 0.01) {
        [self changeTorch:AVCaptureTorchModeOff];
        return;
    }

    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    [device setTorchModeOnWithLevel:factor error:nil];
    [device unlockForConfiguration];
}

- (void)setDeviceExposureDurationAndIsoFactor:(TSCameraView *)cameraView durationFactor:(CGFloat)duration isoFactor:(CGFloat)iso {
    AVCaptureDevice *device = [self activeCamera];
    CMTime time = CMTimeMake(duration, device.activeFormat.maxExposureDuration.timescale);
    
    [device lockForConfiguration:nil];
    [device setExposureModeCustomWithDuration:time ISO:AVCaptureISOCurrent completionHandler:nil];
    
    [device unlockForConfiguration];
}

- (void)setDeviceExposureBiasFactor:(TSCameraView *)cameraView biasFactor:(CGFloat)factor {
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    [device setExposureTargetBias:factor completionHandler:nil];
    [device unlockForConfiguration];
}

- (void)setDeviceBalanceFactor:(TSCameraView *)cameraView redFactor:(CGFloat)red greenFactor:(CGFloat)green blueFactor:(CGFloat)blue {
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    AVCaptureWhiteBalanceGains gins = {red, green, blue};
    [device setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:gins completionHandler:nil];
    [device unlockForConfiguration];
}

- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(TSCameraView *)cameraView {
    AVCaptureDevice *device = [self activeCamera];
    return CGPointMake(device.activeFormat.minExposureDuration.value, device.activeFormat.maxExposureDuration.value);
}

- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(TSCameraView *)func {
    AVCaptureDevice *device = [self activeCamera];
    return CGPointMake(device.activeFormat.minISO, device.activeFormat.maxISO);
}

- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(TSCameraView *)cameraView {
    AVCaptureDevice *device = [self activeCamera];
    return CGPointMake(device.minExposureTargetBias, device.maxExposureTargetBias);
}

- (CGFloat)getDeviceMaxBalanceFactor:(TSCameraView *)cameraView {
    AVCaptureDevice *device = [self activeCamera];
    return device.maxWhiteBalanceGain;
}

#pragma mark - 转换摄像头
- (id)switchCameras {
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        AVCaptureFlashMode flashMode = [self flashMode];
        
        //转换摄像头
        [_session beginConfiguration];
        [_session removeInput:_deviceInput];
        if ([_session canAddInput:videoInput]) {
            CATransition *animation = [CATransition animation];
            animation.type = @"oglFlip";
            animation.subtype = kCATransitionFromLeft;
            animation.duration = 0.5;
            [self.cameraView.previewView.layer addAnimation:animation forKey:@"flip"];
            [_session addInput:videoInput];
            _deviceInput = videoInput;
        } else {
            [_session addInput:_deviceInput];
        }
        [_session commitConfiguration];
        
        // 完成后需要重新设置视频输出链接
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // 如果后置转前置，系统会自动关闭手电筒，如果之前打开的，需要更新UI
        if (videoDevice.position == AVCaptureDevicePositionFront) {
            [self.cameraView changeTorch:NO];
        }
        
        // 前后摄像头的闪光灯不是同步的，所以在转换摄像头后需要重新设置闪光灯
        [self changeFlash:flashMode];
        
        return nil;
    }
    return error;
}

#pragma mark - 聚焦
- (id)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    BOOL supported = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus];
    if (supported){
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"设备不支持聚焦" code:407];
}

#pragma mark - 曝光
static const NSString *CameraAdjustingExposureContext;
- (id)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"设备不支持曝光" code:405];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &CameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 自动聚焦、曝光
- (id)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    }
    return error;
}

#pragma mark - 闪光灯
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

- (id)changeFlash:(AVCaptureFlashMode)flashMode {
    if (![self cameraHasFlash]) {
        return [self errorWithMessage:@"不支持闪光灯" code:401];
    }
    // 如果手电筒打开，先关闭手电筒
    if ([self torchMode] == AVCaptureTorchModeOn) {
        [self setTorchMode:AVCaptureTorchModeOff];
    }
    return [self setFlashMode:flashMode];
}

- (id)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"不支持闪光灯" code:401];
}

#pragma mark - 手电筒
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (id)changeTorch:(AVCaptureTorchMode)torchMode {
    if (![self cameraHasTorch]) {
        return [self errorWithMessage:@"不支持手电筒" code:403];
    }
    // 如果闪光灯打开，先关闭闪光灯
    if ([self flashMode] == AVCaptureFlashModeOn) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    return [self setTorchMode:torchMode];
}

- (id)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"不支持手电筒" code:403];
}

#pragma mark - Private methods
- (NSError *)errorWithMessage:(NSString *)text code:(NSInteger)code {
    NSDictionary *desc = @{NSLocalizedDescriptionKey: text};
    NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:code userInfo:desc];
    return error;
}

// 获取视频旋转矩阵
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.motionManager.videoOrientation];
    CGFloat angleOffset;
    if ([self activeCamera].position == AVCaptureDevicePositionBack) {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    } else {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

// 获取视频旋转角度
- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

// 当前设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

// 移除文件
- (void)removeFile:(NSURL *)fileURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        } else {
            NSLog(@"删除视频文件成功");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
