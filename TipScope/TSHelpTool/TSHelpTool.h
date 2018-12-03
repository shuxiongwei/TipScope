//
//  TSHelpTool.h
//  TipScope
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TSHelpTool : NSObject

/**
 创建时间戳

 @return 返回值
 */
+ (NSString *)timeStampSecond;

/**
 获取沙盒document路径

 @return 返回值
 */
+ (NSString *)getDocumentPath;

/**
 根据文件名创建文件夹

 @param component 文件名
 @return 返回值
 */
+ (NSString *)createFolderWithLastComponent:(NSString *)component;

/**
 测量单行文本的宽度
 
 @param str 文本内容
 @param font 字体大小
 @return 返回宽度
 */
+ (CGFloat)measureSingleLineStringWidthWithString:(NSString *)str font:(UIFont *)font;

/**
 测量文本高度
 
 @param str 文本内容
 @param font 字体大小
 @param width 文本宽度
 @return 返回高度
 */
+ (CGFloat)measureMutilineStringHeightWithString:(NSString *)str font:(UIFont *)font width:(CGFloat)width;

/**
 获取视频指定时间点的画面帧

 @param asset 视频资源
 @param curTime 时间点
 @return 返回值
 */
+ (UIImage *)fetchThumbnailWithAVAsset:(AVAsset *)asset curTime:(CGFloat)curTime;

@end
