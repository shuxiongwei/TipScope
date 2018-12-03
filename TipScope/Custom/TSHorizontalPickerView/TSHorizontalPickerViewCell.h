//
//  TSHorizontalPickerViewCell.h
//  TipScope
//
//  Created by Airths on 17/8/15.
//  Copyright © 2017年 QiShon. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TSHorizontalPickerViewCellItem;
@interface TSHorizontalPickerViewCell : UIView

#pragma mark - 属性
// 在QSHorizontalPickerView中的索引
@property (nonatomic, assign) NSInteger currentIndex;

// 是否被选中
@property (nonatomic, assign, getter=isSelected) BOOL selected;

// 被选中的回调
@property (nonatomic, strong) void(^HorizontalPickerViewCellSelectBlock)(NSInteger currentIncex);

// 数据模型
@property (nonatomic, strong) TSHorizontalPickerViewCellItem* item;

#pragma mark - 方法
// 初始化方法
- (instancetype)initWithHorizontalPickerViewCellItem:(TSHorizontalPickerViewCellItem *)item;

// 设置通常状态
- (void)setNormalState;

// 设置高亮状态
- (void)setHighlightState;

@end
