//
//  RidingRecordModel.h
//  UebikySmart
//
//  Created by Andy on 16/8/3.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "BaseModel.h"
#import <CoreLocation/CoreLocation.h>

@interface RidingRecordModel : BaseModel

@property (assign, nonatomic) CLLocationDegrees BLat;
@property (assign, nonatomic) CLLocationDegrees BLng;
@property (strong, nonatomic) NSString *ComTime;
@property (strong, nonatomic) NSString *id;
@property (assign, nonatomic) CLLocationDegrees Lat;
@property (assign, nonatomic) CLLocationDegrees Lng;

@end
