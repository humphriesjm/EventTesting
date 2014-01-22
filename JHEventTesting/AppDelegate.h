//
//  AppDelegate.h
//  JHEventTesting
//
//  Created by Jason Humphries on 1/21/14.
//  Copyright (c) 2014 Humphries Data Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <EventKit/EventKit.h>

#define MY_APP_DELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) EKEventStore *mainEventStore;

@end
