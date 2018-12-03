//
//  TSCameraView.m
//  TipScope
//
//  Created by 佰道聚合 on 2017/7/5.
//  Copyright © 2017年 cyd. All rights reserved.
//

#import "TSCameraView.h"
#import "TSCameraFunctionView.h"
#import <Masonry.h>

@interface TSCameraView() <MICameraFunctionViewDelegate>

@property(nonatomic, strong) TSVideoPreview *previewView;
@property (nonatomic, strong) UIView *bottomView;   // 下面的bar
@property (nonatomic, strong) UIView *focusView;    // 聚焦动画view
@property (nonatomic, strong) UIView *exposureView; // 曝光动画view
@property (nonatomic, strong) UIButton *torchBtn;   //手电筒
@property (nonatomic, strong) UIButton *photoBtn;   //照片
@property (nonatomic, strong) UIButton *videoBtn;   //视频
@property (nonatomic, strong) UIButton *coverBtn;   //封面图
@property (nonatomic, strong) UIButton *shootBtn;   //拍摄
@property (nonatomic, strong) UIButton *funcBtn;    //参数调节
@property (nonatomic, strong) UILabel *recordTitle;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger recordSecond;
@property (nonatomic, strong) TSCameraFunctionView *functionView;

@end

@implementation TSCameraView

#pragma mark - 懒加载
- (UILabel *)recordTitle {
    if (_recordTitle == nil) {
        _recordTitle = [TSUIFactory createLabelWithCenter:CGPointMake(self.width - 60, 30) withBounds:CGRectMake(0, 0, 120, 40) withText:@"00:00:00" withFont:15 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_recordTitle];
    }
    
    return _recordTitle;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 89, self.width, 89)];
    }
    return _bottomView;
}

- (UIView *)focusView {
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor blueColor].CGColor;
        _focusView.layer.borderWidth = 1.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (UIView *)exposureView {
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = [UIColor purpleColor].CGColor;
        _exposureView.layer.borderWidth = 1.0f;
        _exposureView.hidden = YES;
    }
    return _exposureView;
}

- (NSTimer *)recordTimer {
    if (!_recordTimer) {
        _recordTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(recordDurationOfVideo:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
    }
    return _recordTimer;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _type = 1;

        [self configPreviewView];
        [self configTopView];
        [self registerNotification];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void)configPreviewView {
    _previewView = [[TSVideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self addSubview:_previewView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [_previewView addGestureRecognizer:tap];
    [_previewView addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    [_previewView addSubview:self.bottomView];
    [_previewView addSubview:self.focusView];
    [_previewView addSubview:self.exposureView];
    
    //拍摄按钮
    _shootBtn = [TSUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 64, 64) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"btn_shoot_photo_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(shootPhotoOrVideo:)];
    _shootBtn.center = CGPointMake(_bottomView.centerX, 32);
    [_bottomView addSubview:_shootBtn];
    
    WSWeak(weakSelf);
    
    //视频按钮
    _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_videoBtn setTitle:@"视频" forState:UIControlStateNormal];
    [_videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_videoBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_videoBtn addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_videoBtn];
    [_videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.shootBtn.mas_left).offset(-15);
        make.centerY.equalTo(weakSelf.shootBtn.mas_centerY).offset(0);
    }];
    
    //拍照按钮
    _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoBtn setTitle:@"照片" forState:UIControlStateNormal];
    [_photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_photoBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_photoBtn addTarget:self action:@selector(clickPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
    _photoBtn.selected = YES;
    [_bottomView addSubview:_photoBtn];
    [_photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.shootBtn.mas_right).offset(15);
        make.centerY.equalTo(weakSelf.shootBtn.mas_centerY).offset(0);
    }];
    
    //功能按钮
    _funcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_funcBtn setImage:[UIImage imageNamed:@"btn_shoot_func_nor"] forState:UIControlStateNormal];
    [_funcBtn setImage:[UIImage imageNamed:@"btn_shoot_func_sel"] forState:UIControlStateSelected];
    [_funcBtn addTarget:self action:@selector(clickFunctionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_funcBtn];
    [_funcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-20);
        make.bottom.offset(-20);
    }];
    
    //预览图片按钮
    //    NSString *documentPath = [TSHelpTool getDocumentPath];
    //    NSString *imgPath = [NSString stringWithFormat:@"%@/image.png", documentPath];
    //    UIImage *img = [UIImage imageNamed:@""];
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
    //        img = [UIImage imageWithContentsOfFile:imgPath];
    //    }
    
    _coverBtn = [TSUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(20, self.bottomView.height - 60, 40, 40) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:nil highlightedImage:nil selectedImage:[UIImage imageNamed:@""] touchUpInSideTarget:self action:@selector(reviewCoverImage:)];
    _coverBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverBtn.layer.cornerRadius = 3;
    _coverBtn.layer.masksToBounds = YES;
    [_bottomView addSubview:_coverBtn];
}

- (void)configTopView {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 60)];
    imgView.image = [UIImage imageNamed:@"img_shoot_topMask"];
    [self addSubview:imgView];
    
    //手电筒
    _torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_torchBtn setImage:[UIImage imageNamed:@"btn_shoot_flash_nor"] forState:UIControlStateNormal];
    [_torchBtn setImage:[UIImage imageNamed:@"btn_shoot_flash_sel"] forState:UIControlStateSelected];
    [_torchBtn addTarget:self action:@selector(torchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_torchBtn];
    [_torchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.top.offset(15);
    }];
    
    //app名称
    UILabel *appLab = [TSUIFactory createLabelWithCenter:CGPointMake(self.centerX, 30) withBounds:CGRectMake(0, 0, self.width, 40) withText:@"TipScope" withFont:20 withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentCenter];
    appLab.font = [UIFont captionFontWithName:@"custom" size:20];
    [self addSubview:appLab];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)appDidEnterBackground {
    _torchBtn.selected = NO;
}

#pragma mark - 事件响应
//聚焦
- (void)tapAction:(UIGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(focusAction:point:succ:fail:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.focusView point:point];
        [_delegate focusAction:self point:[self.previewView captureDevicePointForPoint:point] succ:nil fail:^(NSError *error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//曝光
- (void)doubleTapAction:(UIGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(exposAction:point:succ:fail:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.exposureView point:point];
        [_delegate exposAction:self point:[self.previewView captureDevicePointForPoint:point] succ:nil fail:^(NSError *error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//录制视频
- (void)recordVideo:(UIButton *)btn {
    _recordTitle.text = @"00:00:00";
    btn.selected = !btn.selected;
    if (btn.selected) {
        _recordSecond = 0;
        [self.recordTimer fire];
        _coverBtn.hidden = YES;
        _torchBtn.hidden = YES;
        
        if ([_delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
            [_delegate startRecordVideoAction:self];
        }
    } else {
        [_recordTimer invalidate];
        _recordTimer = nil;
        _coverBtn.hidden = NO;
        _torchBtn.hidden = NO;
        
        if ([_delegate respondsToSelector:@selector(stopRecordVideoAction:)]) {
            [_delegate stopRecordVideoAction:self];
        }
    }
}

//拍照
- (void)takePhoto:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(takePhotoAction:)]) {
        [_delegate takePhotoAction:self];
    }
}

//手电筒
- (void)torchClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(torchLightAction:succ:fail:)]) {
        [_delegate torchLightAction:self succ:^{
            self->_torchBtn.selected = !self->_torchBtn.selected;
        } fail:^(NSError *error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//功能按钮
- (void)clickFunctionBtn:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        if (!_functionView) {
            _functionView = [[TSCameraFunctionView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 180) delegate:self];
            [self addSubview:_functionView];
            [_functionView showOrHide:TSTitleFrame];
            [self changePreviewViewFrame:TSTitleFrame];
            
            WSWeak(weakSelf);
            _functionView.changeTorchFactor = ^(CGFloat factor) {
                if (factor < 0.01) {
                    weakSelf.torchBtn.selected = NO;
                } else {
                    weakSelf.torchBtn.selected = YES;
                }
                
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceForchFactor:focusFactor:)]) {
                    [weakSelf.delegate setDeviceForchFactor:weakSelf focusFactor:factor];
                }
            };
            
            _functionView.changeFocalFactor = ^(CGFloat factor) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceZoomFactor:zoomFactor:)]) {
                    [weakSelf.delegate setDeviceZoomFactor:weakSelf zoomFactor:factor];
                }
            };
            
            _functionView.changeFocusFactor = ^(CGFloat factor) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceFocusFactor:focusFactor:)]) {
                    [weakSelf.delegate setDeviceFocusFactor:weakSelf focusFactor:factor];
                }
            };
            
            _functionView.changeExposureDurationAndIsoFactor = ^(CGFloat duration, CGFloat iso) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceExposureDurationAndIsoFactor:durationFactor:isoFactor:)]) {
                    [weakSelf.delegate setDeviceExposureDurationAndIsoFactor:weakSelf durationFactor:duration isoFactor:iso];
                }
            };
            
            _functionView.changeExposureBiasFactor = ^(CGFloat factor) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceExposureBiasFactor:biasFactor:)]) {
                    [weakSelf.delegate setDeviceExposureBiasFactor:weakSelf biasFactor:factor];
                }
            };
            
            _functionView.changeBalanceFactor = ^(CGFloat red, CGFloat green, CGFloat blue) {
                if ([weakSelf.delegate respondsToSelector:@selector(setDeviceBalanceFactor:redFactor:greenFactor:blueFactor:)]) {
                    [weakSelf.delegate setDeviceBalanceFactor:weakSelf redFactor:red greenFactor:green blueFactor:blue];
                }
            };
        } else {
            _functionView.hidden = NO;
        }
    } else {
        _functionView.hidden = YES;
    }
}

//预览图片
- (void)reviewCoverImage:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(reviewCoverImageOrVideo:resourceType:)]) {
        
    }
}

//对焦
- (void)changeFocus:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(setDeviceFocusFactor:focusFactor:)]) {
        [self.delegate setDeviceFocusFactor:self focusFactor:slider.value];
    }
}

//点击图片按钮
- (void)clickPhotoBtn:(UIButton *)sender {
    if (!sender.selected) {
        _recordTitle.hidden = YES;
        _photoBtn.selected = YES;
        _videoBtn.selected = NO;
        [_shootBtn setImage:[UIImage imageNamed:@"btn_shoot_photo_nor"] forState:UIControlStateNormal];
    }
}

//点击视频按钮
- (void)clickVideoBtn:(UIButton *)sender {
    if (!sender.selected) {
        self.recordTitle.hidden = NO;
        _photoBtn.selected = NO;
        _videoBtn.selected = YES;
        [_shootBtn setImage:[UIImage imageNamed:@"btn_shoot_video_nor"] forState:UIControlStateNormal];
    }
}

//拍摄图片或视频
- (void)shootPhotoOrVideo:(UIButton *)sender {
    if (_photoBtn.selected) {
        if ([_delegate respondsToSelector:@selector(takePhotoAction:)]) {
            [_delegate takePhotoAction:self];
        }
    } else {
        _recordTitle.text = @"00:00:00";
        sender.selected = !sender.selected;
        if (sender.selected) {
            _recordSecond = 0;
            [self.recordTimer fire];
            _coverBtn.hidden = YES;
            _torchBtn.hidden = YES;
            _videoBtn.hidden = YES;
            _photoBtn.hidden = YES;
            _funcBtn.hidden = YES;
            
            if ([_delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
                [_delegate startRecordVideoAction:self];
            }
        } else {
            [_recordTimer invalidate];
            _recordTimer = nil;
            _coverBtn.hidden = NO;
            _torchBtn.hidden = NO;
            _videoBtn.hidden = NO;
            _photoBtn.hidden = NO;
            _funcBtn.hidden = YES;
            
            if ([_delegate respondsToSelector:@selector(stopRecordVideoAction:)]) {
                [_delegate stopRecordVideoAction:self];
            }
        }
    }
}

#pragma mark - Private methods
//聚焦、曝光动画
- (void)runFocusAnimation:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

//自动聚焦、曝光动画
- (void)runResetAnimation {
    self.focusView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);
    self.exposureView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);;
    self.exposureView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusView.hidden = NO;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.focusView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        self.exposureView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.focusView.hidden = YES;
            self.exposureView.hidden = YES;
            self.focusView.transform = CGAffineTransformIdentity;
            self.exposureView.transform = CGAffineTransformIdentity;
        });
    }];
}

- (void)recordDurationOfVideo:(NSTimer *)sender {
    _recordSecond ++;
    NSInteger h = _recordSecond / 600;
    NSInteger m = (_recordSecond % 600) / 10;
    NSInteger s = (_recordSecond % 600) % 10;
    NSString *hString = h > 9?[NSString stringWithFormat:@"%ld",(long)h]:[NSString stringWithFormat:@"0%ld",(long)h];
    NSString *mString = m > 9?[NSString stringWithFormat:@"%ld",(long)m]:[NSString stringWithFormat:@"0%ld",(long)m];
    NSString *sString = s > 9?[NSString stringWithFormat:@"%ld",(long)s]:[NSString stringWithFormat:@"0%ld",(long)s];
    _recordTitle.text = [NSString stringWithFormat:@"%@:%@:%@",hString,mString,sString];
}

- (void)changePreviewViewFrame:(TSFrameType)type {
    if (type == TSNoneFrame) {
        [UIView animateWithDuration:0.3 animations:^{
            _previewView.frame = self.frame;
        }];
    } else if (type == TSTitleFrame) {
        [UIView animateWithDuration:0.3 animations:^{
            _previewView.frame = CGRectMake(30, 0, self.width - 60, self.height - 50);
        }];
    }
}

#pragma mark - public methods
- (void)changeTorch:(BOOL)on {
    _torchBtn.selected = on;
}

- (void)refreshCoverImage:(UIImage *)image {
    [_coverBtn setImage:image forState:UIControlStateNormal];
}

#pragma mark - invalidate methods
//取消
- (void)cancel:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(cancelAction:)]) {
        [_delegate cancelAction:self];
    }
}

//转换前后摄像头
- (void)switchCameraClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(swicthCameraAction:succ:fail:)]) {
        [_delegate swicthCameraAction:self succ:nil fail:^(NSError *error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//闪光灯
- (void)flashClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(flashLightAction:succ:fail:)]) {
        [_delegate flashLightAction:self succ:^{
            //self->_flashBtn.selected = !self->_flashBtn.selected;
            self->_torchBtn.selected = NO;
        } fail:^(NSError *error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

//自动聚焦和曝光
- (void)focusAndExposureClick:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(autoFocusAndExposureAction:succ:fail:)]) {
        [_delegate autoFocusAndExposureAction:self succ:^{
            [TSToastAlertView showAlertViewWithMessage:@"自动聚焦曝光设置成功"];
        } fail:^(NSError *error) {
            [TSToastAlertView showAlertViewWithMessage:error.localizedDescription];
        }];
    }
}

- (void)resetCoverBtnImage {
    NSString *documentPath = [TSHelpTool getDocumentPath];
    
    UIImage *img = [UIImage imageNamed:@""];
    if (_type == 0) {
        NSString *imgPath = [NSString stringWithFormat:@"%@/image.png", documentPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
            img = [UIImage imageWithContentsOfFile:imgPath];
        }
    } else {
        NSString *videoPath = [NSString stringWithFormat:@"%@/video.mov", documentPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
            img = [TSHelpTool fetchThumbnailWithAVAsset:asset curTime:0];
        }
    }
    
    [_coverBtn setImage:img forState:UIControlStateNormal];
}

#pragma mark - TSCameraFunctionViewDelegate
- (CGPoint)getDeviceMinAndMaxExposureDurationFactor:(TSCameraFunctionView *)func {
    return [self.delegate getDeviceMinAndMaxExposureDurationFactor:self];
}

- (CGPoint)getDeviceMinAndMaxExposureIsoFactor:(TSCameraFunctionView *)func {
    return [self.delegate getDeviceMinAndMaxExposureIsoFactor:self];
}

- (CGPoint)getDeviceMinAndMaxExposureBiasFactor:(TSCameraFunctionView *)func {
    return [self.delegate getDeviceMinAndMaxExposureBiasFactor:self];
}

- (CGFloat)getDeviceMaxBalanceFactor:(TSCameraFunctionView *)func {
    return [self.delegate getDeviceMaxBalanceFactor:self];
}

@end
