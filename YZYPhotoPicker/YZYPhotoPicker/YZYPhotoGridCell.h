//
//  YZYPhotoGridCell.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZYPhotoGridCell : UICollectionViewCell

@property (nonatomic, strong) id photoAsset;

@property (nonatomic, copy) void(^selectCompletion)(id asset , BOOL hadSelected ,YZYPhotoGridCell*);

- (void)resetSelectState;

- (void)selectCellItem:(BOOL)select anim:(BOOL)anim;

@end
