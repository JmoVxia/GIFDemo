//
//  GIFView.m
//  GIFDemo
//
//  Created by JmoVxia on 2016/10/13.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "GIFView.h"
#import "FLAnimatedImage.h"
#import "UIImageView+WebCache.h"

@interface GIFView()
/**GIF视图*/
@property (nonatomic,weak)FLAnimatedImageView *gifImageView;

@end


@implementation GIFView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    //创建FLAnimatedImageView,继承自UIView
    FLAnimatedImageView *gifImageView = [[FLAnimatedImageView alloc] init];
    gifImageView.frame                = self.frame;
    [self addSubview:gifImageView];
    _gifImageView = gifImageView;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    //将GIF转换成Data
    NSData   *gifImageData             = [self imageDataFromDiskCacheWithKey:url];
    //沙盒存在，直接加载显示
    if (gifImageData)
    {
        [self animatedImageView:_gifImageView data:gifImageData];
        //沙盒不存在，网络获取
    } else
    {
        __weak __typeof(self) weakSelf = self;
        NSURL *newUrl = [NSURL URLWithString:url];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:newUrl
                                                              options:0
                                                             progress:nil
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                
                                                                [[[SDWebImageManager sharedManager] imageCache] storeImage:image
                                                                                                      recalculateFromImage:NO
                                                                                                                 imageData:data
                                                                                                                    forKey:newUrl.absoluteString
                                                                                                                    toDisk:YES];
                                                                //主线程显示
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [weakSelf animatedImageView:_gifImageView data:data];
                                                                });
                                                            }];
    }
}
//通过数据创建GIF
- (void)animatedImageView:(FLAnimatedImageView *)imageView data:(NSData *)data
{
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:data];
    imageView.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    imageView.animatedImage   = gifImage;
    imageView.alpha           = 0.f;
    
    [UIView animateWithDuration:1.f animations:^{
        imageView.alpha = 1.f;
    }];
}

//从沙盒读取
- (NSData *)imageDataFromDiskCacheWithKey:(NSString *)key
{
    NSString *path = [[[SDWebImageManager sharedManager] imageCache] defaultCachePathForKey:key];
    return [NSData dataWithContentsOfFile:path];
}



@end
