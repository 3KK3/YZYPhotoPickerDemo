//
//  YZYPhotoDataManager.h
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/18.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *  const kPDMAlbumInfoImgKey;
extern NSString *  const kPDMAlbumInfoNameKey;
extern NSString *  const kPDMAlbumInfoCountKey;

typedef NS_ENUM(NSInteger , PhotoResolutionType) {
    ePhotoResolutionTypeOrigin,         // 原图
    ePhotoResolutionTypeThumb,          // 缩略图
    ePhotoResolutionTypeScreenSize,     // 屏幕尺寸
};

typedef NS_ENUM(NSInteger, PhotoAuthorizationStatus) {
    PhotoAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    PhotoAuthorizationStatusRestricted,        // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    PhotoAuthorizationStatusDenied,            // User has explicitly denied this application access to photos data.
    PhotoAuthorizationStatusAuthorized         // User has authorized this application to access photos data.
};

typedef void (^fetchResultBlock)(NSArray *);

/* ---------------- */

@interface YZYPhotoDataManager : NSObject
@property (nonatomic , assign) BOOL bReverse;

@property (nonatomic , assign) PhotoResolutionType resolutionType;

+ (instancetype)shareInstance;

/**
 *  获取全部相册列表数据：PHAssetCollection 或者 ALAssetsGroup
 */
- (void)fetchAllPhotoAlbumsList:(fetchResultBlock)result;

/**
 *  获取具体相册里的照片数据:PHAsset 或者 ALAsset
 */
- (void)fetchPhotoListOfAlbumData:(id)albumData result:(fetchResultBlock)result;

/**
 *  获取相机胶卷里的照片数据:PHAsset 或者 ALAsset
 */
- (void)fetchCameraRollPhotoList:(fetchResultBlock)result;

/**
 *  获取当天的照片数据:PHAsset 或者 ALAsset 需要优化
 */
- (void)fetchTodayPhotosList:(fetchResultBlock)result;

/**
 *  获取gif照片数据:PHAsset 或者 ALAsset
 */
- (void)fetchGifPhotosList:(fetchResultBlock)result;

/**
 *  获取当前相册照片数目
 */
- (NSUInteger)getCurrentAlbumPhotosCount;

/**
 *  获取相册数目
 */
- (NSUInteger)getAlbumsCount;

/* -----------  ------------ */

/**
 *  根据相册索引获取相册信息
 */
- (void)fetchAlbumInfoWithThumbImgSize:(CGSize)imgSize albumIndex:(NSInteger)nIndex fetchResult:(void (^)(NSDictionary *))result;

/**
 *  根据相册data获取相册信息
 */
- (void)fetchAlbumInfoWithThumbImgSize:(CGSize)imgSize albumData:(id)albumData fetchResult:(void (^)(NSDictionary *))result;

/*----------------- 照片处理-----------------------**/

/**
 *  根据照片分辨率、照片大小、照片资源 获取UIImage targetSize仅iOS8后支持
 */
- (void)fetchImageFromAsset:(id)asset type:(PhotoResolutionType)nType targetSize:(CGSize)size result:(void (^)(UIImage *))result;
/**
 *  根据照片分辨率、照片大小、照片索引 获取UIImage targetSize仅iOS8后支持
 */
- (void)fetchImageByIndex:(NSInteger)nIndex type:(PhotoResolutionType)nType  targetSize:(CGSize)size result:(void (^)(UIImage *))result;

/* ----------- 工具方法 ------------ */

/**
 *  根据索引获取照片资源 （kPDMAlbumInfoImgKey、kPDMAlbumInfoNameKey、kPDMAlbumInfoCountKey）
 */
- (id)getAssetAtIndex:(NSInteger)nIndex;

- (void)clearData;

+ (NSString *)getAssetIdentifier:(id)asset;

/**
 *  根据照片资源获取照片大小
 */
+ (CGSize)getImageSizeFromAsset:(id)asset;

/**
 *  相册权限状态
 */
+ (void)isPhotoLibraryVisible:(void(^)(PhotoAuthorizationStatus))authorazitionStatus;
+ (NSString *)getImageNameFromAsset:(id)asset;

+ (void)requestAuthorization:(void (^)(PhotoAuthorizationStatus))authorizationStatus;

/**
 *  写照片
 */
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

@end
