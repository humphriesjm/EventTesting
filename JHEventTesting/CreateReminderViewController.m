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
@property (strong, nonatomic) UIBarButtonItem *doneBBI;
@property (strong, nonatomic) UIBarButtonItem *cancelBBI;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UINavigationItem *titleItem;
@end

@implementation CreateReminderViewController

-(void)awakeFromNib
{
//    if (!self) {
//        self = [super init];
//    }
    self.cancelBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.doneBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
//    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320.f, 64.f)];
    self.titleItem = [[UINavigationItem alloc] initWithTitle:@"Create Reminder"];
    self.doneBBI.enabled = NO;
    self.titleItem.rightBarButtonItem = self.doneBBI;
    self.titleItem.leftBarButtonItem = self.cancelBBI;
    self.navBar.items = @[self.titleItem];
    [self.view addSubview:self.navBar];
    
    // initialize reminder
    self.reminder = [EKReminder reminderWithEventStore:MY_APP_DELEGATE.mainEventStore];
    self.reminder.calendar = [MY_APP_DELEGATE.mainEventStore defaultCalendarForNewReminders];
    
    // reminder title
    self.reminder.title = @"No Title";
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
    tomorrowComponents.day = 23;
    tomorrowComponents.month = 1;
    tomorrowComponents.year = 2014;
//    NSDate *tomorrowDate = [calendar dateByAddingComponents:tomorrowComponents
//                                                     toDate:[NSDate date]
//                                                    options:0];
    self.reminder.startDateComponents = tomorrowComponents;
    
    // reminder end
    NSDateComponents *twoDaysComponents = [[NSDateComponents alloc] init];
    twoDaysComponents.day = 24;
    twoDaysComponents.month = 1;
    twoDaysComponents.year = 2014;
    self.reminder.dueDateComponents = twoDaysComponents;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length] > 0) {
        self.reminder.title = textField.text;
        self.doneBBI.enabled = YES;
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *wholeString = [textField.text stringByAppendingString:string];
    if (wholeString.length > 0) {
        self.doneBBI.enabled = YES;
    } else {
        self.doneBBI.enabled = NO;
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

-(void)cancelAction
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
