//
//  TSFactorSlider.m
//  TipScope
//
//  Created by 舒雄威 on 17/8/10.
//  Copyright © 2017年 Yoya. All rights reserved.
//

#import "TSFactorSlider.h"
#import "UIButton+Extension.h"

@implementation TSFactorSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
        self = nibs[0];
        self.frame = frame;
        self.videoProgress.layer.cornerRadius = 1;
        [self.videoProgress clipsToBounds];
    }
    return self;
}

- (void)configBlock {
    [self layoutIfNeeded];
    [self resetBarPointLimit];
    
    [_sliderBar setEnlargeEdge:10];
    
    CGFloat totalWidth = self.width - 20;
    CGFloat scale = _maxFactor / totalWidth;
    
    WSWeak(weakSelf);
    _sliderBar.sliderBarDidTracking = ^ (CGPoint point){
        weakSelf.sliderBarConstant.constant = point.x;
        
        CGFloat factor = point.x * scale;
        if (weakSelf.sliderBarDidTrack) {
            weakSelf.sliderBarDidTrack(factor);
        }
    };
    
    _sliderBar.sliderBarDidTracked = ^(CGPoint point) {
        weakSelf.sliderBarConstant.constant = point.x;
        
        CGFloat factor = point.x * scale;
        if (weakSelf.sliderBarDidEndTrack) {
            weakSelf.sliderBarDidEndTrack(factor);
        }
    };
}

- (void)resetBarPointLimit {
    _sliderBar.minX = 0;
    _sliderBar.maxX = self.width - 20;
}

- (void)setMaxFactor:(CGFloat)maxFactor {
    _maxFactor = maxFactor;
    [self configBlock];
}

@end
