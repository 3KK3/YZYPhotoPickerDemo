//
//  YZYAlbumListViewController.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYAlbumListViewController.h"
#import "YZYAlbumListCell.h"
#import "YZYPhotoDataManager.h"

NSString *const AlbumListCellIdentifier = @"YZYAlbumListCell";

@interface YZYAlbumListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray * _dataArray;
    UICollectionView * _listCollectionView;
}
@end

@implementation YZYAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavBar];
    
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [[YZYPhotoDataManager shareInstance] fetchAllPhotoAlbumsList:^(NSArray * albumListArray) {
        
        _dataArray = [NSArray arrayWithArray: albumListArray];
        [_listCollectionView reloadData];
    }];
}

- (void)configNavBar {
    self.navigationController.navigationBarHidden = YES;
    UIView *navView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navView.backgroundColor = [UIColor blackColor];
    [self.view addSubview: navView];
    
    {
        UIButton *cancelBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [cancelBtn setTitle: @"取消" forState: UIControlStateNormal];
        [cancelBtn addTarget: self action: @selector(cancelBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [navView addSubview: cancelBtn];
        cancelBtn.frame = CGRectMake(navView.frame.size.width - 50 - 10, 20, 50, 44);
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
    }
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(navView.frame.size.width / 2 - 75, 20, 150, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize: 16];
        titleLabel.text = @"相册";
        [navView addSubview: titleLabel];
    }
}

- (void)configUI {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, kAlbumListCellH);
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 0;

    _listCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout: flowLayout];
    _listCollectionView.dataSource  = self;
    _listCollectionView.delegate = self;
    [self.view addSubview: _listCollectionView];
    [_listCollectionView registerClass: [YZYAlbumListCell class] forCellWithReuseIdentifier: AlbumListCellIdentifier];
}

- (void)cancelBtnClick {
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark --- data source ---

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

#pragma mark --- delegate ---
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectCompletion) {
        _selectCompletion(_dataArray[indexPath.item]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
