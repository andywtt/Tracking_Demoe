//
//  UIImage+Extension.m
//
//
//  Created by Andy on 2016/11/7.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "UIImage+Extension.h"
#import <Photos/Photos.h>

@implementation UIImage (Extension)
+ (instancetype)imageWithBackgroundImageName:(NSString *)bgName log:(NSString *)logNmae {
    // 0. 加载背景图片
    UIImage *image = [UIImage imageNamed:bgName];
    
    // 1.创建bitmap上下文
    // 执行完这一行在内存中就相遇创建了一个UIImage
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    // 2.绘图图片
    // 绘制背景图片
    [image drawAtPoint:CGPointMake(0, 0)];
    
    // 绘制水印'
    
    UIImage *logImage = [UIImage imageNamed:logNmae];
    
    CGFloat margin = 10;
    CGFloat logY = margin;
    CGFloat logX = image.size.width - margin - logImage.size.width;
    [logImage drawAtPoint:CGPointMake(logX, logY)];
    
    //    NSString *str = @"黑马程序员";
    //    [str drawAtPoint:CGPointMake(150, 50) withAttributes:nil];
    
    // 3.获得图片
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

+ (instancetype)imageWithIcon:(UIImage *)icon border:(NSInteger)border color:(UIColor *)color {
    // 0. 加载原有图片
    UIImage *image = icon;
    
    // 1.创建图片上下文
    CGFloat margin = border;
    CGSize size = CGSizeMake(image.size.width + margin, image.size.height + margin);
    
    // YES 不透明 NO 透明
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    // 2.绘制大圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, size.width, size.height));
    [color set];
    CGContextFillPath(ctx);
    
    // 3.绘制小圆
    CGFloat smallX = margin * 0.5;
    CGFloat smallY = margin * 0.5;
    CGFloat smallW = image.size.width;
    CGFloat smallH = image.size.height;
    CGContextAddEllipseInRect(ctx, CGRectMake(smallX, smallY, smallW, smallH));
    //    [[UIColor greenColor] set];
    //    CGContextFillPath(ctx);
    // 4.指点可用范围, 可用范围的适用范围是在指定之后,也就说在在指定剪切的范围之前绘制的东西不受影响
    CGContextClip(ctx);
    
    // 5.绘图图片
    [image drawInRect:CGRectMake(smallX, smallY, smallW, smallH)];
    
    // 6.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

+ (instancetype)imageWithURL:(NSString *)url {
    NSURL *imageUrl = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    return [UIImage imageWithData:data];
}

+ (UIImage *)resizeImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat imageW = image.size.width * 0.5;
    CGFloat imageH = image.size.height * 0.5;
    //    image = [image stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW) resizingMode:UIImageResizingModeStretch];
    
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    return image;
}

+ (UIImage *)resizeImage2:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat imageW = image.size.width * 0.5;
    CGFloat imageHTop = image.size.height * 0.7;
    CGFloat imageHBottom = image.size.height * 0.2;
    //    image = [image stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageHTop, imageW, imageHBottom, imageW) resizingMode:UIImageResizingModeStretch];
    return image;
}

/**
 *  根据颜色生成纯色的图片
 *
 *  @param color 颜色
 *
 *  @return iamge
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  把图片变成灰色的
 *
 *  @param sourceImage 原来的图片
 *
 *  @return 改变后的灰色图片
 */
+ (UIImage *)grayImage:(UIImage *)sourceImage {
    int bitmapInfo = kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

/**
 *  得到图像显示完整后的宽度和高度
 *
 *  @param screenWidth  <#screenWidth description#>
 *  @param screenHeight <#screenHeight description#>
 *
 *  @return <#return value description#>
 */
- (CGRect)wl_getBigImageRectSizeWithScreenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight {
    CGFloat widthRatio = screenWidth / self.size.width;
    CGFloat heightRatio = screenHeight / self.size.height;
    CGFloat scale = MIN(widthRatio, heightRatio);
    CGFloat width = scale * self.size.width;
    CGFloat height = scale * self.size.height;
    return CGRectMake((screenWidth - width) / 2, (screenHeight - height) / 2, width, height);
}

- (UIImage*)zj_imageRotatedByAngle:(CGFloat)Angle {
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, Angle * M_PI / 180); //* M_PI / 180
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
