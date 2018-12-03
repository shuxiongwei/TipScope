//
//  TSHomeViewController.m
//  TipScope
//
//  Created by 舒雄威 on 2018/10/21.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "TSHomeViewController.h"
#import "TSShootViewController.h"

@interface TSHomeViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIView *albumView;
@property (weak, nonatomic) IBOutlet UIView *communityView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *shootView;

@end

@implementation TSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configHomeUI];
    [self configGestureRecognizer];
}

- (void)configHomeUI {
    
    CGFloat width = (TSScreenWidth - 5 * 3) / 3.0 * 2.0;
    _widthConstraint.constant = width;
    
    _albumView.layer.cornerRadius = 3;
    _albumView.layer.masksToBounds = YES;
    _communityView.layer.cornerRadius = 3;
    _communityView.layer.masksToBounds = YES;
    _loginView.layer.cornerRadius = 3;
    _loginView.layer.masksToBounds = YES;
    _shootView.layer.cornerRadius = 3;
    _shootView.layer.masksToBounds = YES;
}

- (void)configGestureRecognizer {
    UITapGestureRecognizer *albumT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAlbumView:)];
    [_albumView addGestureRecognizer:albumT];
    
    UITapGestureRecognizer *communityT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCommunityView:)];
    [_communityView addGestureRecognizer:communityT];
    
    UITapGestureRecognizer *shootT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickShootView:)];
    [_shootView addGestureRecognizer:shootT];
    
    UITapGestureRecognizer *loginT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLoginView:)];
    [_loginView addGestureRecognizer:loginT];
}

#pragma mark - 手势
//相册
- (void)clickAlbumView:(UITapGestureRecognizer *)rec {

}

//社区
- (void)clickCommunityView:(UITapGestureRecognizer *)rec {
    
}

//拍摄
- (void)clickShootView:(UITapGestureRecognizer *)rec {
    TSShootViewController *shootVC = [[TSShootViewController alloc] init];
    [self presentViewController:shootVC animated:YES completion:nil];
}

//登录
- (void)clickLoginView:(UITapGestureRecognizer *)rec {
    
}

@end
