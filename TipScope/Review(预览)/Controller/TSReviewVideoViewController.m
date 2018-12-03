//
//  TSReviewVideoViewController.m
//  TipScope
//
//  Created by 舒雄威 on 2018/7/13.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "TSReviewVideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TSReviewVideoViewController ()

@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation TSReviewVideoViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];

    [self configVideoPlayer];
    [self configReviewVideoUI];
    [super configBackBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)configVideoPlayer {
    NSString *documentPath = [TSHelpTool getDocumentPath];
    NSString *videoPath = [NSString stringWithFormat:@"%@/video.mov", documentPath];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:videoPath]];
    _videoPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
    _playerLayer.frame = self.view.frame;
    //_playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_playerLayer];
}

- (void)configReviewVideoUI {
    _playBtn = [TSUIFactory createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, 60, 60) normalTitle:nil normalTitleColor:nil highlightedTitleColor:nil selectedColor:nil titleFont:0 normalImage:[UIImage imageNamed:@"icon_review_play_nor"] highlightedImage:nil selectedImage:nil touchUpInSideTarget:self action:@selector(playVideo:)];
    _playBtn.center = self.view.center;
    [self.view addSubview:_playBtn];
}

#pragma mark - 事件响应
//播放视频
- (void)playVideo:(UIButton *)sender {
    sender.hidden = YES;
    [_videoPlayer play];
}

#pragma mark - 通知
//视频播放结束
- (void)itemDidPlayToEndTime:(NSNotification *)notification {
    _playBtn.hidden = NO;
    [_videoPlayer seekToTime:CMTimeMake(0, 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
