//
//  YZYAlbumDropView.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/24.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYAlbumDropView.h"
#import "YZYPhotoDataManager.h"
#import "YZYAlbumListCell.h"
#import "UIView+Addition.h"

@interface YZYAlbumDropView () <UICollectionViewDataSource , UICollectionViewDelegate>
{
    UICollectionView * _listCollectionView;
}
@end

@implementation YZYAlbumDropView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        
        UIView *bgMaskView = [[UIView alloc] initWithFrame: self.bounds];
        [self addSubview: bgMaskView];
        bgMaskView.backgroundColor = [UIColor blackColor];
        bgMaskView.alpha = 0.5f;
        [bgMaskView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(maskTapAction)]];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(self.frame.size.width, kAlbumListCellH);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        _listCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, kAlbumListCellH * 5) collectionViewLayout: flowLayout];
        _listCollectionView.dataSource  = self;
        _listCollectionView.delegate = self;
        _listCollectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview: _listCollectionView];
        
        [_listCollectionView registerClass: [YZYAlbumListCell class] forCellWithReuseIdentifier: AlbumListCellIdentifier];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [_listCollectionView reloadData];
}

- (void)maskTapAction {
    self.selecteHandler(nil);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YZYAlbumListCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier: AlbumListCellIdentifier forIndexPath: indexPath];
    [cell setupCellWithData: _dataArray[indexPath.item]];
    
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selecteHandler(_dataArray[indexPath.item]);
}

@end
