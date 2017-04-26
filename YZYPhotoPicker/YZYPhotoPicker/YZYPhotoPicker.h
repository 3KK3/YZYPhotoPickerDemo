//
//  YZYPhotoPicker.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YZYPhotoPicker : NSObject

- (void)showPhotoPickerWithController:(UIViewController *)controller maxSelectCount:(NSUInteger)maxCount completion:(void (^)(NSArray * , BOOL isImgType))completion;

@end
