# YZYPhotoPickerDemo
iOS 图片选择浏览框架，使用PhotoKit和AssetsLibrary双框架，兼容iOS 6 - 10，界面仿简书

![Image text](https://github.com/3KK3/ImageSource/raw/master/photoPicker1.jpg)

![Image text](https://github.com/3KK3/ImageSource/raw/master/photoPicker3.jpg)

```
   
    YZYPhotoPicker *photoPicker = [[YZYPhotoPicker alloc] init];
    
    [photoPicker showPhotoPickerWithController: self maxSelectCount: 4 completion:^(NSArray *imageSources, BOOL isImgType) {

        if (isImgType) { // 如果是UIImage

        } else {  // 是照片资源 iOS8 以下为AlAsset  iOS8以上为PHAsset
        
        }
    }];
```
