//
//  UIButton+Extension.h
//  MicroInsight
//
//  Created by 舒雄威 on 2018/8/23.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extension)

- (void)setEnlargeEdge:(CGFloat)size;

- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end
