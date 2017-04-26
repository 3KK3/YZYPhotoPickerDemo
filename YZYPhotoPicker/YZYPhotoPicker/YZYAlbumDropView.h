//
//  YZYAlbumDropView.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/24.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZYAlbumDropView : UIView

@property (nonatomic, copy) NSArray * _Nullable dataArray;

@property (nonatomic, copy) void(^ _Nonnull selecteHandler)(_Nullable id albumData);

@end
