//
//  YZYPhotoGridViewController.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PhotoCellWidth (([UIScreen mainScreen].bounds.size.width - 5 * 5) / 4)

@interface YZYPhotoGridViewController : UIViewController

@property (nonatomic , assign) NSUInteger maxSelectCount;

@property (nonatomic , strong) id albumData; // 配合YZYAlbumListViewController

@property (nonatomic , copy) void (^selectedCompletion)(NSArray * imagesArray, BOOL isImgType);

@end
