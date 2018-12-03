//
//  TSHorizontalPickerView.m
//  TipScope
//
//  Created by Airths on 17/8/15.
//  Copyright © 2017年 QiShon. All rights reserved.
//

#import "TSHorizontalPickerView.h"
#import "TSHorizontalPickerViewCell.h"



#pragma mark - 常量
static const double animationDuration = 0.1;



@interface TSHorizontalPickerView () <UIScrollViewDelegate>

// 滑动视图
@property (nonatomic, strong) UIScrollView* scrollView;
// 滑动视图是否正在被拖动
@property (nonatomic, assign) BOOL isAllCellsUnhighlight;

// cell数组
@property (nonatomic, strong) NSMutableArray<TSHorizontalPickerViewCell *>* cells;
// cell的宽高
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;
// 第一个cell对应的 X值(实现中间选中状态)
// 第一个cell和最后一个cell能移动到中间被选中,则说明第一个cell之前,和最后一个cell之后,都还有额外的contentSize
@property (nonatomic, assign) CGFloat firstCellX;

@end



@implementation TSHorizontalPickerView
#pragma mark - 懒加载
- (NSMutableArray<TSHorizontalPickerViewCell *>*)cells
{
    if (!_cells) {
        _cells = [[NSMutableArray alloc] init];
    }
    return _cells;
}

#pragma mark - setter && getter
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    // 将索引seletedIndex所指示的cell,滑动到中心区域
    // 注意:由于scrollView的滑动动画比较特殊,只会调用代理方法scrollViewDidScroll:方法
    // 因此,需要在代理方法scrollViewDidEndScrollingAnimation:(动画结束),调用
    // callDelegateMethodWithScrollViewCurrentOffset
    CGFloat scrollViewOffsetX = self.cellWidth * _selectedIndex;
    CGFloat scrollViewOffsetY = self.scrollView.contentOffset.y;
    CGPoint scrollViewOffset = CGPointMake(scrollViewOffsetX, scrollViewOffsetY);
    [self.scrollView setContentOffset:scrollViewOffset animated:YES];
}

- (void)setSelectedIndexWithoutAnimation:(NSInteger)selectedIndex {
    
    _selectedIndex = selectedIndex;
    
    // 将索引seletedIndex所指示的cell,滑动到中心区域
    // 注意:由于scrollView的滑动动画比较特殊,只会调用代理方法scrollViewDidScroll:方法
    // 因此,需要在代理方法scrollViewDidEndScrollingAnimation:(动画结束),调用
    // callDelegateMethodWithScrollViewCurrentOffset
    CGFloat scrollViewOffsetX = self.cellWidth * _selectedIndex;
    CGFloat scrollViewOffsetY = self.scrollView.contentOffset.y;
    CGPoint scrollViewOffset = CGPointMake(scrollViewOffsetX, scrollViewOffsetY);
    [self.scrollView setContentOffset:scrollViewOffset animated:NO];
    
    // 手动调用代理方法scrollViewDidEndScrollingAnimation:(动画结束),调用
    // callDelegateMethodWithScrollViewCurrentOffset
    [self scrollViewDidEndScrollingAnimation:self.scrollView];
}

#pragma mark - 初始化
// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame capacityOfDisplayCell:(NSInteger)capacity delegate:(id<TSHorizontalPickerViewDelegate>)delegate dataSource:(id<MIHorizontalPickerViewDataSource>)dataSource
{
    if (self = [super initWithFrame:frame]) {
        // 1.记录变量
        self.capacity = capacity;
        self.delegate = delegate;
        self.dataSource = dataSource;
        
        // 2.初始化设置
        [self setUp];
    }
    return self;
}

// 初始化方法
+ (instancetype)horizontalPickerViewWithFrame:(CGRect)frame capacityOfDisplayCell:(NSInteger)capacity delegate:(id<TSHorizontalPickerViewDelegate>)delegate dataSource:(id<MIHorizontalPickerViewDataSource>)dataSource
{
    return  [[self alloc] initWithFrame:frame capacityOfDisplayCell:capacity delegate:delegate dataSource:dataSource];
}

// 初始化设置
- (void)setUp
{
    // 1.scrollView
    // frame
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = 0;
    CGFloat scrollViewW = self.bounds.size.width;
    CGFloat scrollViewH = self.bounds.size.height;
    CGRect scrollViewFrame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    // 指示条
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    // delegate
    self.scrollView.delegate = self;
    // 背景透明 与 减速效果
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    // 添加
    [self addSubview:self.scrollView];
    
    // 2.cell的宽高
    self.cellWidth = self.bounds.size.width / self.capacity;
    self.cellHeight = self.bounds.size.height;
    
    // 3.第一个cell的位置
    self.firstCellX = (self.frame.size.width - self.cellWidth) * 0.5;
    
    // 4.刷新数据
    [self reloadData];
    
//    NSLog(@"%s, scrollViewFrame = %@", __func__, NSStringFromCGRect(scrollViewFrame));
//    NSLog(@"%s, self.cellWidth = %f, self.cellHeight = %f", __func__, self.cellWidth, self.cellHeight);
//    NSLog(@"%s, self.firstCellX = %f", __func__, self.firstCellX);
}

#pragma mark - 布局子控件
// 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 布局cells
    [self layoutCells];
}

// 布局cells
- (void)layoutCells
{
    // 1.scrollView的frame
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = 0;
    CGFloat scrollViewW = self.bounds.size.width;
    CGFloat scrollViewH = self.bounds.size.height;
    CGRect scrollViewFrame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
    self.scrollView.frame = scrollViewFrame;
    
    // 2.cells的frame
    CGFloat cellX = self.firstCellX;
    for (int i = 0; i < self.cells.count; i++) {
        // 获取cell
        TSHorizontalPickerViewCell* cell = self.cells[i];
        // 设置cell的frame
        CGFloat cellY = 0;
        CGFloat cellW = self.cellWidth;
        CGFloat cellH = self.cellHeight;
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        cell.frame = cellFrame;
        // cellX增加
        cellX += self.cellWidth;
        
//        NSLog(@"%s, cellFrame = %@", __func__, NSStringFromCGRect(cellFrame));
    }
    
    // 3.scrollView的contentSize
    CGFloat scrollViewContentSizeW = MAX(cellX + self.bounds.size.width - self.firstCellX - self.cellWidth * 0.5, cellX);
    CGFloat scrollViewContentSizeH = self.bounds.size.height;
    CGSize scrollViewContentSize = CGSizeMake(scrollViewContentSizeW, scrollViewContentSizeH);
    self.scrollView.contentSize = scrollViewContentSize;
    
    // 4.根据scrollView的contentOffset调用代理方法
    [self callDelegateMethodWithScrollViewCurrentOffset:self.scrollView.contentOffset];
    
//    NSLog(@"%s, scrollViewFrame = %@", __func__, NSStringFromCGRect(scrollViewFrame));
//    NSLog(@"%s, scrollViewContentSize = %@", __func__, NSStringFromCGSize(scrollViewContentSize));
}

#pragma mark - 公有方法
// 重新加载数据
- (void)reloadData
{
    // 1.将所有的cell从父控件中移除,并清空cells数组
    for (TSHorizontalPickerViewCell* cell in self.cells) {
        [cell removeFromSuperview];
    }
    [self.cells removeAllObjects];
    
    // 2.通过数据源获取要展示的cell的数量
    NSInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnInHorizontalPickerView:)]) {
        count = [self.dataSource numberOfColumnInHorizontalPickerView:self];
    }
    
    // 3.通过数据源获取要展示什么样的cell
    if ([self.dataSource respondsToSelector:@selector(horizontalPickerView:cellForColumnAtIndex:)]) {
        for (NSInteger i = 0; i < count; i++) {
            TSHorizontalPickerViewCell* cell = [self.dataSource horizontalPickerView:self cellForColumnAtIndex:i];
            // 保存cell,并将cell添加到scrollView
            [self.cells addObject:cell];
            [self.scrollView addSubview:cell];
        }
    }
    
    // 4.重新布局cells
    [self layoutCells];
    
//    NSLog(@"%s", __func__);
}

#pragma mark - Helper
// 根据scrollView的contentOffset调用代理方法
- (void)callDelegateMethodWithScrollViewCurrentOffset:(CGPoint)currentOffset
{
    // 1.处于中心区域的cell的索引(高亮状态的cell的索引)
    NSInteger centerIndex = roundf(currentOffset.x / self.cellWidth);
    
    // 2.根据索引,调用不同的代理方法
    for (int i = 0; i < self.cells.count; i++) {
        TSHorizontalPickerViewCell* cell = self.cells[i];
        if (i == centerIndex) {
            // 记录中心位置索引(不能用setter)
            _selectedIndex = i;
            // 中心区域
            [self callDelegateMethodDidHighlightHorizontalPickerViewCell:cell withIndex:i];
            
            cell.selected = YES;
        } else {
            // 非中心区域
            [self callDelegateMethodDidUnhighlightHorizontalPickerViewCell:cell withIndex:i];
            cell.selected = NO;
        }
    }
    
//    NSLog(@"%s, centerIndex = %lu", __func__, centerIndex);
}

// 调用cell处于中心区域的代理方法(调用cell处于高亮状态的代理方法)
- (void)callDelegateMethodDidHighlightHorizontalPickerViewCell:(TSHorizontalPickerViewCell *)hpvc withIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(horizontalPickerView:didHighlightHorizontalPickerViewCell:atIndex:)]) {
        [self.delegate horizontalPickerView:self didHighlightHorizontalPickerViewCell:hpvc atIndex:index];
    }
    
//    NSLog(@"%s, index = %lu", __func__, index);
}

// 调用cell处于非中心区域的代理方法(调用cell处于通常状态的代理方法)
- (void)callDelegateMethodDidUnhighlightHorizontalPickerViewCell:(TSHorizontalPickerViewCell *)hpvc withIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(horizontalPickerView:didUnhighlightHorizontalPickerViewCell:atIndex:)]) {
        [self.delegate horizontalPickerView:self didUnhighlightHorizontalPickerViewCell:hpvc atIndex:index];
    }
    
//    NSLog(@"%s, index = %lu", __func__, index);
}

// 设置离中心区域最近的cell进入中心区域
- (void)scrollViewSetNearestCellIntoCenterArea:(UIScrollView *)scrollView
{
    // 1.获取scrollView的 X轴偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 2.左右边界安全判断
    if (offsetX < 0) {
        offsetX = 0;
    } else if (offsetX > (self.cells.count - 1) * self.cellWidth) {
        offsetX = (self.cells.count - 1) * self.cellWidth;
    }
    
    // 3.对偏移的倍数进行四舍五入
    NSInteger step = roundf(offsetX / self.cellWidth);
    
    // 4.设置偏移量
    CGFloat contentOffsetX = self.cellWidth * step;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGPoint contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
    // 方案一 : 无动画
    [UIView animateWithDuration:animationDuration animations:^{
        [scrollView setContentOffset:contentOffset animated:NO];
    } completion:^(BOOL finished) {
        // 5.根据scrollView的contentOffset调用代理方法
        [self callDelegateMethodWithScrollViewCurrentOffset:scrollView.contentOffset];
    }];
    
//    NSLog(@"%s, contentOffset = %@", __func__, NSStringFromCGPoint(contentOffset));
}

#pragma mark - 代理
#pragma mark - UIScrollViewDelegate
// scrollView滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isAllCellsUnhighlight) {
        // 通知代理 － 所有的cell都处于非中心区域
        for (int i = 0; i < self.cells.count; i++) {
            TSHorizontalPickerViewCell* cell = self.cells[i];
            [self callDelegateMethodDidUnhighlightHorizontalPickerViewCell:cell withIndex:i];
        }
        self.isAllCellsUnhighlight = YES;
    }
//    NSLog(@"%s", __func__);
}

// scrollView将要开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isAllCellsUnhighlight = NO;
//    NSLog(@"%s", __func__);
}

// scrollView结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 设置离中心区域最近的cell进入中心区域
    [self scrollViewSetNearestCellIntoCenterArea:scrollView];
//    NSLog(@"%s", __func__);
}

// scrollView将要开始减速
// 可以在此处结束scrollView的减速,优化视觉效果
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:scrollView.contentOffset animated:NO];
//    NSLog(@"%s", __func__);
}

// 注意:手指离开屏幕后,scrollView会继续滑动一段时间再停止
// 如果需要scrollView在停止滑动后一定要执行某段代码,应搭配
// scrollView结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 设置离中心区域最近的cell进入中心区域
    [self scrollViewSetNearestCellIntoCenterArea:scrollView];
//    NSLog(@"%s", __func__);
}

// scrollView结束滑动动画
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 根据scrollView的contentOffset调用代理方法
    [self callDelegateMethodWithScrollViewCurrentOffset:scrollView.contentOffset];
//    NSLog(@"%s", __func__);
}

@end

























