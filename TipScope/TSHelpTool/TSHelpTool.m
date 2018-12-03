//
//  TSHelpTool.m
//  TipScope
//
//  Created by 舒雄威 on 2018/7/10.
//  Copyright © 2018年 舒雄威. All rights reserved.
//

#import "TSHelpTool.h"

@implementation TSHelpTool

+ (NSString *)timeStampSecond {
    long long stamp = [[NSDate date] timeIntervalSince1970] * 1000; //毫秒
    NSString *curStamp = [NSString stringWithFormat:@"%lld", stamp];
    
    return curStamp;
}

+ (NSString *)getDocumentPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)createFolderWithLastComponent:(NSString *)component {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *pathDocuments = [self getDocumentPath];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",pathDocuments,component];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return createPath;
}

+ (CGFloat)measureSingleLineStringWidthWithString:(NSString *)str font:(UIFont *)font {
    if (str == nil) {
        return 0;
    }
    
    CGSize measureSize = [str boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
    return ceil(measureSize.width);
}

+ (CGFloat)measureMutilineStringHeightWithString:(NSString *)str font:(UIFont *)font width:(CGFloat)width {
    
    if (str == nil || width <= 0) {
        return 0;
    }
    
    CGSize measureSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
    
    return ceil(measureSize.height);
}

+ (UIImage *)fetchThumbnailWithAVAsset:(AVAsset *)asset curTime:(CGFloat)curTime {
    @autoreleasepool {
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(curTime, asset.duration.timescale);
        NSError *error = nil;
        CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:NULL error:&error];
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
        
        if (image == nil) {
            time = CMTimeMakeWithSeconds(curTime + 1, asset.duration.timescale);
            imageRef = [gen copyCGImageAtTime:time actualTime:NULL error:&error];
            image = [[UIImage alloc] initWithCGImage:imageRef];
        }
        
        CGImageRelease(imageRef);
        return image;
    }
}

@end
