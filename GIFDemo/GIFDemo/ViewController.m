//
//  ViewController.m
//  GIFDemo
//
//  Created by JmoVxia on 2016/10/12.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "GIFView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GIFView *view = [[GIFView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 180)];
    view.url = @"http://upload-images.jianshu.io/upload_images/1979970-9d2b1cc945099612.gif?imageMogr2/auto-orient/strip";
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
