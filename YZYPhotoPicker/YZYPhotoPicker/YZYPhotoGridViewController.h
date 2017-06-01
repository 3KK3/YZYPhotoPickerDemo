//
//  YZYPhotoGridViewController.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZYPhotoDataManager.h"

#define PhotoCellWidth (([UIScreen mainScreen].bounds.size.width - 5 * 5) / 4)

@interface YZYPhotoGridViewController : UIViewController

@property (nonatomic , assign) NSUInteger maxSelectCount;

@property (nonatomic , assign) PhotoResolutionType resolutionType; // 选择结果清晰度，默认是ePhotoResolutionTypeOrigin

@property (assign, nonatomic) CGSize targetSize; // 得到的图片大小 ，仅iOS8以后支持，默认图片大小

@property (assign, nonatomic) BOOL isImgType; // 选择结果是UIimage还是 图片asset ，默认是yes

@property (nonatomic , copy) void (^selectedCompletion)(NSArray * imagesArray, BOOL isImgType);

@end
