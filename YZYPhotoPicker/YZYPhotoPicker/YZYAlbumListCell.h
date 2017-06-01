//
//  YZYAlbumListCell.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlbumListCellH 60

extern NSString *const AlbumListCellIdentifier;

@interface YZYAlbumListCell : UICollectionViewCell

- (void)setupCellWithData:(id)data;

@end
