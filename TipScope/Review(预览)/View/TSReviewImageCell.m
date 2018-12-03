//
//  TSReviewImageCell.m
//  TipScope
//
//  Created by 舒雄威 on 2018/4/19.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import "TSReviewImageCell.h"


const CGFloat minZoomScale = 1.0;
const CGFloat maxZoomScale = 2.5;

@interface TSReviewImageCell () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@end


@implementation TSReviewImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self configReviewImageUI];
    }
    
    return self;
}

#pragma mark - 配置UI
- (void)configReviewImageUI {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.minimumZoomScale = minZoomScale;
    _scrollView.maximumZoomScale = maxZoomScale;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.bouncesZoom = NO;
    _scrollView.delegate = self;
    [self.contentView addSubview:_scrollView];

    _imgView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
    _imgView.userInteractionEnabled = YES;
    _imgView.backgroundColor = [UIColor blackColor];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imgView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.cancelsTouchesInView = NO;
    tap.numberOfTapsRequired = 2;
    [_imgView addGestureRecognizer:tap];
}

#pragma mark - 手势
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {

    if (_scrollView.minimumZoomScale == _scrollView.zoomScale) {
        CGPoint tapPoint = [tap locationInView:_imgView];
        CGFloat zoomRectWidth = _scrollView.frame.size.width / maxZoomScale;
        CGFloat zoomRectHeight = _scrollView.frame.size.height / maxZoomScale;
        CGFloat zoomRectX = tapPoint.x - (zoomRectWidth / 2.0);
        CGFloat zoomRectY = tapPoint.y - (zoomRectHeight / 2.0);
        CGRect zoomRect = CGRectMake(zoomRectX, zoomRectY, zoomRectWidth, zoomRectHeight);
        [_scrollView zoomToRect:zoomRect animated:YES];
    } else {
        [_scrollView setZoomScale:minZoomScale animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imgView;
}

@end
