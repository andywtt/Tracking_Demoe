//
//  CarAnnotation.h
//  
//
//  Created by Andy on 16/7/8.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface CarAnnotation : NSObject <MKAnnotation>
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end
