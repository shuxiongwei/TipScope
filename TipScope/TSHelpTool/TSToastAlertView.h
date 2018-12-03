//
//  TSToastAlertView.h
//  TipScope
//
//  Created by 舒雄威 on 2018/6/13.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import <UIKit/UIKit.h>

//吐司提示视图
@interface TSToastAlertView : UIView

/**
 显示吐司提示视图

 @param message 提示信息
 */
+ (void)showAlertViewWithMessage:(NSString *)message;

@end
