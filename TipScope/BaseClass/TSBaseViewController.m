//
//  TSBaseViewController.m
//  TipScope
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSBaseViewController ()

@end

@implementation TSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)configBackBtn {
    UIButton *backBtn = [TSUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(20, 20, 30, 30) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_review_close_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(goBack:)];
    [self.view addSubview:backBtn];
}

#pragma mark - 事件响应
//返回
- (void)goBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
