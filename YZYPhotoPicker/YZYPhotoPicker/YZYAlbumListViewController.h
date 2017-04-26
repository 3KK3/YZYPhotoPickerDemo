//
//  YZYAlbumListViewController.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const _Nonnull AlbumListCellIdentifier;

@interface YZYAlbumListViewController : UIViewController

@property (nonatomic , copy) void (^_Nonnull selectCompletion)(id _Nonnull albumData);

@end
