//
//  YZYPhotoBrowserViewController.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/20.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYPhotoBrowserViewController.h"
#import "YZYPhotoAsset.h"
#import "YZYPhotoBrowserCell.h"
#import "UIView+Addition.h"
#import "YZYPhotoDataManager.h"

#define kViewWidth self.view.frame.size.width

@interface YZYPhotoBrowserViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
{
    UICollectionView *_collectionView;
    UIButton *_rightSelectBtn;
    UIButton *_sendBtn;
}
@end

@implementation YZYPhotoBrowserViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configUI];
    [self configNavBar];
    [self configTabbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_currentIndex != 0) {
        [_collectionView setContentOffset:CGPointMake((self.view.width + 20) * _currentIndex, 0) animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    id asset = _dataArray[_currentIndex];
    NSString *UID = [YZYPhotoDataManager getAssetIdentifier: asset];
    
    for (YZYPhotoAsset *photoAsset in _selecteAssets) {
        if ([photoAsset.uniqueID isEqualToString: UID]) {
            _rightSelectBtn.selected = YES;
            break;
        }
    }
}

- (void)configNavBar {
    self.navigationController.navigationBarHidden = YES;
    UIView *navView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.view addSubview: navView];
    
    {
        UIView *maskView = [[UIView alloc] initWithFrame: navView.bounds];
        maskView.backgroundColor = [UIColor whiteColor];
        [navView addSubview: maskView];
    }
    
    {
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, navView.height - 0.5, navView.width, 0.5)];
        [navView addSubview: lineImgView];
        lineImgView.backgroundColor = [UIColor lightGrayColor];
    }
    
    {
        UIButton *returnBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [returnBtn setTitle: @"返回" forState: UIControlStateNormal];
        [returnBtn addTarget: self action: @selector(returnBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [navView addSubview: returnBtn];
        returnBtn.frame = CGRectMake(0, 20, 50, 44);
        returnBtn.titleLabel.font = [UIFont systemFontOfSize: 16];
        [returnBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    }
    
    {
        UIButton *selectBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [selectBtn addTarget: self action: @selector(selectBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [navView addSubview: selectBtn];
        selectBtn.frame = CGRectMake(navView.frame.size.width - 27 - 10, 28, 27, 27);
        _rightSelectBtn = selectBtn;
        [selectBtn setBackgroundImage: [UIImage imageNamed: @"gridCell_unSelect"] forState: UIControlStateNormal];
        [selectBtn setBackgroundImage: [UIImage imageNamed: @"gridCell_select"] forState: UIControlStateSelected];
        selectBtn.selected = NO;
    }
}

- (void)configTabbar {
    UIView *tabbarView = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    tabbarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview: tabbarView];
    
    {
        UIView *maskView = [[UIView alloc] initWithFrame: tabbarView.bounds];
        maskView.backgroundColor = [UIColor whiteColor];
        [tabbarView addSubview: maskView];
    }
    
    {
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, tabbarView.width, 0.5)];
        [tabbarView addSubview: lineImgView];
        lineImgView.backgroundColor = [UIColor lightGrayColor];
    }
    
    {
        UIButton *sendBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        NSString *str = [NSString stringWithFormat:  @"完成(%ld/%ld)",_selecteAssets.count,_maxSelectCount];
        [sendBtn setTitle: str forState: UIControlStateNormal];
        [sendBtn addTarget: self action: @selector(sendBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [tabbarView addSubview: sendBtn];
        sendBtn.frame = CGRectMake(tabbarView.frame.size.width - 80 - 10, 0, 80, 40);
        sendBtn.titleLabel.font = [UIFont systemFontOfSize: 16];
        [sendBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        _sendBtn = sendBtn;
    }
}

- (void)configUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height - 64 - 40);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(- 10, 64, self.view.width + 20, self.view.height - 64 - 40) collectionViewLayout:layout];
    [_collectionView registerClass: [YZYPhotoBrowserCell class] forCellWithReuseIdentifier: @"YZYPhotoBrowserCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView reloadData];
}


#pragma mark --- UIButton Actions

- (void)returnBtnClick {
    self.onSelectedPhotos(_selecteAssets);
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)selectBtnClick {
    
    if (_selecteAssets.count == _maxSelectCount && _rightSelectBtn.isSelected == NO) {
        return;
    }
    
    _rightSelectBtn.selected = !_rightSelectBtn.selected;

    YZYPhotoBrowserCell *browserCell = (YZYPhotoBrowserCell *)[_collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: _currentIndex inSection: 0]];

    if (_rightSelectBtn.isSelected) {
        
        YZYPhotoAsset *photoAsset = [[YZYPhotoAsset alloc] init];
        photoAsset.photoName = [YZYPhotoDataManager getImageNameFromAsset: browserCell.photoAsset];
        photoAsset.uniqueID = [YZYPhotoDataManager getAssetIdentifier: browserCell.photoAsset];
        photoAsset.photoAsset = browserCell.photoAsset;
        [_selecteAssets addObject: photoAsset];
        
    } else {
        
        NSString *currentAssetUID = [YZYPhotoDataManager getAssetIdentifier: browserCell.photoAsset];
        
        for (YZYPhotoAsset *photoAsset in _selecteAssets) {
            if ([photoAsset.uniqueID isEqualToString: currentAssetUID]) {
                [_selecteAssets removeObject: photoAsset];
                break;
            }
        }
    }
    
    [self refreshNaviBarState];
}

- (void)sendBtnClick {
    if (self.onCommitPhotos) {
        self.onCommitPhotos([_selecteAssets mutableCopy]);
    }
}

- (void)refreshNaviBarState {
    
    BOOL hited = NO;
    
    YZYPhotoBrowserCell *browserCell = (YZYPhotoBrowserCell *)[_collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: _currentIndex inSection: 0]];

    NSString *currentAssetUID = [YZYPhotoDataManager getAssetIdentifier: browserCell.photoAsset];
    
    for (YZYPhotoAsset *photoAsset in _selecteAssets) {
        if ([photoAsset.uniqueID isEqualToString: currentAssetUID]) {
            hited = YES;
            break;
        }
    }
    
    _rightSelectBtn.selected = hited;

    NSString *str = [NSString stringWithFormat:  @"完成(%ld/%ld)",_selecteAssets.count,_maxSelectCount];
    [_sendBtn setTitle: str forState: UIControlStateNormal];
}

#pragma mark - UICollection DataSource & delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YZYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YZYPhotoBrowserCell" forIndexPath:indexPath];
    cell.photoAsset = _dataArray[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(YZYPhotoBrowserCell *)cell resetUI];
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [(YZYPhotoBrowserCell *)cell resetUI];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.width + 20);
    _currentIndex = currentIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self refreshNaviBarState];
}


@end
