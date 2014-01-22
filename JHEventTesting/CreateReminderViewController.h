//
//  CreateReminderViewController.h
//  JHEventTesting
//
//  Created by Jason Humphries on 1/21/14.
//  Copyright (c) 2014 Humphries Data Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@protocol ReminderCreationDelegate <NSObject>
-(void)createReminderFinished:(EKReminder*)reminder;
@optional
@property (strong, nonatomic) NSString *title;
@end

@interface CreateReminderViewController : UIViewController
@property (strong, nonatomic) EKReminder *reminder;
@property (strong, nonatomic) id <ReminderCreationDelegate> reminderDelegate;
@end
