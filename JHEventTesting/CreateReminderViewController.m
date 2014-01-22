//
//  CreateReminderViewController.m
//  JHEventTesting
//
//  Created by Jason Humphries on 1/21/14.
//  Copyright (c) 2014 Humphries Data Design. All rights reserved.
//

#import "CreateReminderViewController.h"
#import "AppDelegate.h"

@interface CreateReminderViewController () <UITextFieldDelegate, UIPickerViewDelegate>
@property (strong, nonatomic) UILabel *startLabel;
@property (strong, nonatomic) UITextField *titleField;
@end

@implementation CreateReminderViewController

-(id)init
{
    if (!self) {
        self = [super init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64.f)];
    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:@"Create Reminder"];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    titleItem.rightBarButtonItem = doneItem;
    navBar.items = @[titleItem];
    [self.view addSubview:navBar];
    
    // initialize reminder
    self.reminder = [EKReminder reminderWithEventStore:MY_APP_DELEGATE.mainEventStore];
    self.reminder.calendar = [MY_APP_DELEGATE.mainEventStore defaultCalendarForNewReminders];
    
    // reminder title
    self.reminder.title = @"Default Title";
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(20, 84, 320, 60)];
    self.titleField.placeholder = @"Enter Reminder Title Here";
    self.titleField.delegate = self;
    [self.view addSubview:self.titleField];
    
    // reminder start
    UIDatePicker *startPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 144.f, 320.f, 122.f)];
    self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 360.f, 300.f, 60.f)];
    [self.view addSubview:self.startLabel];
    startPicker.datePickerMode = UIDatePickerModeDateAndTime;
    [startPicker addTarget:self
                   action:@selector(changeStartDate:)
         forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:startPicker];
    
    NSDateComponents *tomorrowComponents = [[NSDateComponents alloc] init];
    tomorrowComponents.day = 1;
    tomorrowComponents.month = 0;
    tomorrowComponents.year = 0;
//    NSDate *tomorrowDate = [calendar dateByAddingComponents:tomorrowComponents
//                                                     toDate:[NSDate date]
//                                                    options:0];
    self.reminder.startDateComponents = tomorrowComponents;
    
    // reminder end
    NSDateComponents *twoDaysComponents = [[NSDateComponents alloc] init];
    twoDaysComponents.day = 2;
    twoDaysComponents.month = 0;
    twoDaysComponents.year = 0;
    self.reminder.dueDateComponents = twoDaysComponents;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length] > 0) {
        self.reminder.title = textField.text;
    }
    return YES;
}

- (void)changeStartDate:(UIDatePicker*)picker
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	self.startLabel.text = [NSString stringWithFormat:@"%@",
                            [df stringFromDate:picker.date]];
}

-(void)doneAction
{
    NSLog(@"doneAction");
    if ([self.titleField.text length] > 0) {
        self.reminder.title = self.titleField.text;
        [self.reminderDelegate createReminderFinished:self.reminder];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Nothing entered"
                                    message:@"" delegate:nil cancelButtonTitle:@"Try again"
                          otherButtonTitles:nil, nil] show];
    }
}

@end
