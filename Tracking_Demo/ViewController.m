//
//  ViewController.m
//  Tracking_Demo
//
//  Created by Andy on 2017/6/24.
//  Copyright © 2017年 FL SMART. All rights reserved.
//

#import "ViewController.h"
#import "PlayTrackingViewController.h"
#import "RidingRecordModel.h"
#import "NSDictionary+Extension.h"

@interface ViewController ()

/**
 gps list
 */
@property (strong, nonatomic) NSArray *gpsList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickGoButton:(UIButton *)sender {
    PlayTrackingViewController *vc = [PlayTrackingViewController new];
    vc.array = [NSMutableArray arrayWithArray:self.gpsList];
    vc.timeInterval = @"12:17 - 12:22";
    vc.totalKM = 0.5;
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSArray *)gpsList {
    if (_gpsList == nil) {
        NSDictionary *dict = @{
                               @"gpsList" :@[
                                       @{
                                           @"BLat" : @"29.621390279158",
                                           @"BLng" : @"120.872151352547",
                                           @"ComTime" : @"2017/6/22 12:17:13",
                                           @"Lat" : @"29.61796667",
                                           @"Lng" : @"120.86163167",
                                           @"id" : @"6308",
                                       },
                                       @{
                                           @"BLat" : @"29.621365077714",
                                           @"BLng" : @"120.871908964264",
                                           @"ComTime" : @"2017/6/22 12:17:16",
                                           @"Lat" : @"29.61793667",
                                           @"Lng" : @"120.86139",
                                           @"id" : @"6309",
                                       },
                                       @{
                                           @"BLat" : @"29.621679420286",
                                           @"BLng" : @"120.871526298315",
                                           @"ComTime" : @"2017/6/22 12:17:46",
                                           @"Lat" : @"29.61824333",
                                           @"Lng" : @"120.86100833",
                                           @"id" : @"6310",
                                       },
                                       @{
                                           @"BLat" : @"29.621968460389",
                                           @"BLng" : @"120.87149632075",
                                           @"ComTime" : @"2017/6/22 12:17:55",
                                           @"Lat" : @"29.61853167",
                                           @"Lng" : @"120.86097833",
                                           @"id" : @"6311",
                                       },
                                       @{
                                           @"BLat" : @"29.622598221393",
                                           @"BLng" : @"120.871351155207",
                                           @"ComTime" : @"2017/6/22 12:18:16",
                                           @"Lat" : @"29.61915833",
                                           @"Lng" : @"120.86083333",
                                           @"id" : @"6312",
                                       },
                                       @{
                                           @"BLat" : @"29.623023810711",
                                           @"BLng" : @"120.871329614722",
                                           @"ComTime" : @"2017/6/22 12:18:27",
                                           @"Lat" : @"29.61958333",
                                           @"Lng" : @"120.86081167",
                                           @"id": @"6313",
                                       },
                                       @{
                                           @"BLat" : @"29.623450967034",
                                           @"BLng" : @"120.871567149121",
                                           @"ComTime" : @"2017/6/22 12:18:49",
                                           @"Lat" : @"29.620015",
                                           @"Lng" : @"120.86104833",
                                           @"id" : @"6314",
                                       },
                                       @{
                                           @"BLat" : @"29.62347356578",
                                           @"BLng" : @"120.87168918259",
                                           @"ComTime" : @"2017/6/22 12:18:55",
                                           @"Lat" : @"29.62004",
                                           @"Lng" : @"120.86117",
                                           @"id" : @"6315",
                                       },
                                       @{
                                           @"BLat" : @"29.623215198898",
                                           @"BLng" : @"120.872190529857",
                                           @"ComTime" : @"2017/6/22 12:19:23",
                                           @"Lat" : @"29.61979167",
                                           @"Lng" : @"120.86167",
                                           @"id" : @"6316",
                                       },
                                       @{
                                           @"BLat" : @"29.622649982228",
                                           @"BLng" : @"120.872273860614",
                                           @"ComTime" : @"2017/6/22 12:19:37",
                                           @"Lat" : @"29.61922833",
                                           @"Lng" : @"120.86175333",
                                           @"id" : @"6317",
                                       },
                                       @{
                                           @"BLat" : @"29.622199887124",
                                           @"BLng" : @"120.872353913416",
                                           @"ComTime" : @"2017/6/22 12:19:49",
                                           @"Lat" : @"29.61878",
                                           @"Lng" : @"120.86183333",
                                           @"id" : @"6318",
                                       },
                                       @{
                                           @"BLat" : @"29.621817110106",
                                           @"BLng" : @"120.872402248282",
                                           @"ComTime" : @"2017/6/22 12:19:55",
                                           @"Lat" : @"29.61839833",
                                           @"Lng" : @"120.86188167",
                                           @"id" : @"6319",
                                       },
                                       @{
                                           @"BLat" : @"29.621778799317",
                                           @"BLng" : @"120.872400558877",
                                           @"ComTime" : @"2017/6/22 12:20:04",
                                           @"Lat" : @"29.61836",
                                           @"Lng" : @"120.86188",
                                           @"id" : @"6320",
                                       }
                                            ],
                               };
        NSArray *array = [dict getArray:@"gpsList"];
        NSMutableArray *mArray = [NSMutableArray new];
        for (NSDictionary *subDict in array) {
            RidingRecordModel *model = [RidingRecordModel initWithDictionary:subDict];
            [mArray addObject:model];
        }
        _gpsList = [NSArray arrayWithArray:mArray];
    }
    return _gpsList;
}


/*
 
 {
 beginDate = "2017-06-22 12:17:27";
 endDate = "2017-06-22 12:22:49";
 gpsList =             (
 {
 BLat = "29.621390279158";
 BLng = "120.872151352547";
 ComTime = "2017/6/22 12:17:13";
 Lat = "29.61796667";
 Lng = "120.86163167";
 id = 6308;
 },
 {
 BLat = "29.621365077714";
 BLng = "120.871908964264";
 ComTime = "2017/6/22 12:17:16";
 Lat = "29.61793667";
 Lng = "120.86139";
 id = 6309;
 },
 {
 BLat = "29.621679420286";
 BLng = "120.871526298315";
 ComTime = "2017/6/22 12:17:46";
 Lat = "29.61824333";
 Lng = "120.86100833";
 id = 6310;
 },
 {
 BLat = "29.621968460389";
 BLng = "120.87149632075";
 ComTime = "2017/6/22 12:17:55";
 Lat = "29.61853167";
 Lng = "120.86097833";
 id = 6311;
 },
 {
 BLat = "29.622598221393";
 BLng = "120.871351155207";
 ComTime = "2017/6/22 12:18:16";
 Lat = "29.61915833";
 Lng = "120.86083333";
 id = 6312;
 },
 {
 BLat = "29.623023810711";
 BLng = "120.871329614722";
 ComTime = "2017/6/22 12:18:27";
 Lat = "29.61958333";
 Lng = "120.86081167";
 id = 6313;
 },
 {
 BLat = "29.623450967034";
 BLng = "120.871567149121";
 ComTime = "2017/6/22 12:18:49";
 Lat = "29.620015";
 Lng = "120.86104833";
 id = 6314;
 },
 {
 BLat = "29.62347356578";
 BLng = "120.87168918259";
 ComTime = "2017/6/22 12:18:55";
 Lat = "29.62004";
 Lng = "120.86117";
 id = 6315;
 },
 {
 BLat = "29.623215198898";
 BLng = "120.872190529857";
 ComTime = "2017/6/22 12:19:23";
 Lat = "29.61979167";
 Lng = "120.86167";
 id = 6316;
 },
 {
 BLat = "29.622649982228";
 BLng = "120.872273860614";
 ComTime = "2017/6/22 12:19:37";
 Lat = "29.61922833";
 Lng = "120.86175333";
 id = 6317;
 },
 {
 BLat = "29.622199887124";
 BLng = "120.872353913416";
 ComTime = "2017/6/22 12:19:49";
 Lat = "29.61878";
 Lng = "120.86183333";
 id = 6318;
 },
 {
 BLat = "29.621817110106";
 BLng = "120.872402248282";
 ComTime = "2017/6/22 12:19:55";
 Lat = "29.61839833";
 Lng = "120.86188167";
 id = 6319;
 },
 {
 BLat = "29.621778799317";
 BLng = "120.872400558877";
 ComTime = "2017/6/22 12:20:04";
 Lat = "29.61836";
 Lng = "120.86188";
 id = 6320;
 }
 );
 nub = 3;
 }
 
 */


@end
