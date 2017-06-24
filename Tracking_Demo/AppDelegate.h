//
//  AppDelegate.h
//  Tracking_Demo
//
//  Created by Andy on 2017/6/24.
//  Copyright © 2017年 FL SMART. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WS(weakSelf,self) __weak __typeof(self) weakSelf = self
#define kFont(s) [UIFont fontWithName:@"Helvetica-Light" size:s]
//屏幕尺寸
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

