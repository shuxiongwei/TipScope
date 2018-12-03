//
//  TSToastAlertView.m
//  TipScope
//
//  Created by 舒雄威 on 2018/6/13.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import "TSToastAlertView.h"
#import "Masonry.h"


@interface TSToastAlertView ()

@property (nonatomic, copy) NSString *message;

@end


@implementation TSToastAlertView

+ (void)showAlertViewWithMessage:(NSString *)message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        //先移除之前的吐司提示
        UIView *v = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
        if ([v isKindOfClass:[TSToastAlertView class]]) {
            [v removeFromSuperview];
        }
        
        TSToastAlertView *alert = [[TSToastAlertView alloc] initWithFrame:TSScreenBounds message:message];
        [[UIApplication sharedApplication].keyWindow addSubview:alert];
    });
}

- (instancetype)initWithFrame:(CGRect)frame message:(NSString *)message {
    
    if (self = [super initWithFrame:frame]) {
        _message = message;
        [self configToastAlertUI];
    }
    
    return self;
}

- (void)configToastAlertUI {
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat second = 2;
    CGFloat imgWidth = 12;
    CGFloat messageWidth = [TSHelpTool measureSingleLineStringWidthWithString:_message font:[UIFont systemFontOfSize:15]];
    CGFloat messageHeight = [TSHelpTool measureMutilineStringHeightWithString:_message font:[UIFont systemFontOfSize:15] width:messageWidth];
    
    CGFloat alertWidth = 20 + imgWidth + 10 + messageWidth + 20;
    CGFloat alertHeight = 15 + messageHeight + 15;
    if (alertWidth > TSScreenWidth / 2.0) {
        alertWidth = TSScreenWidth / 2.0;
        alertHeight = 15 + messageHeight * 2 + 15;
        second = 3;
    }
    
    CGRect rect = CGRectMake((TSScreenWidth - alertWidth) / 2.0, -alertHeight, alertWidth, alertHeight);
    
    UIView *alertView = [[UIView alloc] initWithFrame:rect];
    alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:alertView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imgView.image = [UIImage imageNamed:@"icon_common_msg_nor"];
    [alertView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertView.mas_left).offset(20);
        make.centerY.equalTo(alertView);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
    }];
    
    UILabel *titleLab = [TSUIFactory createLabelWithCenter:CGPointZero withBounds:CGRectZero withText:_message withFont:15 withTextColor:UIColorFromRGBWithAlpha(0x00102C, 1) withTextAlignment:NSTextAlignmentLeft];
    titleLab.numberOfLines = 0;
    [alertView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertView.mas_left).offset(42);
        make.right.equalTo(alertView.mas_right).offset(-20);
        make.centerY.equalTo(alertView);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionNone animations:^{
        alertView.frame = CGRectMake(rect.origin.x, 100, alertWidth, alertHeight);
        [TSUIFactory addShadowToView:alertView withOpacity:1 shadowColor:UIColorFromRGBWithAlpha(0x000000, 0.12) shadowRadius:23 andCornerRadius:3];
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self removeFromSuperview];
        });
    }];
}

- (void)tap:(UITapGestureRecognizer *)rec {
    [self removeFromSuperview];
}

@end
