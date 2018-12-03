//
//  TSReviewImageViewController.m
//  TipScope
//
//  Created by 舒雄威 on 2018/8/22.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "TSReviewImageViewController.h"
#import "TSReviewImageCell.h"

@interface TSReviewImageViewController () <UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation TSReviewImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configReviewImageUI];
}

- (void)configReviewImageUI {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[TSReviewImageCell class] forCellWithReuseIdentifier:@"reviewCell"];
    _collectionView.pagingEnabled = YES;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    [super configBackBtn];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSReviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:indexPath];
    
    NSString *documentPath = [TSHelpTool getDocumentPath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/image.png", documentPath];
    UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
    cell.imgView.image = image;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
