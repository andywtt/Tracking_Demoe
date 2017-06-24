//
//  CLGeocoder+Extension.h
//  CENNTRO
//
//  Created by Andy on 2017/6/13.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLGeocoder (Extension)
/**
 *  反编译GPS坐标点 判断坐标点位置是否在中国境内
 *
 *  @param location GPS坐标点
 *  @param block    isError 是否出错 /  isINCHINA 是否在中国境内
 */
- (void)reverseGeocodeWithCLLocation:(CLLocation *)location Block:(void (^)(BOOL isError, BOOL isInCHINA))block;
@end
