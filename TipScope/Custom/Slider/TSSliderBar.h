//
//  TSSliderBar.h
//  TipScope
//
//  Created by John_Chen on 12/5/16.
//  Copyright © 2016 舒雄威. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TSSliderBar : UIButton

@property (nonatomic, copy) void (^sliderBarDidTracking)(CGPoint point);
@property (nonatomic, copy) void (^sliderBarDidTracked)(CGPoint point);
@property (nonatomic, assign) CGFloat minX;
@property (nonatomic, assign) CGFloat maxX;

@end
