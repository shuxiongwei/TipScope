//
//  UIFont+Extension.m
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/23.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "UIFont+Extension.h"
#import <CoreText/CoreText.h>

@implementation UIFont (Extension)

+ (UIFont *)captionFontWithName:(NSString*)name size:(CGFloat)size {
    if ([name isEqualToString:@"custom"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"font" ofType:@"ttf"];
        return [UIFont customFontWithPath:path size:size];
    } else {
        return [UIFont fontWithName:name size:size];
    }
    return nil;
}

+ (UIFont*)customFontWithPath:(NSString*)path size:(CGFloat)size {
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider =CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}

@end
