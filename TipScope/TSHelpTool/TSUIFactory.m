//
//  TSUIFactory.m
//  TipScope
//
//  Created by 舒雄威 on 2017/12/29.
//  Copyright © 2017年 舒雄威. All rights reserved.
//

#import "TSUIFactory.h"

@implementation TSUIFactory

+ (UIButton *)createButtonWithType:(UIButtonType)type
                        frame:(CGRect)frame
                  normalTitle:(NSString *)title
                   normalTitleColor:(UIColor *)norColor
             highlightedTitleColor:(UIColor *)hgtColor
                     selectedColor:(UIColor *)selColor
                    titleFont:(CGFloat)font
                  normalImage:(UIImage *)norImage
             highlightedImage:(UIImage *)hgtImage
                selectedImage:(UIImage *)selImage
              touchUpInSideTarget:(id)target
                           action:(SEL)action {
    
    UIButton *btn = [UIButton buttonWithType:type];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:norColor forState:UIControlStateNormal];
    [btn setTitleColor:hgtColor forState:UIControlStateHighlighted];
    [btn setTitleColor:selColor forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:font];
    [btn setImage:norImage forState:UIControlStateNormal];
    [btn setImage:hgtImage forState:UIControlStateHighlighted];
    [btn setImage:selImage forState:UIControlStateSelected];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

+ (UIButton *)createButtonWithType:(UIButtonType)type
                             frame:(CGRect)frame
                       normalTitle:(NSString *)title
                  normalTitleColor:(UIColor *)norColor
             highlightedTitleColor:(UIColor *)hgtColor
                     selectedColor:(UIColor *)selColor
                         titleFont:(CGFloat)font
                       normalImage:(UIImage *)norImage
                  highlightedImage:(UIImage *)hgtImage
                     selectedImage:(UIImage *)selImage
               touchUpInSideTarget:(id)target
                            action:(SEL)action
                   layoutDirection:(BOOL)vercital {
    
    UIButton *btn = [UIButton buttonWithType:type];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:norColor forState:UIControlStateNormal];
    [btn setTitleColor:hgtColor forState:UIControlStateHighlighted];
    [btn setTitleColor:selColor forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:font];
    [btn setImage:norImage forState:UIControlStateNormal];
    [btn setImage:hgtImage forState:UIControlStateHighlighted];
    [btn setImage:selImage forState:UIControlStateSelected];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (vercital) {
        CGFloat totalHeight = (btn.imageView.frame.size.height + btn.titleLabel.frame.size.height + 7);
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - btn.imageView.frame.size.height), 0.0, 0.0, -btn.titleLabel.frame.size.width)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -btn.imageView.frame.size.width, -(totalHeight - btn.titleLabel.frame.size.height),0.0)];
    }
    
    return btn;
}

+ (UILabel *)createLabelWithCenter:(CGPoint)centerPoint
                        withBounds:(CGRect)bounds
                          withText:(NSString *)text
                          withFont:(CGFloat)font
                     withTextColor:(UIColor *)color
                 withTextAlignment:(NSTextAlignment)alignment {
    
    UILabel *label = [[UILabel alloc] init];
    label.center = centerPoint;
    label.bounds = bounds;
    label.text = text;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:font];
    label.textAlignment = alignment;
    
    return label;
}

+ (CAShapeLayer *)createShapeLayerWithPath:(CGPathRef)path
                            strokeColor:(CGColorRef)strokeColor
                              fillColor:(CGColorRef)fillColor
                              lineWidth:(CGFloat)width {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path;
    shapeLayer.strokeColor = strokeColor;
    shapeLayer.fillColor = fillColor;
    shapeLayer.lineWidth = width;
    return shapeLayer;
}

+ (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect {

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5].CGPath);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
            shadowColor:(UIColor *)shadowColor
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius {
    
    //////// shadow /////////
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = view.layer.frame;
    
    shadowLayer.shadowColor = shadowColor.CGColor;//shadowColor阴影颜色
    shadowLayer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowLayer.bounds.size.width;
    float height = shadowLayer.bounds.size.height;
    float x = shadowLayer.bounds.origin.x;
    float y = shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [view.superview.layer insertSublayer:shadowLayer below:view.layer];
}

@end
