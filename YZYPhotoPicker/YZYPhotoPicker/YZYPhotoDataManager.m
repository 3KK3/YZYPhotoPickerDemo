//
//  YZYPhotoDataManager.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYPhotoDataManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

NSString *  const kPDMAlbumInfoImgKey = @"PDMAlbumInfoImgKey";

NSString *  const kPDMAlbumInfoNameKey = @"PDMAlbumInfoNameKey";

NSString *  const kPDMAlbumInfoCountKey = @"PDMAlbumInfoCountKey";

@interface YZYPhotoDataManager ()
{
    BOOL _usePhotoKit;
    
    ALAssetsLibrary	* _assetsLibrary;
    
    NSMutableArray  * _photosArray; //当前相册数据 PHAsset 或者 AlAsset
    NSMutableArray  * _albumsArray; //全部相册列表数据 PHAssetCollection 或者 ALAssetsGroup
}

@property (nonatomic,strong) CIContext * context;

@end

@implementation YZYPhotoDataManager

#pragma mark --- 初始化相关 ---

+ (instancetype)shareInstance {
    
    static YZYPhotoDataManager * manager = nil;
    static dispatch_once_t once_t;
    
    dispatch_once(&once_t, ^{
        
        manager = [[YZYPhotoDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    
    if ([super init]) {
        
        _bReverse = NO;
        _photosArray = [NSMutableArray array];
        _albumsArray = [NSMutableArray array];
        _usePhotoKit = [YZYPhotoDataManager getiOSVersion] >= __IPHONE_8_0;
        
        if (!_usePhotoKit) {
            
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
    }
    return self;
}

+ (int)getiOSVersion {
    
    //[[[UIDevice currentDevice] systemVersion] floatValue] >=7.0
    static int version = -1;
    
    if (version == -1) {
        int ver1 = 0;
        int ver2 = 0;
        int ver3 = 0;
        
        NSString* iosVersion = [[UIDevice currentDevice] systemVersion];
        NSArray* versions = [iosVersion componentsSeparatedByString:@"."];
        
        if( [versions count] >= 2) {
            
            ver1 = [[versions objectAtIndex:0] intValue];
            ver2 = [[versions objectAtIndex:1] intValue];
            
            if ([versions count] == 3) {
                
                ver3 = [[versions objectAtIndex:2] intValue];
            }
            version = ver1*10000 + ver2*100 + ver3;
        }
    }
    return version;
}

#pragma mark --- 数据获取相关 ---

- (void)fetchAllPhotoAlbumsList:(fetchResultBlock)result {
    
    [_albumsArray removeAllObjects];
    
    if (_usePhotoKit) {
        //获取所有智能相册
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            //过滤掉视频和最近删除
            if (!([collection.localizedTitle isEqualToString:@"Recently Deleted"] ||
                  [collection.localizedTitle isEqualToString:@"Videos"])) {
                
                PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection: collection options: nil];
                
                if (fetchResult.count > 0) {
                    [_albumsArray addObject: collection];
                }
            }
        }];
        
        //获取用户创建的相册
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection: collection options: nil];
            
            if (fetchResult.count > 0) {
                [_albumsArray addObject: collection];
            }
        }];
        
        result(_albumsArray);
        
    } else {
        
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            if (group == nil) {
                
                if (_bReverse)
                    
                    _albumsArray = [[NSMutableArray alloc] initWithArray:[[_albumsArray reverseObjectEnumerator] allObjects]];
                
                result(_albumsArray);
                
                return;
                
            } else if (group.numberOfAssets > 0) {
                
                [_albumsArray addObject:group];
            }
        };
        
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            
            NSLog(@"asset helper Error : %@", [error description]);
        };
        
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
        
    }
}

- (void)fetchPhotoListOfAlbumData:(id)albumData result:(fetchResultBlock)result {
    
    [_photosArray removeAllObjects];
    
    if (_usePhotoKit) {
        
        PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection: albumData options: nil];
        
        for (PHAsset *asset in fetchResult) {
            
            //只添加图片类型资源，去除视频类型资源
            //当mediaType == 2时，这个资源则为视频资源
            
            if (asset.mediaType == 1) {
                
                [_photosArray addObject:asset];
            }
            
        }
        
        if (_bReverse) {
            
            _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
        }
        
        result(_photosArray);
        
    } else {
        
        if (![albumData isKindOfClass: [ALAssetsGroup class]]) {
            
            result(nil);
            
            return;
        }
        
        [albumData setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        [albumData enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
            
            if(alPhoto == nil) {
                
                if (_bReverse) {
                    
                    _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
                }
                
                result(_photosArray);
                
                return;
            }
            
            [_photosArray addObject:alPhoto];
        }];
    }
}

- (void)fetchCameraRollPhotoList:(fetchResultBlock)result {
    
    [_photosArray removeAllObjects];
    
    if (_usePhotoKit) {
        
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
        
        PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
        
        id collection = smartAlbumsFetchResult.firstObject;
        
        if ([collection isKindOfClass: [PHAssetCollection class]]) {
            
            PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection: collection options:nil];
            
            for (PHAsset *asset in fetchResult) {
                
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    
                    [_photosArray addObject:asset];
                }
            }
            
            if (_bReverse) {
                
                _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
            }
            
            result(_photosArray);
        }
        
    } else {
        
        NSMutableArray *savedPhotoList = [NSMutableArray array];
        
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            
            if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos) {
                
                [group setAssetsFilter: [ALAssetsFilter allPhotos]];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
                    
                    if(alPhoto == nil) {
                        
                        if (_bReverse) {
                            
                            NSArray * tempArray = [savedPhotoList copy];
                            
                            [savedPhotoList removeAllObjects];
                            
                            [savedPhotoList addObjectsFromArray: [[tempArray reverseObjectEnumerator] allObjects]];
                        }
                        
                        _photosArray = [savedPhotoList mutableCopy];
                        
                        result(_photosArray);
                        
                        return;
                    }
                    
                    [savedPhotoList addObject:alPhoto];
                }];
            }
        };
        
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *err) {
            
            NSLog(@"Asset read Error : %@", [err description]);
        };
        
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
    }
}

- (void)fetchTodayPhotosList:(fetchResultBlock)result {
    
    NSMutableArray * tempArray = [@[] mutableCopy];
    
    if (_usePhotoKit) {
        
        [self fetchCameraRollPhotoList:^(NSArray * phAssets) {
            
            [phAssets enumerateObjectsUsingBlock:^(PHAsset * asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([self isWithinDays: 1 date1: asset.creationDate date2: [NSDate date]]) {
                    
                    [tempArray addObject: asset];
                }
                
                if (asset == nil) {
                    
                    _photosArray = [tempArray mutableCopy];
                    
                    if (_bReverse) {
                        
                        _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
                    }
                    
                    result(_photosArray);
                    
                    return ;
                }
            }];
        }];
        
    } else {
        
        [self fetchCameraRollPhotoList:^(NSArray * alAssets) {
            
            [alAssets enumerateObjectsUsingBlock:^(ALAsset * asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSDate * photoDate =  [asset valueForProperty: @"ALAssetPropertyDate"];
                
                NSDate * currentDate = [NSDate date];
                
                if ([self isWithinDays: 1 date1: photoDate date2: currentDate]) {
                    
                    [tempArray addObject: asset];
                }
                
                if (asset == nil) {
                    
                    _photosArray = [tempArray mutableCopy];
                    
                    if (_bReverse) {
                        
                        _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
                    }
                    
                    result(_photosArray);
                    
                    return ;
                }
            }];
        }];
    }
}

- (void)fetchGifPhotosList:(fetchResultBlock)result {
    
    NSMutableArray * tempArray = [@[] mutableCopy];
    
    if (_usePhotoKit) {
        
        [self fetchCameraRollPhotoList:^(NSArray * phAssets) {
            
            [phAssets enumerateObjectsUsingBlock:^(PHAsset * asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString * fileName = [asset valueForKey:@"filename"];
                
                fileName = [fileName lowercaseString];
                
                if ([fileName hasSuffix:@".gif"]) {
                    
                    [tempArray addObject: asset];
                }
                
                if (asset == nil) {
                    
                    _photosArray = [tempArray mutableCopy];
                    
                    if (_bReverse) {
                        
                        _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
                    }
                    
                    result(_photosArray);
                    
                    return ;
                }
            }];
        }];
        
    } else {
        
        [self fetchCameraRollPhotoList:^(NSArray * alAssets) {
            
            [alAssets enumerateObjectsUsingBlock:^(ALAsset * asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                ALAssetRepresentation* image_representation = [asset defaultRepresentation];
                
                NSString* name = [image_representation filename];
                
                name = [name lowercaseString];
                
                if ([name hasSuffix:@".gif"]) {
                    
                    [tempArray addObject: asset];
                }
                
                if (asset == nil) {
                    
                    _photosArray = [tempArray mutableCopy];
                    
                    if (_bReverse) {
                        
                        _photosArray = [[NSMutableArray alloc] initWithArray:[[_photosArray reverseObjectEnumerator] allObjects]];
                    }
                    
                    result(_photosArray);
                    
                    return ;
                }
            }];
        }];
    }
}

- (BOOL)isWithinDays:(NSInteger)days date1:(NSDate *)date1 date2:(NSDate *)date2 {
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSDateComponents * date1Comp = nil;
    
    NSDateComponents * date2Comp = nil;
    
    if (_usePhotoKit) {
        
        date1Comp = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate: date1];
        
        date2Comp = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate: date2];
        
        
    } else {
        
        date1Comp = [calendar components: (NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit) fromDate: date1];
        
        date2Comp = [calendar components: (NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit) fromDate: date2];
    }
    
    if ( [date1Comp day] <= [date2Comp day] &&  [date1Comp day] + days >= ([date2Comp day]) &&  [date1Comp month] == [date2Comp month] && [date1Comp year] == [date2Comp year]) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

- (void)clearData {
    
    [_photosArray removeAllObjects];
    
    [_albumsArray removeAllObjects];
}

+ (NSString *)getAssetIdentifier:(id)asset {
    if ([YZYPhotoDataManager getiOSVersion] >= __IPHONE_8_0) {
        PHAsset *phAsset = (PHAsset *)asset;
        return phAsset.localIdentifier;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAsset *alAsset = (ALAsset *)asset;
        NSURL *assetUrl = [alAsset valueForProperty:ALAssetPropertyAssetURL];
#pragma clang diagnostic pop
        return assetUrl.absoluteString;
    }
}

- (NSUInteger)getAlbumsCount {
    
    return _albumsArray.count;
}

- (NSUInteger)getCurrentAlbumPhotosCount {
    
    return _photosArray.count;
}

- (void)fetchAlbumInfoWithThumbImgSize:(CGSize)imgSize albumIndex:(NSInteger)nIndex fetchResult:(void (^)(NSDictionary *))result {
    
    if (nIndex >= _albumsArray.count) {
        
        result(nil);
        
        return;
    }
    
    [self fetchAlbumInfoWithThumbImgSize: imgSize albumData: _albumsArray[nIndex] fetchResult: result];
}

- (void)fetchAlbumInfoWithThumbImgSize:(CGSize)imgSize albumData:(id)albumData fetchResult:(void (^)(NSDictionary *))result {
    
    NSMutableDictionary * mutDic = [@{} mutableCopy];
    
    if (_usePhotoKit) {
        
        if ([albumData isKindOfClass:[PHAssetCollection class]]) {
            
            PHAssetCollection * assetCollection = albumData;
            
            [mutDic setObject: assetCollection.localizedTitle forKey: kPDMAlbumInfoNameKey];
            
            PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection: assetCollection options: nil];
            
            [mutDic setObject: [NSNumber numberWithInteger: fetchResult.count] forKey: kPDMAlbumInfoCountKey];
            
            [[PHImageManager defaultManager] requestImageForAsset: fetchResult.lastObject
                                                       targetSize: imgSize
                                                      contentMode: PHImageContentModeDefault
                                                          options: nil
                                                    resultHandler:^(UIImage * _Nullable resultImg, NSDictionary * _Nullable info) {
                                                        
                                                        if (resultImg) {
                                                            
                                                            [mutDic setObject: resultImg forKey: kPDMAlbumInfoImgKey];
                                                            
                                                            result(mutDic);
                                                            
                                                            return ;
                                                            
                                                        }}];
        } else {
            
            result(nil);
            
        }
        
    } else {
        
        ALAssetsGroup * group = albumData;
        
        NSString * albumName = [group valueForProperty: ALAssetsGroupPropertyName];
        
        [mutDic setObject: albumName forKey: kPDMAlbumInfoNameKey];
        
        NSNumber * albumPhotosCount = [NSNumber numberWithInteger: [group numberOfAssets]];
        
        [mutDic setObject: albumPhotosCount forKey: kPDMAlbumInfoCountKey];
        
        UIImage * thumbImg = [UIImage imageWithCGImage:[group posterImage]];
        
        [mutDic setObject: thumbImg forKey: kPDMAlbumInfoImgKey];
        
        result(mutDic);
    }
}

+ (void)isPhotoLibraryVisible:(void (^)(PhotoAuthorizationStatus))authorazitionStatus {
    
    PhotoAuthorizationStatus photoRightStatus;

    if ([YZYPhotoDataManager getiOSVersion] >= __IPHONE_9_0) {
        
        //相册权限判断
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

        switch (status) {
            case PHAuthorizationStatusNotDetermined: {
                photoRightStatus = PhotoAuthorizationStatusNotDetermined;
            }
                break;
                
                case PHAuthorizationStatusRestricted: {
                    photoRightStatus = PhotoAuthorizationStatusRestricted;
            }
                break;
                
            case PHAuthorizationStatusDenied: {
                photoRightStatus = PhotoAuthorizationStatusDenied;
            }break;
                
            case PHAuthorizationStatusAuthorized:{
                photoRightStatus = PhotoAuthorizationStatusAuthorized;
            }
        }
        
        authorazitionStatus(photoRightStatus);
        
    }else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        
        switch (author) {
            case ALAuthorizationStatusNotDetermined: {
                photoRightStatus = PhotoAuthorizationStatusNotDetermined;
            }
                break;
                
            case ALAuthorizationStatusRestricted: {
                photoRightStatus = PhotoAuthorizationStatusRestricted;
            }
                break;
                
            case ALAuthorizationStatusDenied: {
                photoRightStatus = PhotoAuthorizationStatusDenied;

            }
                break;
                
            case ALAuthorizationStatusAuthorized: {
                photoRightStatus = PhotoAuthorizationStatusAuthorized;

            }
                break;
        }
        authorazitionStatus(photoRightStatus);
    }
}

- (id)getAssetAtIndex:(NSInteger)nIndex {
    
    if (nIndex >= _photosArray.count) {
        
        return nil;
    }
    return _photosArray[nIndex];
}

- (void)fetchImageFromAsset:(id)asset type:(PhotoResolutionType)nType targetSize:(CGSize)size result:(void (^)(UIImage *))result {
    
    if (asset == nil) {
        result(nil);
        return ;
    }
    
    if (_usePhotoKit) {
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = NO;
        
        PHAsset * phAsset = (PHAsset *)asset;
        
        switch (nType) {
                
            case ePhotoResolutionTypeThumb: {
                
                [[PHImageManager defaultManager] requestImageForAsset: phAsset
                                                           targetSize: size
                                                          contentMode: PHImageContentModeDefault
                                                              options: options
                                                        resultHandler:^(UIImage * _Nullable resultImg, NSDictionary * _Nullable info) {
                                                            
                                                            if (resultImg) {
                                                                
                                                                result(resultImg);
                                                            }
                                                        }];
                
            }
                
                break;
                
            case ePhotoResolutionTypeScreenSize: {
                
                [[PHImageManager defaultManager] requestImageForAsset: phAsset
                                                           targetSize: size
                                                          contentMode: PHImageContentModeAspectFit
                                                              options: options
                                                        resultHandler:^(UIImage *resultImg, NSDictionary *info){
                                                            
                                                            if (resultImg) {
                                                                
                                                                result(resultImg);
                                                            }
                                                            
                                                        }];
                
            }
                
                break;
                
            case ePhotoResolutionTypeOrigin: {
                
                [[PHImageManager defaultManager] requestImageForAsset: phAsset
                                                           targetSize: PHImageManagerMaximumSize
                                                          contentMode: PHImageContentModeAspectFit
                                                              options: options
                                                        resultHandler:^(UIImage *resultImg, NSDictionary *info){
                                                            
                                                            if (resultImg) {
                                                                
                                                                result(resultImg);
                                                            }
                                                            
                                                        }];
            }
                
                break;
        }
        
    } else {
        
        ALAsset * alAsset = (ALAsset *)asset;
        
        CGImageRef iRef = nil;
        
        switch (nType) {
                
            case ePhotoResolutionTypeThumb: {
                
                iRef = [alAsset thumbnail];
            }
                break;
                
            case ePhotoResolutionTypeScreenSize: {
                
                iRef = [alAsset.defaultRepresentation fullScreenImage];
            }
                break;
                
            case ePhotoResolutionTypeOrigin: {
                
                NSString *strXMP = alAsset.defaultRepresentation.metadata[@"AdjustmentXMP"];
                
                NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
                
                if (strXMP == nil) {
                    
                    UIImage * img = [UIImage imageWithCGImage: alAsset.defaultRepresentation.fullResolutionImage scale:1.0f orientation: alAsset.defaultRepresentation.orientation];
                    
                    result(img);
                    
                    return;
                }
                
                CIImage *image = [CIImage imageWithCGImage: alAsset.defaultRepresentation.fullResolutionImage];
                
                NSError *error = nil;
                
                NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP: dXMP inputImageExtent: image.extent error: &error];
                
                if (error) {
                    
                    NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
                }
                
                for (CIFilter *filter in filterArray) {
                    
                    [filter setValue:image forKey:kCIInputImageKey];
                    
                    image = [filter outputImage];
                }
                
                iRef = [self.context createCGImage:image fromRect:image.extent];
                
                UIImage* img = [UIImage imageWithCGImage: iRef scale:1.0f orientation: (UIImageOrientation)alAsset.defaultRepresentation.orientation];
                
                CGImageRelease(iRef);
                
                result(img);
                
                return;
            }
                break;
        }
        
        UIImage * img = [[UIImage alloc] initWithCGImage:iRef];
        
        result(img);
    }
    
}

- (CIContext *)context {
    
    if (_context == nil) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (void)fetchImageByIndex:(NSInteger)nIndex type:(PhotoResolutionType)nType targetSize:(CGSize)size result:(void (^)(UIImage *))result {
    
    if (nIndex >= _photosArray.count) {
        
        result(nil);
        return;
    }
    
    [self fetchImageFromAsset: _photosArray[nIndex] type: nType targetSize: size result: result];
    
}

+ (NSString *)getImageNameFromAsset:(id)asset {
    
    if ([YZYPhotoDataManager getiOSVersion] >= __IPHONE_8_0) {
        PHAsset * phAsset = (PHAsset *)asset;
        
        return [phAsset valueForKey: @"filename"];

    } else {
        ALAssetRepresentation* image_representation = [(ALAsset *)asset defaultRepresentation];
        
        NSString* name = [image_representation filename];
        
        return name;
    }
}

+ (CGSize) getImageSizeFromAsset:(id)asset {
    
    if ([YZYPhotoDataManager getiOSVersion] >= __IPHONE_8_0) {
        
        if (![asset isKindOfClass: [PHAsset class]]) {
            
            return CGSizeMake(0, 0);
        }
        
        PHAsset * phAsset = (PHAsset *)asset;
        
        return CGSizeMake(phAsset.pixelWidth / [UIScreen mainScreen].scale, phAsset.pixelHeight / [UIScreen mainScreen].scale);
        
        
    } else {
        
        if (![asset isKindOfClass: [ALAsset class]]) {
            return CGSizeMake(0, 0);
        }
        
        ALAssetRepresentation * representation = [(ALAsset *)asset defaultRepresentation];
        CGSize imageSize = [representation dimensions];
        return imageSize;
    }
}

+ (void)requestAuthorization:(void (^)(PhotoAuthorizationStatus))authorizationStatus {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus sstatus) {
        
        PhotoAuthorizationStatus photoRightStatus;
        
        //相册权限判断
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
            case PHAuthorizationStatusNotDetermined: {
                photoRightStatus = PhotoAuthorizationStatusNotDetermined;
            }
                break;
                
            case PHAuthorizationStatusRestricted: {
                photoRightStatus = PhotoAuthorizationStatusRestricted;
            }
                break;
                
            case PHAuthorizationStatusDenied: {
                photoRightStatus = PhotoAuthorizationStatusDenied;
            }break;
                
            case PHAuthorizationStatusAuthorized:{
                photoRightStatus = PhotoAuthorizationStatusAuthorized;
            }
        }
        authorizationStatus(photoRightStatus);
    }];
}

- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    if ([YZYPhotoDataManager getiOSVersion] >= __IPHONE_9_0) { // 这里有坑... iOS8系统下这个方法保存图片会失败
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [_assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation: image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
#pragma clang diagnostic pop
            if (error) {
                NSLog(@"保存图片失败:%@",error.localizedDescription);
                if (completion) {
                    completion(error);
                }
            } else {
                // 多给系统0.5秒的时间，让系统去更新相册数据
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        }];
    }
}


@end
