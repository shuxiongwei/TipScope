//
//  TSHorizontalPickerView.h
//  TipScope
//
//  Created by Airths on 17/8/15.
//  Copyright © 2017年 QiShon. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TSHorizontalPickerView, TSHorizontalPickerViewCell;
@protocol TSHorizontalPickerViewDelegate <NSObject>

@optional
/**
 HorizontalPickerView的cell处于高亮状态(处于中间区域)
 注意: 这里只负责通知代理对象,哪个cell处于中心区域,哪个cell处于非中心区域
 至于处于中心区域的cell,和非处于中心区域的cell要如何改变自身的样式,由cell本身决定

 @param hpv QSHorizontalPickerView
 @param hpvc QSHorizontalPickerViewCell
 @param index QSHorizontalPickerViewCell的索引
 */
- (void)horizontalPickerView:(TSHorizontalPickerView *)hpv didHighlightHorizontalPickerViewCell:(TSHorizontalPickerViewCell *)hpvc atIndex:(NSInteger)index;

/**
 HorizontalPickerView的cell处于非高亮状态(处于两侧区域)

 @param hpv QSHorizontalPickerView
 @param hpvc QSHorizontalPickerViewCell
 @param index QSHorizontalPickerViewCell的索引
 */
- (void)horizontalPickerView:(TSHorizontalPickerView *)hpv didUnhighlightHorizontalPickerViewCell:(TSHorizontalPickerViewCell *)hpvc atIndex:(NSInteger)index;

@end



#pragma mark - 数据源
@protocol MIHorizontalPickerViewDataSource <NSObject>

@required
/**
 一共有几列

 @param hpv QSHorizontalPickerView
 @return 列数
 */
- (NSInteger)numberOfColumnInHorizontalPickerView:(TSHorizontalPickerView *)hpv;

/**
 每列返回什么样的cell

 @param hpv QSHorizontalPickerView
 @param index 该列对应的索引
 @return 该列的对应的cell
 */
- (TSHorizontalPickerViewCell *)horizontalPickerView:(TSHorizontalPickerView *)hpv cellForColumnAtIndex:(NSInteger)index;

@end



@interface TSHorizontalPickerView : UIView

//处于中心区域的cell对应的索引(高亮状态的cell对应的索引)
@property (nonatomic, assign) NSInteger selectedIndex;
//显示的子控件数量
@property (nonatomic, assign) NSInteger capacity;
//代理和数据源
@property (nonatomic, weak) id<TSHorizontalPickerViewDelegate> delegate;
@property (nonatomic, weak) id<MIHorizontalPickerViewDataSource> dataSource;

/**
 初始化方法

 @param frame 位置和宽高
 @param capacity 显示的子控件数量,仅用于决定显示cell的数据,即仅用于决定cell的宽度.第一个cell的offsetX即firstCellX永远为中间区域
 @param delegate 代理
 @param dataSource 数据源
 @return 返回值
 */
- (instancetype)initWithFrame:(CGRect)frame capacityOfDisplayCell:(NSInteger)capacity delegate:(id<TSHorizontalPickerViewDelegate>)delegate dataSource:(id<MIHorizontalPickerViewDataSource>)dataSource;

/**
 初始化方法

 @param frame 位置和宽高
 @param capacity 显示的子控件数量,仅用于决定显示cell的数据,即仅用于决定cell的宽度.第一个cell的offsetX即firstCellX永远为中间区域
 @param delegate 代理
 @param dataSource 数据源
 @return 返回值
 */
+ (instancetype)horizontalPickerViewWithFrame:(CGRect)frame capacityOfDisplayCell:(NSInteger)capacity delegate:(id<TSHorizontalPickerViewDelegate>)delegate dataSource:(id<MIHorizontalPickerViewDataSource>)dataSource;

/**
 重新加载数据
 */
- (void)reloadData;

/**
 设置处于中心区域的cell对应的索引(高亮状态的cell对应的索引 - 无动画)

 @param selectedIndex 高亮状态的cell对应的索引
 */
- (void)setSelectedIndexWithoutAnimation:(NSInteger)selectedIndex;

@end
