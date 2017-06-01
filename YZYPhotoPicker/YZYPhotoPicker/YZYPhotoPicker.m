//
//  YZYPhotoPicker.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYPhotoPicker.h"
#import "YZYPhotoDataManager.h"
#import "YZYPhotoGridViewController.h"

@implementation YZYPhotoPicker

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _isImgType = YES;
        _resolutionType = ePhotoResolutionTypeOrigin;
        _targetSize = [UIScreen mainScreen].bounds.size;
    }
    return self;
}

- (void)showPhotoPickerWithController:(id)controller maxSelectCount:(NSUInteger)maxCount completion:(void (^)(NSArray *,BOOL))completion {
    
    [YZYPhotoDataManager isPhotoLibraryVisible:^(PhotoAuthorizationStatus status) {
        
        if (status == PhotoAuthorizationStatusDenied) {
            
            NSLog(@"not allowed");
        }else if(status == PhotoAuthorizationStatusNotDetermined){
            //相册进行授权
            /* * * 第一次安装应用时直接进行这个判断进行授权 * * */
            
            [YZYPhotoDataManager requestAuthorization:^(PhotoAuthorizationStatus authorStatus) {
                
                if (authorStatus == PhotoAuthorizationStatusAuthorized) {
                    [self showPhotoListVCWithController: controller maxSelectCount: maxCount completion: completion];
                }
            }];
            
        }else if (status == PhotoAuthorizationStatusAuthorized){
            
            [self showPhotoListVCWithController: controller maxSelectCount: maxCount completion: completion];
        }
    }];
}

- (void)showPhotoListVCWithController:(UIViewController *)controller  maxSelectCount:(NSUInteger)maxCount completion:(void (^)(NSArray * , BOOL isImgType))completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        YZYPhotoGridViewController * photoListVC = [[YZYPhotoGridViewController alloc] init];
        UINavigationController * listNav = [[UINavigationController alloc] initWithRootViewController: photoListVC];
        photoListVC.isImgType = _isImgType;
        photoListVC.resolutionType = _resolutionType;
        photoListVC.maxSelectCount = maxCount;
        photoListVC.targetSize = _targetSize;
        photoListVC.selectedCompletion = ^ (NSArray * imagesArray, BOOL isImgType) {
            
            if (completion) {
                completion(imagesArray , isImgType);
            }
        };
        
        [controller presentViewController: listNav animated: YES completion: nil];
    });
}
@end
