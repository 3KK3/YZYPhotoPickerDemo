//
//  YZYAlbumListCell.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYAlbumListCell.h"
#import "YZYPhotoDataManager.h"
#import "UIView+Addition.h"

static CGFloat const kAlubmImgViewW = 50;

NSString *const AlbumListCellIdentifier = @"AlbumListCellIdentifier";

@implementation YZYAlbumListCell
{
    UIImageView * _thumbImgView;
    UILabel * _detailInfoLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        
        _thumbImgView = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, kAlubmImgViewW, kAlubmImgViewW)];
        _thumbImgView.clipsToBounds = YES;
        _thumbImgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview: _thumbImgView];
        
        
        _detailInfoLabel = [[UILabel alloc] initWithFrame: CGRectMake(60, 0, 200, kAlbumListCellH)];
        _detailInfoLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview: _detailInfoLabel];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame: CGRectMake(10, kAlbumListCellH - 0.5, self.contentView.width, 0.5)];
        [self.contentView addSubview: lineImgView];
        lineImgView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setupCellWithData:(id)data {
    
    [[YZYPhotoDataManager shareInstance] fetchAlbumInfoWithThumbImgSize: CGSizeMake(kAlubmImgViewW, kAlubmImgViewW) albumData: data fetchResult:^(NSDictionary *dataDic) {
        _thumbImgView.image = dataDic[kPDMAlbumInfoImgKey];
        
        NSString *albumName = dataDic[kPDMAlbumInfoNameKey];
        
        NSInteger albumPhotoCount = [dataDic[kPDMAlbumInfoCountKey] integerValue];
        
        NSString *fullStr = [NSString stringWithFormat:@"%@ (%ld)", albumName, albumPhotoCount];
        
        NSMutableAttributedString *mutAttrString = [[NSMutableAttributedString alloc] initWithString: fullStr];
        
        [mutAttrString setAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize: 16]} range: NSMakeRange(0, albumName.length)];
        
        [mutAttrString setAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize: 11]} range: NSMakeRange(albumName.length, fullStr.length - albumName.length)];
        
        _detailInfoLabel.attributedText = mutAttrString;
    }];
}
@end





