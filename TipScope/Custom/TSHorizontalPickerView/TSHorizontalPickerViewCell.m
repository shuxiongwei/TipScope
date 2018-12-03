//
//  TSHorizontalPickerViewCell.m
//  TipScope
//
//  Created by Airths on 17/8/15.
//  Copyright © 2017年 QiShon. All rights reserved.
//

#import "TSHorizontalPickerViewCell.h"
#import "TSHorizontalPickerViewCellItem.h"

#define QSColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define titleColorHighlight QSColor(245, 180, 86, 1.0)
#define titleColorNormal QSColor(255, 255, 255, 1.0)

static NSString* const fontFamilyNormal = @"Courier";
static NSString* const fontFamilyHightlight = @"Courier-Blod";

@interface TSHorizontalPickerViewCell ()

@property (nonatomic, strong) UILabel* titleLabel;

@end



@implementation TSHorizontalPickerViewCell
#pragma mark - setter && getter
- (void)setItem:(TSHorizontalPickerViewCellItem *)item
{
    _item = item;
    self.titleLabel.text = item.title;
}
#pragma mark - 初始化
- (instancetype)initWithHorizontalPickerViewCellItem:(TSHorizontalPickerViewCellItem *)item
{
    if (self = [super init]) {
        // 1.初始化设置
        [self setUp];
        
        // 2.赋值
        self.item = item;
        
        // 3.添加手势
        [self addGesture];
    }
    return self;
}

// 初始化设置
- (void)setUp
{
    // 1.自身
    self.backgroundColor = [UIColor clearColor];
    
    // 2.标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = UIColorFromRGBWithAlpha(0x9FB1C1, 1);
    //self.titleLabel.font = [UIFont fontWithName:fontFamilyNormal size:fontSizeNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.titleLabel];
}

// 添加手势
- (void)addGesture
{
    // 添加点击手势
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDidTrigger)];
    [self addGestureRecognizer:tap];
}

// 触发点击手势
- (void)tapGestureDidTrigger
{
    // 执行被选中的回调
    if (self.HorizontalPickerViewCellSelectBlock) {
        self.HorizontalPickerViewCellSelectBlock(self.currentIndex);
    }
}

#pragma mark - 布局
// 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.标题
    self.titleLabel.frame = self.bounds;
}


#pragma mark - 公有方法
// 设置通常状态
- (void)setNormalState
{
    // titleLabel
    self.titleLabel.textColor = UIColorFromRGBWithAlpha(0x9FB1C1, 1);
    //self.titleLabel.font = [UIFont fontWithName:fontFamilyNormal size:fontSizeNormal];
    //self.titleLabel.font = [UIFont systemFontOfSize:15];
}

// 设置高亮状态
- (void)setHighlightState
{
    // titleLabel
    self.titleLabel.textColor = UIColorFromRGBWithAlpha(0x0070F9, 1);
    //self.titleLabel.font = [UIFont fontWithName:fontFamilyHightlight size:fontSizeHighlight];
}

@end


















