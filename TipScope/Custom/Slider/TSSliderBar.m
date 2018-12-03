//
//  OTSSliderBar.m
//  TipScope
//
//  Created by John_Chen on 12/5/16.
//  Copyright © 2016 舒雄威. All rights reserved.
//

#import "TSSliderBar.h"


@implementation TSSliderBar

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    CGPoint point = [touches.anyObject locationInView:self.superview];
    CGFloat x = MAX(point.x, _minX);
    x = MIN(x, _maxX);
    CGPoint resultPoint = CGPointMake(x, self.center.y);
    if (_sliderBarDidTracking) {
        _sliderBarDidTracking(resultPoint);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    CGPoint point = [touches.anyObject locationInView:self.superview];
    CGFloat x = MAX(point.x, _minX);
    x = MIN(x, _maxX);
    CGPoint resultPoint = CGPointMake(x, self.center.y);
    
    if (_sliderBarDidTracked) {
        _sliderBarDidTracked(resultPoint);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    CGPoint point = [touches.anyObject locationInView:self.superview];
    CGFloat x = MAX(point.x, _minX);
    x = MIN(x, _maxX);
    CGPoint resultPoint = CGPointMake(x, self.center.y);
    
    if (_sliderBarDidTracked) {
        _sliderBarDidTracked(resultPoint);
    }
}

@end
