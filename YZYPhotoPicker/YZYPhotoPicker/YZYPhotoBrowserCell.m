//
//  YZYPhotoBrowserCell.m
//  YZYPhotoPickerDemo
//
//  Created by 杨志勇 on 2016/10/20.
//  Copyright © 2016年 杨志勇. All rights reserved.
//

#import "YZYPhotoBrowserCell.h"
#import "YZYPhotoDataManager.h"
#import "UIView+Addition.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface YZYPhotoBrowserCell () <UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    CGFloat _aspectRatio;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageContainerView;
@end

@implementation YZYPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.contentView.width- 20, self.contentView.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor whiteColor];

        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        [_scrollView addSubview:_imageContainerView];
        _imageContainerView.backgroundColor = [UIColor whiteColor];

        self.contentView.backgroundColor = [UIColor whiteColor];
    
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
    }
    return self;
}

- (void)singleTap:(UITapGestureRecognizer *)tapGes {
    
}

- (void)setPhotoAsset:(id)photoAsset {
    _photoAsset = photoAsset;
    [_scrollView setZoomScale:1.0 animated:NO];
    
    [[YZYPhotoDataManager shareInstance] fetchImageFromAsset: photoAsset type: ePhotoResolutionTypeScreenSize targetSize: kScreenSize result:^(UIImage *photo) {
        self.imageView.image = photo;
        [self resizeSubviews];
    }];
}


- (void)resetUI {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    
    _imageContainerView.frame = CGRectZero;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.scrollView.height / self.scrollView.width) { // 以照片长为准
        
        CGFloat contentViewH = self.scrollView.height;
        CGFloat conteViewW = floor(contentViewH * image.size.width / image.size.height);
        _imageContainerView.frame = CGRectMake((self.scrollView.width - conteViewW) / 2, 0, conteViewW, contentViewH);
        
    } else {  //以照片宽为准
        CGFloat conteViewW = self.scrollView.width;
        CGFloat contentViewH = floor(conteViewW * image.size.height / image.size.width)  ;
        _imageContainerView.frame = CGRectMake(0, (_scrollView.height - contentViewH) / 2, conteViewW, contentViewH);
    }

    _scrollView.contentSize = CGSizeMake(self.scrollView.width, MAX(_imageContainerView.height, self.scrollView.height));
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.height <= self.scrollView.height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.contentView.frame.size.width / newZoomScale;
        CGFloat ysize = self.contentView.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

//#pragma mark - tool
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return _imgView;
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    CGFloat scale = MIN(kScreenSize.width / _imgView.frame.size.width, kScreenSize.height / _imgView.frame.size.height);
//    CGFloat imageH = scale* _imgView.frame.size.width;
//    CGFloat imageW = scale* _imgView.frame.size.width;
//    //self.imageView.frame = CGRectMake(0, 0, imageW, imageH);
//    _scrollView.contentInset = UIEdgeInsetsMake(0.5* (kScreenSize.height - imageH), 0.5* (kScreenSize.width - imageW), 0.5* (kScreenSize.height - imageH), 0.5* (kScreenSize.width - imageW));
//    _scrollView.contentSize = _imgView.frame.size;
//}
//
//- (void)zoomToMinAnim:(BOOL)animated {
//    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated: animated];
//}
//
//- (void)zoomToMaxWithPoint:(CGPoint)point {
//    CGRect imgShowRect = CGRectMake(0.5* (kScreenSize.width - _imgView.frame.size.width), 0.5* (kScreenSize.height - _imgView.frame.size.height), _imgView.frame.size.width, _imgView.frame.size.height);
//    
//    if (!CGRectContainsPoint(imgShowRect, point)) {
//        return;
//    }
//    CGRect rect = [self getRectWithScale:MAX( _scrollView.maximumZoomScale / [UIScreen mainScreen].scale, 1.0f) andCenter:point];
//    [_scrollView zoomToRect:rect animated:YES];
//    
//}
//
//- (void)adjustImageViewFrame:(UIImage*)image {
//    CGFloat scale = MIN(kScreenSize.width / image.size.width, kScreenSize.height / image.size.height);
//    CGFloat imageH = scale* image.size.height;
//    CGFloat imageW = scale* image.size.width;
//    _imgView.frame = CGRectMake(0, 0, imageW, imageH);
//    
//    _scrollView.contentInset = UIEdgeInsetsMake(0.5* (kScreenSize.height - imageH), 0.5* (kScreenSize.width - imageW), 0.5* (kScreenSize.height - imageH), 0.5* (kScreenSize.width - imageW));
//    _scrollView.contentSize = _imgView.frame.size;
//}
//
//- (CGRect)getRectWithScale:(float)scale andCenter:(CGPoint)center {
//    CGRect newRect;
//    newRect.size.width= _scrollView.frame.size.width/scale;
//    newRect.size.height= _scrollView.frame.size.height/scale;
//    newRect.origin.x= center.x-newRect.size.width/2;
//    newRect.origin.y =center.y-newRect.size.height/2;
//    return newRect;
//}

@end
