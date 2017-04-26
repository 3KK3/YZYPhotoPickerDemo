//
//  YZYPhotoBrowserViewController.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/20.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZYPhotoBrowserViewController : UIViewController

@property (nonatomic, assign) NSUInteger maxSelectCount;

@property (nonatomic, copy) NSArray *dataArray;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *selecteAssets; // [YZYPhotoAsset]

@property (nonatomic, copy) void (^onSelectedPhotos)(NSArray *); // [YZYPhotoAsset]

@property (nonatomic, copy) void (^onCommitPhotos)(NSArray *); // [YZYPhotoAsset]

@end
 
