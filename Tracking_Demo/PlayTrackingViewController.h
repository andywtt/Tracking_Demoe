//
//  PlayTrackingViewController.h
//  CENNTRO
//
//  Created by Andy on 2017/4/12.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RidingRecordModel;

@interface PlayTrackingViewController : UIViewController

/// point array
@property (strong, nonatomic) NSArray<RidingRecordModel *> *array;

/// time interval
@property (strong, nonatomic) NSString *timeInterval;

/** total km */
@property (assign, nonatomic) CGFloat totalKM;

@end
