//
//  ViewController.m
//  YZYPhotoPicker
//
//  Created by YZY on 2017/4/26.
//  Copyright © 2017年 YZY. All rights reserved.
//

#import "ViewController.h"
#import "YZYPhotoPicker.h"
#import "UIView+Addition.h"

@interface ViewController ()
{
    UIView *_view;
}

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
    
    _view = [[UIView alloc] initWithFrame: CGRectMake(0, button.maxY + 10, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (button.maxY + 10))];
    
    _view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview: _view];
    
}

- (void)buttonClick {
    
    YZYPhotoPicker *photoPicker = [[YZYPhotoPicker alloc] init];
    
    photoPicker.isImgType = NO;
    [photoPicker showPhotoPickerWithController: self maxSelectCount: 4 completion:^(NSArray *imageSources, BOOL isImgType) {
        
        [_view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        
        NSInteger i = 0;

        if (isImgType) { // 如果是UIImage
            
            for (UIImage *img in imageSources) {
                
                UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(i % 3 * 105, i / 3 * 105, 100, 100)];
                imgView.image = img;
                [_view addSubview: imgView];
                
                i ++;
            }
        } else {  // 是照片资源 iOS8 以下为AlAsset  iOS8以上为PHAsset
            
            for (id asset in imageSources) {
                
                [[YZYPhotoDataManager shareInstance] fetchImageFromAsset: asset type: ePhotoResolutionTypeScreenSize targetSize: [UIScreen mainScreen].bounds.size result:^(UIImage *img) {
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(i % 3 * 105, i / 3 * 105, 100, 100)];
                    
                    imgView.image = img;
                    [_view addSubview: imgView];
                }];
                
                i ++;
            }
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
