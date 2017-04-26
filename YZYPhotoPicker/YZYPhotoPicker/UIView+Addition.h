//
//  UIView+Addition.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/24.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Addition)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign, readonly) CGFloat maxX;
@property (nonatomic, assign, readonly) CGFloat maxY;

@end
