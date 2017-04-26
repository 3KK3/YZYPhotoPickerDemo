//
//  YZYPhotoAsset.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/20.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYPhotoAsset.h"

@implementation YZYPhotoAsset

- (NSString *)description {
    return [NSString stringWithFormat: @"PhotoAssetModel - photoName:%@ ，UID:%@",_photoName, _uniqueID];
}

@end
