#前言

许多项目需要加载GIF图片，但是在直接使用UIImageView加载存在许多问题，于是查找资料做了一个加载GIF的Demo，思路来源https://github.com/YouXianMing/Animations 在链接里边，已经给出了解决办法，Demo只是将功能剥离，简单封装了一下。

#思路

使用FLAnimatedImage来加载GIF图片，再利用SDWebImage来做缓存，话不多说，直接上代码。

#使用方法  
```
导入头文件#import "GIFView.h"  

创建GIFView，添加到视图上
GIFView *view = [[GIFView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
view.url = @"http://upload-images.jianshu.io/upload_images/1979970-9d2b1cc945099612.gif?imageMogr2/auto-orient/strip";
[self.view addSubview:view];
```
#GIFView内部代码
```
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
    gifImageView.frame                = self.frame;
    [self addSubview:gifImageView];
    _gifImageView = gifImageView;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    //将GIF转换成Data
    NSData   *gifImageData             = [self imageDataFromDiskCacheWithKey:url];
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
    imageView.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    imageView.animatedImage   = gifImage;
    imageView.alpha           = 0.f;
    
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
```
#效果图
这里需要注意要用真机测试，模拟器测试会看到卡顿现象

![真机效果图.gif](http://p1.bqimg.com/4851/c6832e5c15e6fd66.gif)


#声明
在这里说明下，只是简单的剥离功能，封装了一下，方便大家使用。
