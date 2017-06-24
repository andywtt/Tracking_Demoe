//
//  MovingAnnotation.h
//  CENNTRO
//
//  Created by Andy on 2017/6/24.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class MovingAnnotation;

typedef void(^MovingAnnotationAnimationCompletion)(MovingAnnotation *moving, BOOL finished);

@interface MovingAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) double angle;
@property (nonatomic, strong) MKAnnotationView *annotationView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) int currIndex;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate angle:(double)angle movePoints:(NSArray *)points;
- (MKAnnotationView *)getMyAnnotationView:(MKMapView *)mapView;

/**
 开始动画
 */
- (void)startMoving;

/**
 是否暂停动画：NO=不暂停，YES=暂停
 */
@property (nonatomic, assign) BOOL pause;

@property (copy, nonatomic) MovingAnnotationAnimationCompletion completion;

@end
