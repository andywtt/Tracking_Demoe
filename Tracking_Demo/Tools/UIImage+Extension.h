//
//  UIImage+Extension.h
//
//
//  Created by Andy on 2016/11/7.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  生成水印
 *
 *  @param bgName  背景图片
 *  @param logNmae 水印图片
 *
 *  @return 生成好的图片(带水印的图片)
 */
+ (instancetype)imageWithBackgroundImageName:(NSString *)bgName log:(NSString *)logNmae;

/**
 *  生成头像
 *
 *  @param icon   头像图片名称
 *  @param border 头像边框大小
 *  @param color  头像边框的颜色
 *
 *  @return 生成好的头像
 */
+ (instancetype)imageWithIcon:(UIImage *)icon border:(NSInteger)border color:(UIColor *)color;


/**
 *  根据url请求图片
 *
 *  @param url  请求图片的url地址
 *
 *  @return image
 */
+ (instancetype)imageWithURL:(NSString *)url;

+ (UIImage *)resizeImage:(NSString *)imageName;

+ (UIImage *)resizeImage2:(NSString *)imageName;

/**
 *  根据颜色生成纯色的图片
 *
 *  @param color 颜色
 *
 *  @return iamge
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  把图片变成灰色的
 *
 *  @param sourceImage 原来的图片
 *
 *  @return 改变后的灰色图片
 */
+ (UIImage *)grayImage:(UIImage *)sourceImage;

/**
 *  得到图像显示完整后的宽度和高度
 *
 *  @param screenWidth  <#screenWidth description#>
 *  @param screenHeight <#screenHeight description#>
 *
 *  @return <#return value description#>
 */
- (CGRect)wl_getBigImageRectSizeWithScreenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight;

/**
 根据弧度旋转图片

 @param Angle 弧度
 @return 旋转后的图片
 */
- (UIImage*)zj_imageRotatedByAngle:(CGFloat)Angle;


@end
