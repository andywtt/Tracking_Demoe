//
//  MovingAnnotation.m
//  CENNTRO
//
//  Created by Andy on 2017/6/24.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import "MovingAnnotation.h"
#import "TracingPoint.h"
#import "UIImage+Extension.h"
#import "AppDelegate.h"

@implementation MovingAnnotation {
    NSArray *moveArray;
    BOOL movingOver;
    NSInteger currentIndex;
    UIImage *annnationImage;
    
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate angle:(double)angle movePoints:(NSArray *)points {
    if (self == [super init]) {
        _coordinate = coordinate;
        _angle = angle;
        moveArray = [NSMutableArray arrayWithArray:points];
        movingOver = NO;
        currentIndex = 0;
        _pause = NO;
    }
    return self;
}

- (MKAnnotationView *)getMyAnnotationView:(MKMapView *)mapView {
    MKAnnotationView *annotationView = nil;
    annotationView = [self setupWithView:mapView identifier:@"CayAnnotation"];
    annnationImage = [UIImage imageNamed:@"Annotation_Car"];;
    annotationView.image = [annnationImage zj_imageRotatedByAngle:self.angle];
    self.annotationView = annotationView;
    return annotationView;
}

- (MKAnnotationView *)setupWithView:(MKMapView *)mapView identifier:(NSString *)identifer {
    MKAnnotationView *myView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifer];
    if (myView == nil) {
        myView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:identifer];
    }
    myView.draggable = NO;
    myView.canShowCallout = NO;
    return myView;
}

- (void)setCurrIndex:(int)currIndex {
    _currIndex = currIndex;
    currentIndex = _currIndex;
    
    NSInteger index = currentIndex % moveArray.count;
    TracingPoint *newLocation = moveArray[index];
    
    self.annotationView.image = [annnationImage zj_imageRotatedByAngle:newLocation.course];
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    self.coordinate = newCoordinate;
}

- (void)startMoving {
    NSInteger index = currentIndex % moveArray.count;
    TracingPoint *newLocation = moveArray[index];
    
    
    
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    if (!_pause) {
        WS(weakSelf, self);
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.coordinate = newCoordinate;
            currentIndex ++;
            
        } completion:^(BOOL finished) {
            weakSelf.annotationView.image = [annnationImage zj_imageRotatedByAngle:newLocation.course];
            if (currentIndex == moveArray.count) {
                movingOver = YES;
                _pause = NO;
                weakSelf.currIndex = 0;
                if (weakSelf.completion) {
                    weakSelf.completion(weakSelf, finished);
                }
            } else {
                [weakSelf startMoving];
            }
        }];
    }
    
}

- (void)setPause:(BOOL)pause {
    _pause = pause;
}

@end
