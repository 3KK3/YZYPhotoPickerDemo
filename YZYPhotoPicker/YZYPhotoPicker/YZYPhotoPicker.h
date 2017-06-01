//
//  YZYPhotoPicker.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YZYPhotoDataManager.h"

@interface YZYPhotoPicker : NSObject

@property (assign, nonatomic) BOOL isImgType; // 选择结果是UIimage还是图片asset ，默认是yes
@property (nonatomic , assign) PhotoResolutionType resolutionType; // 选择结果清晰度，默认是ePhotoResolutionTypeOrigin
@property (assign, nonatomic) CGSize targetSize; // 得到的图片大小 ，仅iOS8以后支持，默认屏幕大小

- (void)showPhotoPickerWithController:(UIViewController *)controller maxSelectCount:(NSUInteger)maxCount completion:(void (^)(NSArray * , BOOL isImgType))completion;

@end
