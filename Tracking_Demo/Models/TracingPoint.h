//
//  TracingPoint.h
//  CENNTRO
//
//  Created by Andy on 2017/6/24.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TracingPoint : NSObject

/*!
 @brief 轨迹经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/*!
 @brief 方向，有效范围0~359.9度
 */
@property (nonatomic) CLLocationDirection course;

@end
