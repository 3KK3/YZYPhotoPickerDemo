//
//  ViewController.m
//  YZYPhotoPicker
//
//  Created by YZY on 2017/4/26.
//  Copyright © 2017年 YZY. All rights reserved.
//

#import "ViewController.h"
#import "YZYPhotoPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 200, 30);
    [button setTitle: @"点击图片选择器" forState: UIControlStateNormal];
    [self.view addSubview: button];
    
    button.backgroundColor = [UIColor greenColor];
    [button addTarget: self action: @selector(buttonClick) forControlEvents: UIControlEventTouchUpInside];
    
}

- (void)buttonClick {
    
    YZYPhotoPicker *photoPicker = [[YZYPhotoPicker alloc] init];
    
    
    [photoPicker showPhotoPickerWithController: self maxSelectCount: 4 completion:^(NSArray *imageSources, BOOL isImgType) {
        
        if (isImgType) { // 如果是UIImage
            
        } else {  // 是照片资源 iOS8 以下为AlAsset  iOS8以上为PHAsset
            
        //可以使用单例 YZYPhotoDataManager 中的如下两个方法处理得到UIImage
            
            /**
             *  根据照片分辨率、照片大小、照片资源 获取UIImage targetSize仅iOS8后支持
             */
            //- (void)fetchImageFromAsset:(id)asset type:(PhotoResolutionType)nType targetSize:(CGSize)size result:(void (^)(UIImage *))result;
            /**
             *  根据照片分辨率、照片大小、照片索引 获取UIImage targetSize仅iOS8后支持
             */
            //- (void)fetchImageByIndex:(NSInteger)nIndex type:(PhotoResolutionType)nType  targetSize:(CGSize)size result:(void (^)(UIImage *))result;
            
            
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
