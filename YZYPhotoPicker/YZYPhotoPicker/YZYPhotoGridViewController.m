//
//  YZYPhotoGridViewController.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYPhotoGridViewController.h"
#import "YZYPhotoGridCell.h"
#import "YZYPhotoBrowserViewController.h"
#import "YZYAlbumDropView.h"
#import "YZYPhotoAsset.h"
#import "UIView+Addition.h"

static NSString *const cellIdentifier = @"YZYPhotoGridCell";

@interface YZYPhotoGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSArray * _dataArray;
    UICollectionView * _listCollectionView;
    NSMutableArray <YZYPhotoAsset *>* _selectedArray;
    
    UIButton *_browserBtn;
    UIButton *_sureBtn;
    UIButton *_cameraBtn;
    UIView *_navBarView;
    UIImageView *_arrowImgView;
    UILabel *_titleLabel;
    
    BOOL _hadShowAlbumListView;
}

@property (nonatomic, strong) YZYAlbumDropView *albumsView;


@end

@implementation YZYPhotoGridViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _isImgType = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedArray = [@[] mutableCopy];
    self.view.backgroundColor = [UIColor whiteColor];

    [self configUI];
    if (_maxSelectCount != 1) {
        [self configTabbar];
    }
    [self configNavBar];

    [self loadData];
}

- (void)loadData {
    [YZYPhotoDataManager shareInstance].bReverse = YES;
    
    [[YZYPhotoDataManager shareInstance] fetchCameraRollPhotoList:^(NSArray * photoList) {
        _dataArray = photoList;
        [_listCollectionView reloadData];
    }];
    
    dispatch_queue_t global_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(global_t, ^{
        
        [[YZYPhotoDataManager shareInstance] fetchAllPhotoAlbumsList:^(NSArray * allGroups) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.albumsView.dataArray = allGroups;
            });
        }];
    });
}

- (void)configNavBar {
    self.navigationController.navigationBarHidden = YES;
    UIView *navView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: navView];
    _navBarView = navView;
    
    {
        UIButton *backToListBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        
        [backToListBtn setTitle: @"相机" forState: UIControlStateNormal];
        [backToListBtn addTarget: self action: @selector(openCamera) forControlEvents: UIControlEventTouchUpInside];
        [navView addSubview: backToListBtn];
        [backToListBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        backToListBtn.frame = CGRectMake(0, 24, 50, 40);
        backToListBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
        _cameraBtn = backToListBtn;
    }
    
    {
        UIButton *cancelBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [cancelBtn setTitle: @"取消" forState: UIControlStateNormal];
        [cancelBtn addTarget: self action: @selector(cancelBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [navView addSubview: cancelBtn];
        [cancelBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        cancelBtn.frame = CGRectMake(navView.frame.size.width - 50 - 10, 24, 50, 40);
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
    }
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(navView.frame.size.width / 2 - 75, 20, 150, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize: 18];
        titleLabel.text = @"所有照片";
        [navView addSubview: titleLabel];
        titleLabel.userInteractionEnabled = YES;
        [titleLabel sizeToFit];
        _titleLabel = titleLabel;

        _titleLabel.frame = CGRectMake(navView.frame.size.width / 2 - _titleLabel.width / 2, 20, _titleLabel.width, 44);
        
        UITapGestureRecognizer *titleTapGes = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapTitleAction)];
        [titleLabel addGestureRecognizer: titleTapGes];
    }
    
    {
        _arrowImgView = [[UIImageView alloc] initWithFrame: CGRectMake(_titleLabel.maxX + 3, 0, 13.5, 8)];
        [navView addSubview: _arrowImgView];
        _arrowImgView.centerY = _titleLabel.centerY;
        _arrowImgView.image = [UIImage imageNamed: @"arrow"];
        _arrowImgView.userInteractionEnabled = YES;
        [_arrowImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapTitleAction)]];
    }
    
    {
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, navView.height - 0.5, navView.width, 0.5)];
        [navView addSubview: lineImgView];
        lineImgView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)configTabbar {
    UIView *tabbarView = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    tabbarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: tabbarView];
    
    {
        UIButton *browserBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [browserBtn setTitle: @"预览" forState: UIControlStateNormal];
        [browserBtn addTarget: self action: @selector(browserBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [tabbarView addSubview: browserBtn];
        browserBtn.frame = CGRectMake(10, 0, 50, 40);
        browserBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
        [browserBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        _browserBtn = browserBtn;
        _browserBtn.enabled = NO;
    }
    
    {
        UIButton *sureBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        
        NSString *str = [NSString stringWithFormat:  @"完成(0/%ld)",_maxSelectCount];
        [sureBtn setTitle: str forState: UIControlStateNormal];
        [sureBtn addTarget: self action: @selector(sureBtnClick) forControlEvents: UIControlEventTouchUpInside];
        [tabbarView addSubview: sureBtn];
        sureBtn.frame = CGRectMake(tabbarView.frame.size.width - 80 - 10, 0, 80, 40);
        sureBtn.titleLabel.font = [UIFont systemFontOfSize: 14];
        [sureBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        _sureBtn = sureBtn;
        _sureBtn.enabled =NO;
    }
    {
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, tabbarView.width, 0.5)];
        [tabbarView addSubview: lineImgView];
        lineImgView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)configUI {
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(PhotoCellWidth, PhotoCellWidth);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    _listCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 64, self.view.width, self.view.height - 64 - 40) collectionViewLayout: flowLayout];
    _listCollectionView.prefetchingEnabled = NO;
    _listCollectionView.dataSource  = self;
    _listCollectionView.delegate = self;
    _listCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: _listCollectionView];
    [_listCollectionView registerClass: [YZYPhotoGridCell class] forCellWithReuseIdentifier: cellIdentifier];
}

#pragma mark --- tool method

//- (void)reloaddDsignatedDataPhotos {
//    [[YZYPhotoDataManager shareInstance] fetchPhotoListOfAlbumData: _albumData result:^(NSArray * photoList) {
//        _dataArray = photoList;
//        [_listCollectionView reloadData];
//    }];
//}

- (void)checkBtnState {
    if (_selectedArray.count > 0) {
        _sureBtn.enabled = _browserBtn.enabled = YES;
        _sureBtn.selected = _browserBtn.selected = YES;
        [_sureBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [_browserBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    } else {
        _sureBtn.enabled = _browserBtn.enabled = NO;
        _sureBtn.selected = _browserBtn.selected = NO;
        [_sureBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        [_browserBtn setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
    }
    
    NSString *str = [NSString stringWithFormat:  @"完成(%ld/%ld)",_selectedArray.count,_maxSelectCount];
    [_sureBtn setTitle: str forState: UIControlStateNormal];
}

- (YZYAlbumDropView *)albumsView {
    if (!_albumsView) {
        YZYAlbumDropView * albumView = [[YZYAlbumDropView alloc] initWithFrame: CGRectMake(0, 64 - self.view.height, self.view.width, self.view.height - 64)];
        albumView.userInteractionEnabled = NO;
        [self.view insertSubview: albumView belowSubview: _navBarView];
        
        _albumsView = albumView;
        [_arrowImgView.layer removeAllAnimations];
        __weak typeof(self) weakSelf = self;
        _albumsView.selecteHandler = ^(id albumData) {
            [weakSelf handleSelectAlbumData: albumData];
        };
    }
    return _albumsView;
}

- (void)showAlbumListView {
    _hadShowAlbumListView = YES;
    self.view.userInteractionEnabled = NO;
    _cameraBtn.hidden = YES;
    [self.view insertSubview: self.albumsView belowSubview: _navBarView];

    [UIView animateWithDuration: 0.3f animations:^{
        self.albumsView.y = 64;
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        self.albumsView.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)dismissAlbumsListView {
    _cameraBtn.hidden = NO;

    [UIView animateWithDuration: 0.3f animations:^{
        
        self.albumsView.y = 64 - [UIScreen mainScreen].bounds.size.height;
        _arrowImgView.transform = CGAffineTransformIdentity;

    } completion:^(BOOL finished) {
        
        self.view.userInteractionEnabled = YES;
        
        [self.albumsView removeFromSuperview];
        [_arrowImgView.layer addAnimation:[self getIconAnimation] forKey:@"move"];
        _hadShowAlbumListView = NO;

    }];
}

- (CAAnimation*)getIconAnimation {
    CAKeyframeAnimation* anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = @[@0,@2.0f,@0,@2.0,@0,@0];
    anim.keyTimes = @[@0,@(0.25f/6.0f),@(0.5/6.0f),@(0.75f/6.0f),@(1.0f/6.0f),@1.0f];
    anim.duration = 6.0f;
    anim.repeatCount = MAXFLOAT;
    anim.removedOnCompletion = NO;
    return anim;
}

- (void)handleSelectAlbumData:(id)data {
    [self dismissAlbumsListView];
    
    if (data) {
//        [self reloaddDsignatedDataPhotos];
       
        [[YZYPhotoDataManager shareInstance] fetchAlbumInfoWithThumbImgSize: CGSizeZero albumData: data fetchResult:^(NSDictionary * infoDic) {
           
            _titleLabel.text = infoDic[kPDMAlbumInfoNameKey];
            [_titleLabel sizeToFit];
            _titleLabel.frame = CGRectMake(_navBarView.frame.size.width / 2 - _titleLabel.width / 2, 20, _titleLabel.width, 44);
            _arrowImgView.frame = CGRectMake(_titleLabel.maxX + 3, 0, 13.5, 8);
            _arrowImgView.centerY  =_titleLabel.centerY;
        }];
    }
}

#pragma mark --- handle event action ---

- (void)tapTitleAction {
    
    if (_hadShowAlbumListView) {
        [self dismissAlbumsListView];
    } else {
        [self showAlbumListView];
    }

}

- (void)cancelBtnClick {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)sureBtnClick {
    
    NSMutableArray *assetsArray = [NSMutableArray arrayWithCapacity: _selectedArray.count];
    
    if (_isImgType) {
        
        dispatch_group_t serviceGroup = dispatch_group_create();
        
        for (YZYPhotoAsset *selectAsset in _selectedArray) {
            
            dispatch_group_enter(serviceGroup);

            [[YZYPhotoDataManager shareInstance] fetchImageFromAsset: selectAsset.photoAsset type: _resolutionType targetSize: _targetSize result:^(UIImage *img) {
                [assetsArray addObject: img];
                
                dispatch_group_leave(serviceGroup);
            } ];
        }
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
            if (_selectedCompletion) {
                _selectedCompletion(assetsArray ,YES);
            }
        });

    } else {
        
        for (YZYPhotoAsset *selectAsset in _selectedArray) {
            
            [assetsArray addObject: selectAsset.photoAsset];
        }
        
        if (_selectedCompletion) {
            _selectedCompletion(assetsArray ,NO);
        }
    }

    [self cancelBtnClick];
}

- (void)browserBtnClick {
    NSMutableArray *assetsArray = [NSMutableArray arrayWithCapacity: _selectedArray.count];
    
    for (YZYPhotoAsset *selectAsset in _selectedArray) {
        
        [assetsArray addObject: selectAsset.photoAsset];
    }
    
    [self showBrowserVCWithDataArray: assetsArray selectIndex: 0];
}

- (void)showBrowserVCWithDataArray:(NSArray *)dataArray selectIndex:(NSInteger)selectIndex {
    YZYPhotoBrowserViewController *browserVC = [[YZYPhotoBrowserViewController alloc] init];
    browserVC.dataArray = dataArray;
    browserVC.maxSelectCount = _maxSelectCount;
    browserVC.selecteAssets = [_selectedArray mutableCopy];
    browserVC.currentIndex = selectIndex;
    [self.navigationController pushViewController: browserVC animated: YES];
    
    browserVC.onSelectedPhotos = ^(NSArray *resultSelectAssets){
        [_selectedArray removeAllObjects];
        [_selectedArray addObjectsFromArray: resultSelectAssets];
        [_listCollectionView reloadData];
        [self checkBtnState];
    };
    
    browserVC.onCommitPhotos = ^(NSArray *resultArray) {
        
        if (resultArray.count > 0) {
            NSMutableArray *assetsArray = [NSMutableArray arrayWithCapacity: resultArray.count];
            
            if (_isImgType) {
                
                for (YZYPhotoAsset *selectAsset in resultArray) {
                    
                    [[YZYPhotoDataManager shareInstance] fetchImageFromAsset: selectAsset.photoAsset type: _resolutionType targetSize: _targetSize result:^(UIImage *img) {
                        [assetsArray addObject: img];
                    } ];
                }
                
                if (_selectedCompletion) {
                    _selectedCompletion(assetsArray ,YES);
                }
            } else {
                
                for (YZYPhotoAsset *selectAsset in resultArray) {
                    
                    [assetsArray addObject: selectAsset.photoAsset];
                }
                
                if (_selectedCompletion) {
                    _selectedCompletion(assetsArray ,NO);
                }
            }
            [self cancelBtnClick];
        }else {
            _selectedCompletion(resultArray ,_isImgType);
            [self cancelBtnClick];
        }
    };
}

#pragma mark --- data source ---

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YZYPhotoGridCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier: cellIdentifier forIndexPath: indexPath];
    cell.photoAsset = _dataArray[indexPath.item];
    
    cell.selectCompletion = ^(id asset , BOOL hadSelectd, YZYPhotoGridCell *gridCell){
        [self didTapCellWithAsset: asset selectState: hadSelectd cell:gridCell];
    };
    
    NSString *photoUID = [YZYPhotoDataManager getAssetIdentifier: _dataArray[indexPath.item] ];
    
    NSMutableArray *tempArray = [NSMutableArray array];

    for (YZYPhotoAsset *asset in _selectedArray) { // 每次循环败笔
        [tempArray addObject: asset.uniqueID];
    }
    
    if ([tempArray containsObject: photoUID]) {
        [cell selectCellItem: YES anim: NO];

    } else {
        [cell selectCellItem: NO anim: NO];
    }
    return cell;
}

- (void)didTapCellWithAsset:(id)selectAsset selectState:(BOOL)selectState cell:(YZYPhotoGridCell *)cell {
    
    
    if (_maxSelectCount == 1) {
        [cell selectCellItem: YES anim: YES];
        self.selectedCompletion(@[selectAsset] , NO);
        [self cancelBtnClick];
        return;
    }
    
    YZYPhotoAsset *asset = [[YZYPhotoAsset alloc] init];
    asset.photoName = [YZYPhotoDataManager getImageNameFromAsset: selectAsset];
    asset.uniqueID = [YZYPhotoDataManager getAssetIdentifier: selectAsset];
    asset.photoAsset = selectAsset;
    
    NSInteger selectedIndex = -1;
    
    for (NSInteger i = 0; i < _selectedArray.count; i ++) {
        
        YZYPhotoAsset *photoAsset = _selectedArray[i];
        if ([photoAsset.uniqueID isEqualToString: asset.uniqueID]) {
            selectedIndex = i;
            break;
        }
    }
    
    if (selectedIndex == -1 && _selectedArray.count < _maxSelectCount) { // 没有命中
        
        [_selectedArray addObject: asset];
        [cell selectCellItem: YES anim: YES];
    } else {
        if (selectedIndex != -1) {
            [_selectedArray removeObjectAtIndex: selectedIndex];
            [cell selectCellItem: NO anim: YES];
        }
    }
    
    [self checkBtnState];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showBrowserVCWithDataArray: _dataArray selectIndex: indexPath.item];
}

#pragma mark --- 拍照

- (void)openCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.view.backgroundColor = [UIColor blackColor];
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.sourceType = sourceType;
        picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.selectedCompletion(@[image] , YES);
    }
    [picker dismissViewControllerAnimated: NO completion: nil];
    [self.presentingViewController dismissViewControllerAnimated: YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
