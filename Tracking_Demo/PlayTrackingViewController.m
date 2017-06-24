//
//  PlayTrackingViewController.m
//  CENNTRO
//
//  Created by Andy on 2017/4/12.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import "PlayTrackingViewController.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

#import "CarAnnotation.h"
#import "RidingRecordModel.h"

#import "CLGeocoder+Extension.h"
#import "UIView+Extension.h"

// 轨迹播放相关的 Track playback related
#import "TracingPoint.h"
#import "MovingAnnotation.h"



@interface PlayTrackingViewController ()<MKMapViewDelegate>
@property (strong, nonatomic) NSMutableArray *dataArray;
/// map
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UILabel *kmKcalLabel;

@property (strong, nonatomic) UIView *playView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIView *slidView;
@property (strong, nonatomic) UISlider *sliderPlay;
/// start time and end time
@property (strong, nonatomic) UILabel *timeIntervalLabel;

/// back button
@property (strong, nonatomic) UIButton *backButton;

@property (strong, nonatomic) MKPolyline *commonPolyline;

@property (strong, nonatomic) CarAnnotation *startAnnotation;
@property (strong, nonatomic) CarAnnotation *endAnnotation;
@property (strong, nonatomic) MovingAnnotation *movingAnnotation;

@property (strong, nonatomic) NSTimer *playTimer;
/**
 *  当前数组的下标
 */
@property (assign, nonatomic) NSInteger index;


/** 是否在国内 */
@property (assign, nonatomic) BOOL isInCN;

@end

@implementation PlayTrackingViewController


#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.dataArray.count > 0) {
        RidingRecordModel *ridingModel1 = self.dataArray[0];
        
        WS(weakSelf, self);
        CLLocation *loca = [[CLLocation alloc] initWithLatitude:ridingModel1.BLat longitude:ridingModel1.BLng];
        CLGeocoder *geo = [[CLGeocoder alloc] init];
        [geo reverseGeocodeWithCLLocation:loca Block:^(BOOL isError, BOOL isInCHINA) {
            if (!isError && isInCHINA) {
                // 国内
                weakSelf.isInCN = YES;
                [weakSelf showRoute];
            } else if (!isError && !isInCHINA) {
                // abroad
                weakSelf.isInCN = NO;
                [weakSelf showRoute];
            }
        }];
        //////  END
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.playTimer) {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
    
    if (self.dataArray.count > 0 && self.movingAnnotation) {
        self.sliderPlay.value = 1;
        RidingRecordModel *ridingModel1 = self.dataArray[0];
        CLLocationCoordinate2D amapcoord1;
        if (_isInCN) {
            amapcoord1 = MKMapCoordinateConvertBaiDuToAMap(ridingModel1.BLat, ridingModel1.BLng);
        } else {
            amapcoord1 = [self wgs84frombd09:CLLocationCoordinate2DMake(ridingModel1.BLat, ridingModel1.BLng)];
        }
        
        self.movingAnnotation.coordinate = CLLocationCoordinate2DMake(amapcoord1.latitude, amapcoord1.longitude);
        self.playButton.selected = NO;
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
        self.index = 0;
        self.mapView.userInteractionEnabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.mapView];
    [self.mapView addSubview:self.kmKcalLabel];
    
    [self.view addSubview:self.playView];
    [self.playView addSubview:self.playButton];
    [self.playView addSubview:self.slidView];
    [self.slidView addSubview:self.sliderPlay];
    [self.playView addSubview:self.timeIntervalLabel];
    [self.view addSubview:self.backButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Delegate
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    NSString *startStr = @"Starting Point";
    NSString *endStr = @"End Point";
    if ([annotation isKindOfClass:[CarAnnotation class]] && [annotation.title isEqualToString:startStr]) {
        MKAnnotationView *annotationView =(MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        // 起点
        //判断复用池中是否有可用的
        if(annotationView==nil) {
            annotationView =(MKAnnotationView *)[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }
        annotationView.image = [UIImage imageNamed:@"record_qidian"];
        annotationView.width = 40;
        annotationView.height = 40;
        annotationView.centerOffset = CGPointMake(0, -18);
        //自定义大头针后，大头针是不可交互的，需要将canShowCallout设为YES方可再继续交互。
        annotationView.canShowCallout = YES;
        return annotationView;
    } else if ([annotation isKindOfClass:[CarAnnotation class]] && [annotation.title isEqualToString:endStr]) {
        MKAnnotationView *annotationView =(MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        // 终点
        //判断复用池中是否有可用的
        if(annotationView==nil) {
            annotationView =(MKAnnotationView *)[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }
        
        annotationView.image = [UIImage imageNamed:@"record_zhong"];
        annotationView.width = 40;
        annotationView.height = 40;
        annotationView.centerOffset = CGPointMake(0, -18);
        //自定义大头针后，大头针是不可交互的，需要将canShowCallout设为YES方可再继续交互。
        annotationView.canShowCallout = YES;
        return annotationView;
    } else if ([annotation isKindOfClass:[MovingAnnotation class]]) {
        
        return [(MovingAnnotation *)annotation getMyAnnotationView:mapView];
        
    } else if ([annotation isKindOfClass:[MKPointAnnotation class]] && [annotation.title isEqualToString:@""]) {
        MKAnnotationView *annotationView =(MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        // 所有点
        //判断复用池中是否有可用的
        if(annotationView==nil) {
            annotationView =(MKAnnotationView *)[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }
        
        annotationView.image = [UIImage imageNamed:@""];
        annotationView.width = 12;
        annotationView.height = 12;
        
        //自定义大头针后，大头针是不可交互的，需要将canShowCallout设为YES方可再继续交互。
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 5.f;
        polylineView.strokeColor = [UIColor colorWithRed:0.1755 green:0.5482 blue:0.9445 alpha:0.8];
        return polylineView;
    }
    return nil;
}


#pragma mark - Event Response
/**
 *  播放移动
 */
- (void)clickPlayButton:(UIButton *)btn {
    if (self.dataArray.count > 0 && self.movingAnnotation) {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.mapView.userInteractionEnabled = NO;
            // 播放
            self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(play:) userInfo:nil repeats:YES];
            self.movingAnnotation.pause = NO;
            [self.movingAnnotation startMoving];
        } else {
            // 暂停
            if (self.movingAnnotation && self.playTimer) {
                [self.playTimer invalidate];
                self.playTimer = nil;
                self.mapView.userInteractionEnabled = YES;
                self.movingAnnotation.pause = YES;
            }
        }
    } else {
        btn.selected = NO;
    }
}


- (void)play:(NSTimer *)playTimer {
    self.mapView.userInteractionEnabled = NO;
    CGFloat currentPoint = self.sliderPlay.value;
    NSInteger currentI = currentPoint;
    self.index = currentI-1;
    
    NSInteger endInt = self.sliderPlay.value + 1;
    if (endInt <= self.sliderPlay.maximumValue) {
        self.sliderPlay.value = endInt;
    } else {
        if (self.playTimer) {
            [self.playTimer invalidate];
            self.playTimer = nil;
            self.playButton.selected = NO;
            self.mapView.userInteractionEnabled = YES;
        }
    }
}

- (void)moveSliderPlay:(UISlider *)slider {
    
    if (self.playButton.selected || self.playTimer) {
        self.playButton.selected = NO;
        self.mapView.userInteractionEnabled = YES;
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
    
    self.movingAnnotation.pause = YES;
    
    CGFloat currentPoint = slider.value;
    NSInteger currentI = currentPoint;
    if (self.movingAnnotation) {
        self.movingAnnotation.currIndex = (int)currentI-1;
    }
}

- (void)showRoute {
    if (self.commonPolyline) {
        [self.mapView removeOverlay:self.commonPolyline];
    }
    
    if (self.startAnnotation) {
        [self.mapView removeAnnotation:self.startAnnotation];
    }
    
    if (self.endAnnotation) {
        [self.mapView removeAnnotation:self.endAnnotation];
    }
    
    if (self.movingAnnotation) {
        [self.mapView removeAnnotation:self.movingAnnotation];
    }
    
    if (self.array.count > 0) {
        NSMutableArray *pointArray = [NSMutableArray new];
        //构造折线数据对象
        CLLocationCoordinate2D commonPolylineCoords[self.dataArray.count];
        for (int i = 0; i < self.dataArray.count; i++) {
            RidingRecordModel *ridingModel = self.dataArray[i];
            CLLocationCoordinate2D amapcoord;
            if (_isInCN) {
                amapcoord = MKMapCoordinateConvertBaiDuToAMap(ridingModel.BLat, ridingModel.BLng);
            } else {
                amapcoord = [self wgs84frombd09:CLLocationCoordinate2DMake(ridingModel.BLat,ridingModel.BLng)];
            }
            commonPolylineCoords[i].latitude = amapcoord.latitude;
            commonPolylineCoords[i].longitude = amapcoord.longitude;
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = amapcoord;
            point.title = @"";
            [pointArray addObject:point];
        }
        
        
        self.commonPolyline = [MKPolyline polylineWithCoordinates:commonPolylineCoords count:self.dataArray.count];
        
        //在地图上添加折线对象  add overlay
        [_mapView addOverlay:self.commonPolyline];
        
        // 添加起点标注  add starting point
        RidingRecordModel *ridingModel1 = self.dataArray[0];
        CLLocationCoordinate2D amapcoord1;
        if (_isInCN) {
            amapcoord1 = MKMapCoordinateConvertBaiDuToAMap(ridingModel1.BLat, ridingModel1.BLng);
        } else {
            amapcoord1 = [self wgs84frombd09:CLLocationCoordinate2DMake(ridingModel1.BLat,ridingModel1.BLng)];
        }
        self.startAnnotation = [[CarAnnotation alloc] init];
        NSString *startStr = @"Starting Point";
        self.startAnnotation.title = startStr;
        
        self.startAnnotation.coordinate = CLLocationCoordinate2DMake(amapcoord1.latitude, amapcoord1.longitude);
        [self.mapView addAnnotation:self.startAnnotation];
        self.mapView.centerCoordinate = amapcoord1;
        
        // 添加终点标注 add end point
        RidingRecordModel *ridingModel2 = self.dataArray[self.dataArray.count-1];
        CLLocationCoordinate2D amapcoord2;
        if (_isInCN) {
            amapcoord2 = MKMapCoordinateConvertBaiDuToAMap(ridingModel2.BLat, ridingModel2.BLng);
        } else {
            amapcoord2 = [self wgs84frombd09:CLLocationCoordinate2DMake(ridingModel2.BLat,ridingModel2.BLng)];
        }
        self.endAnnotation = [[CarAnnotation alloc] init];
        NSString *endStr = @"End Point";
        self.endAnnotation.title = endStr;
        self.endAnnotation.coordinate = CLLocationCoordinate2DMake(amapcoord2.latitude, amapcoord2.longitude);
        [self.mapView addAnnotation:self.endAnnotation];
        
        [self.mapView showAnnotations:pointArray animated:YES];
        
        NSArray *movePoints = [self getMovePointWitnMapPoints:pointArray];
        TracingPoint *tracingPoint = (TracingPoint *)movePoints.firstObject;
        // 添加移动点标注  add moving point
        self.movingAnnotation = [[MovingAnnotation alloc] initWithCoordinate:tracingPoint.coordinate angle:tracingPoint.course movePoints:movePoints];
        [self.mapView addAnnotation:self.movingAnnotation];
        
        WS(weakSelf, self);
        self.movingAnnotation.completion = ^(MovingAnnotation *moving, BOOL finished) {
            if (finished) {
                weakSelf.playButton.selected = NO;
                weakSelf.mapView.userInteractionEnabled = YES;
                weakSelf.sliderPlay.value = 1;
                if (weakSelf.playTimer) {
                    [weakSelf.playTimer invalidate];
                    weakSelf.playTimer = nil;
                }
            }
        };
        
        self.sliderPlay.minimumValue = 1;
        self.sliderPlay.maximumValue = self.dataArray.count;

    }
}

/**
 获取需要动画的点
 */
- (nonnull NSArray *)getMovePointWitnMapPoints:(nonnull NSArray *)pointArray {
    NSMutableArray *moveArray = [NSMutableArray new];
    for (int i = 0; i < pointArray.count-1; i++) {
        // 第一个点 first
        MKAnnotationView *annotation = pointArray[i];
        CLLocationDegrees latitude1 = annotation.annotation.coordinate.latitude;
        CLLocationDegrees longitude1 = annotation.annotation.coordinate.longitude;
        CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(latitude1, longitude1);
        
        // 下一个点 next
        MKAnnotationView *annotation2 = pointArray[i+1];
        CLLocationDegrees latitude2 = annotation2.annotation.coordinate.latitude;
        CLLocationDegrees longitude2 = annotation2.annotation.coordinate.longitude;
        CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(latitude2, longitude2);
        
        TracingPoint *tracingPoint = [[TracingPoint alloc] init];
        tracingPoint.coordinate = coordinate1;
        tracingPoint.course = [self calculateCourseFromCoordinate:coordinate1 to:coordinate2];
        [moveArray addObject:tracingPoint];
    }
    
    MKAnnotationView *annotation = pointArray[pointArray.count-1];
    CLLocationDegrees latitude1 = annotation.annotation.coordinate.latitude;
    CLLocationDegrees longitude1 = annotation.annotation.coordinate.longitude;
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(latitude1, longitude1);
    
    // end tracking point
    TracingPoint *tracingPoint = [[TracingPoint alloc] init];
    tracingPoint.coordinate = coordinate1;
    tracingPoint.course = ((TracingPoint *)[moveArray lastObject]).course;
    [moveArray addObject:tracingPoint];
    return moveArray;
}

#pragma mark - HTTP Request



#pragma mark - Private Methods
/**
 *  两个时间差的计算
 *
 *  @param startTime 小时间
 *  @param endTime   大时间
 *
 *  @return 返回 0 或者 1 或者 自定义
 */
- (NSInteger)contrastStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    dateFomatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *expireDateStr = endTime;
    // 当前时间字符串格式
    NSString *nowDateStr = startTime;
    NSDate *expireDate = [dateFomatter dateFromString:expireDateStr];
    // 当前时间data格式
    NSDate *nowDate = [dateFomatter dateFromString:nowDateStr];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 对比时间差
    NSDateComponents *dateCom = [calendar components:unit fromDate:nowDate toDate:expireDate options:0];
//    DEBUGLOG(@"*******************    %ld, %ld, %ld, %ld, %ld, %ld", dateCom.year, dateCom.month, dateCom.day, dateCom.hour, dateCom.minute, dateCom.second);
    if (dateCom.hour > 0) {
        return 1;
    } else if (dateCom.second == 14) {
        return 1;
    }
    return 0;
}
- (NSMutableAttributedString *)setAttributedStringWithStringFirst:(NSString *)str1 stringSecond:(NSString *)str2 {
    NSString *str = [NSString stringWithFormat:@"%@ %@", str1, str2];
    
    // 确定文字的颜色区分
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    UIFont *font = kFont(20);
    UIFont *font2 = kFont(14);
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.3296 green:0.3296 blue:0.3296 alpha:1.0] range:NSMakeRange(0, str.length)];
    [attStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, str1.length)];
    [attStr addAttribute:NSFontAttributeName value:font2 range:NSMakeRange(str1.length, str2.length)];
    
    return attStr;
}
- (NSAttributedString *)getKMKcalNumberWithTotalKM:(CGFloat)totalKM {
    NSString *totalKMStr = [NSString stringWithFormat:@"  %.1f", totalKM];
    NSString *kmStr = @"km";
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", totalKMStr, kmStr]];
    
    UIFont *font = kFont(42);
    UIFont *font2 = kFont(14);
    
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, totalKMStr.length)];
    [attStr addAttribute:NSFontAttributeName value:font2 range:NSMakeRange(totalKMStr.length, attStr.length - totalKMStr.length)];
    
    return attStr;
}


#pragma mark - Getters And Setters
- (void)setTimeInterval:(NSString *)timeInterval {
    _timeInterval = timeInterval;
    self.timeIntervalLabel.text = [NSString stringWithFormat:@"%@    %@", @"Beginning and ending time", _timeInterval];
}

- (void)setTotalKM:(CGFloat)totalKM {
    self.kmKcalLabel.attributedText = [self getKMKcalNumberWithTotalKM:totalKM];
}

- (void)setArray:(NSArray<RidingRecordModel *> *)array {
    _array = array;
    if (_array.count > 1) {
        self.dataArray = [NSMutableArray arrayWithArray:_array];
    }
}

/**
 *  地图
 *
 *  @return 地图
 */
- (MKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-106)];
        _mapView.delegate = self;
        [_mapView setShowsUserLocation:NO];
        [_mapView setMapType:MKMapTypeStandard];
    }
    return _mapView;
}

- (UILabel *)kmKcalLabel {
    if (_kmKcalLabel == nil) {
        _kmKcalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.mapView.height - 54, self.mapView.width, 54)];
        _kmKcalLabel.textAlignment = NSTextAlignmentLeft;
        _kmKcalLabel.attributedText = [self getKMKcalNumberWithTotalKM:0.00];
        _kmKcalLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    }
    return _kmKcalLabel;
}

- (UIView *)playView {
    if (_playView == nil) {
        _playView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame), kScreenWidth, 106)];
        _playView.backgroundColor = [UIColor whiteColor];
    }
    return _playView;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(15, 20, 40, 40);
        [_playButton setBackgroundImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"play_stop"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIView *)slidView {
    if (_slidView == nil) {
        _slidView = [[UIView alloc] initWithFrame:CGRectMake(70, 20, self.playView.width - 70 - 15, 40)];
        _slidView.clipsToBounds = YES;
        _slidView.layer.cornerRadius = 20;
        _slidView.backgroundColor = [UIColor colorWithRed:0.9655 green:0.9654 blue:0.9654 alpha:1.0];
    }
    return _slidView;
}

- (UISlider *)sliderPlay {
    if (_sliderPlay == nil) {
        _sliderPlay = [[UISlider alloc] initWithFrame:CGRectMake(12, 4.5f, self.slidView.width-24, 31)];
        _sliderPlay.minimumTrackTintColor = [UIColor grayColor];
        _sliderPlay.maximumTrackTintColor = [UIColor colorWithRed:0.302 green:0.6745 blue:0.9686 alpha:1.0];
        [_sliderPlay addTarget:self action:@selector(moveSliderPlay:) forControlEvents:UIControlEventValueChanged];
        _sliderPlay.minimumValue = 0;
        _sliderPlay.maximumValue = 0;
    }
    return _sliderPlay;
}

- (UILabel *)timeIntervalLabel {
    if (_timeIntervalLabel == nil) {
        _timeIntervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.playButton.frame), self.playView.width-30, self.playView.height-CGRectGetMaxY(self.playButton.frame))];
        _timeIntervalLabel.textColor = [UIColor grayColor];
        _timeIntervalLabel.textAlignment = NSTextAlignmentLeft;
        _timeIntervalLabel.font = kFont(14);
    }
    return _timeIntervalLabel;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 20, 44, 44);
        [_backButton setImage:[UIImage imageNamed:@"gps_back_gray"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBaseBackBotton) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _backButton;
}

- (void)clickBaseBackBotton {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Other tool function -  从工具类中拷贝出来的。。。。。。
const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
/**
 百度地图坐标转高德地图坐标
 */
CLLocationCoordinate2D MKMapCoordinateConvertBaiDuToAMap(double bd_lat, double bd_lon) {
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    double gd_lon = z * cos(theta);
    double gd_lat = z * sin(theta);
    return CLLocationCoordinate2DMake(gd_lat, gd_lon);
}

//static double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
// π
static double pi = 3.1415926535897932384626;
// 长半轴
static double a = 6378245.0;
// 扁率
static double ee = 0.00669342162296594323;

/*
 * 百度坐标系(BD-09)  转  WGS坐标
 */
- (CLLocationCoordinate2D)wgs84frombd09:(CLLocationCoordinate2D)bd09Coord{
    
    
    return [self wgs84fromgcj02:[self gcj02frombd09:bd09Coord]];
}
/*
 * WGS坐标  转   百度坐标系(BD-09)
 */
- (CLLocationCoordinate2D)bd09fromwgs84:(CLLocationCoordinate2D)wgs84Coord{
    
    return [self bd09fromgcj02:[self gcj02fromwgs84:wgs84Coord]];
}

/*
 * 百度坐标系(BD-09)  转  火星坐标系(GCJ-02)  已验证
 */
- (CLLocationCoordinate2D)gcj02frombd09:(CLLocationCoordinate2D)bd09Coord{
    
    double bd_lon = bd09Coord.longitude;
    double bd_lat = bd09Coord.latitude;
    
    double x = bd_lon - 0.0065;
    double y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    double gg_lng = z * cos(theta);
    double gg_lat = z * sin(theta);
    
    return CLLocationCoordinate2DMake(gg_lat, gg_lng);
}
/*
 * 火星坐标系(GCJ-02)  转   百度坐标系(BD-09)
 */
- (CLLocationCoordinate2D)bd09fromgcj02:(CLLocationCoordinate2D)gcj02Coord{
    double lng = gcj02Coord.longitude;
    double lat = gcj02Coord.latitude;
    
    double z = sqrt(lng * lng + lat * lat) + 0.00002 * sin(lat * x_pi);
    double theta = atan2(lat, lng) + 0.000003 * cos(lng * x_pi);
    double bd_lng = z * cos(theta) + 0.0065;
    double bd_lat = z * sin(theta) + 0.006;
    
    return CLLocationCoordinate2DMake(bd_lat, bd_lng);;
}

/*
 * GCJ02(火星坐标系)  转  WGS84坐标
 */
- (CLLocationCoordinate2D)wgs84fromgcj02:(CLLocationCoordinate2D)gcj02Coord{
    if ([self out_of_china:(gcj02Coord)]) {
        return gcj02Coord;
    }
    double lng = gcj02Coord.longitude;
    double lat = gcj02Coord.latitude;
    
    double dlat = [self latTransFormfromCoord:CLLocationCoordinate2DMake(lat - 35.0, lng - 105.0)];
    double dlng = [self lngTransFormfromCoord:CLLocationCoordinate2DMake(lat - 35.0, lng - 105.0)];
    
    double radlat = lat / 180.0 * pi;
    double magic = sin(radlat);
    magic = 1 - ee * magic * magic;
    double sqrtmagic = sqrt(magic);
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi);
    dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * pi);
    double mglat = lat + dlat;
    double mglng = lng + dlng;
    
    return CLLocationCoordinate2DMake(lat * 2 - mglat, lng * 2 - mglng);
}

/*
 * WGS84坐标  转  GCJ02(火星坐标系)
 */
- (CLLocationCoordinate2D)gcj02fromwgs84:(CLLocationCoordinate2D)wgs84Coord{
    if ([self out_of_china:(wgs84Coord)]) {
        return wgs84Coord;
    }
    double lng = wgs84Coord.longitude;
    double lat = wgs84Coord.latitude;
    
    double dlat = [self latTransFormfromCoord:CLLocationCoordinate2DMake(lat - 35.0, lng - 105.0)];
    double dlng =[self lngTransFormfromCoord:CLLocationCoordinate2DMake(lat - 35.0, lng - 105.0)];
    
    double radlat = lat / 180.0 * pi;
    double magic = sin(radlat);
    magic = 1 - ee * magic * magic;
    double sqrtmagic = sqrt(magic);
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi);
    dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * pi);
    double mglat = lat + dlat;
    double mglng = lng + dlng;
    
    return CLLocationCoordinate2DMake(mglat, mglng);
    
    
}
/**
 * 纬度转换
 */
- (double)latTransFormfromCoord:(CLLocationCoordinate2D)coord{
    
    double lng = coord.longitude;
    double lat = coord.latitude;
    
    double ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 *sqrt(fabs(lng));
    ret += (20.0 * sin(6.0 * lng * pi) + 20.0 * sin(2.0 * lng * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(lat * pi) + 40.0 * sin(lat / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(lat / 12.0 * pi) + 320 * sin(lat * pi / 30.0)) * 2.0 / 3.0;
    
    return ret;
}
/**
 * 经度转换
 */
- (double)lngTransFormfromCoord:(CLLocationCoordinate2D)coord{
    double lng = coord.longitude;
    double lat = coord.latitude;
    
    double ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * sqrt(fabs(lng));
    ret += (20.0 * sin(6.0 * lng * pi) + 20.0 * sin(2.0 * lng * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(lng * pi) + 40.0 * sin(lng / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(lng / 12.0 * pi) + 300.0 * sin(lng / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
    
}

/**
 * 判断是否在国内，不在国内不做偏移
 */
- (BOOL)out_of_china:(CLLocationCoordinate2D)coord{
    if (coord.latitude < 72.004 || coord.longitude > 137.8347) {
        return YES;
    } else if (coord.latitude  < 0.8293 || coord.latitude  > 55.8271) {
        return YES;
    }
    return NO;
}

#pragma mark - 计算转向角度

- (CLLocationDirection)calculateCourseFromMapPoint:(MKMapPoint)p1 to:(MKMapPoint)p2 {
    //20级坐标y轴向下，需要反过来。
    MKMapPoint dp = MKMapPointMake(p2.x - p1.x, p1.y - p2.y);
    
    if (dp.y == 0)
    {
        return dp.x < 0? 270.f:0.f;
    }
    
    double dir = atan(dp.x/dp.y) * 180.f / M_PI;
    
    if (dp.y > 0)
    {
        if (dp.x < 0)
        {
            dir = dir + 360.f;
        }
        
    }else
    {
        dir = dir + 180.f;
    }
    
    return dir;
}

- (CLLocationDirection)calculateCourseFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2 {
    MKMapPoint p1 = MKMapPointForCoordinate(coord1);
    MKMapPoint p2 = MKMapPointForCoordinate(coord2);
    
    return [self calculateCourseFromMapPoint:p1 to:p2];
}

- (CLLocationDirection)fixNewDirection:(CLLocationDirection)newDir basedOnOldDirection:(CLLocationDirection)oldDir {
    //the gap between newDir and oldDir would not exceed 180.f degrees
    CLLocationDirection turn = newDir - oldDir;
    if(turn > 180.f)
    {
        return newDir - 360.f;
    }
    else if (turn < -180.f)
    {
        return newDir + 360.f;
    }
    else
    {
        return newDir;
    }
    
}


@end
