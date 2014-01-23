//
//  MainViewController.m
//  JHEventTesting
//
//  Created by Jason Humphries on 1/21/14.
//  Copyright (c) 2014 Humphries Data Design. All rights reserved.
//

#import "MainViewController.h"
#import "CreateReminderViewController.h"
#import "AppDelegate.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, ReminderCreationDelegate>
@property (strong, nonatomic) IBOutlet UITableView *remindersTable;
@property (strong, nonatomic) NSArray *remindersArray;
@property (strong, nonatomic) CreateReminderViewController *createViewController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation MainViewController

#pragma mark <UITableViewDataSource>

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 64.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.remindersArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reminderCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reminderCell"];
    }
    EKReminder *cellReminder = self.remindersArray[indexPath.row];
    cell.textLabel.text = cellReminder.title;
    if (cellReminder.dueDateComponents) {
        NSString *dueDateString = [NSString stringWithFormat:@"%d-%d-%d", cellReminder.dueDateComponents.month, cellReminder.dueDateComponents.day, cellReminder.dueDateComponents.year];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Due: %@", dueDateString];
    }
    if (cellReminder.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EKReminder *selectedReminder = self.remindersArray[indexPath.row];
    if (!selectedReminder.completed) {
        [selectedReminder setCompletionDate:[NSDate date]];
    } else {
        selectedReminder.completionDate = nil;
    }
    [tableView reloadData];
}

#pragma mark - methods

//-(void)showACalendarsEvents
//{
//    // Get a calendar
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    // start date
//    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
//    oneDayAgoComponents.day = -1;
//    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
//                                                  toDate:[NSDate date]
//                                                 options:0];
//    
//    // end date
//    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
//    oneYearFromNowComponents.year = 1;
//    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
//                                                       toDate:[NSDate date]
//                                                      options:0];
//    
//    // predicate
//    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:oneDayAgo
//                                                                      endDate:oneYearFromNow
//                                                                    calendars:nil];
//    
//    // get all events matching the predicate
//    NSArray *eventsArray = [self.eventStore eventsMatchingPredicate:predicate];
//    
//    NSLog(@"eventsArray: %@", eventsArray);
//}

//-(void)setupForEvents
//{
//    self.eventStore = [[EKEventStore alloc] init];
//    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
//                                    completion:
//     ^(BOOL granted, NSError *error) {
//         if (!error) {
//             if (granted) {
//                 NSLog(@"GRANTED!");
//                 [self showACalendarsEvents];
//                 //                 [self showEventKitEventViewController];
//             } else {
//                 NSLog(@"NOT GRANTED!");
//             }
//         } else {
//             NSLog(@"error with event store access: %@", error);
//         }
//     }];
//}

-(void)showEventKitEventViewController
{
    [MY_APP_DELEGATE.mainEventStore requestAccessToEntityType:EKEntityTypeReminder
                                    completion:
     ^(BOOL granted, NSError *error) {
         NSLog(@"error?(%@)", error);
         dispatch_async(dispatch_get_main_queue(), ^{
             // show default event ui
             EKEventViewController *viewController = [[EKEventViewController alloc] init];
             //             viewController.event = anEvent;
             viewController.allowsEditing = YES;
             [self.navigationController presentViewController:viewController animated:YES completion:nil];
         });
     }];
}

-(void)fetchAllReminders
{
    NSPredicate *predicate = [MY_APP_DELEGATE.mainEventStore predicateForRemindersInCalendars:nil];
    [MY_APP_DELEGATE.mainEventStore fetchRemindersMatchingPredicate:predicate
                                          completion:
     ^(NSArray *reminders) {
         if (reminders.count > 0) {
             for (EKReminder *reminder in reminders) {
                 NSLog(@"reminder: %@", reminder.title);
             }
             self.remindersArray = reminders;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.remindersTable reloadData];
             });
         } else {
             NSLog(@"no reminders");
         }
         if ([self.refreshControl isRefreshing]) {
             [self.refreshControl endRefreshing];
         }
     }];
}

-(void)showCreateReminder
{
    [self.navigationController presentViewController:self.createViewController animated:YES completion:nil];
}

#pragma mark - creation delegate

-(void)createReminderFinished:(EKReminder*)reminder
{
    NSError *reminderErr;
    [MY_APP_DELEGATE.mainEventStore saveReminder:reminder
                                          commit:YES
                                           error:&reminderErr];
    if (reminderErr) {
        NSLog(@"error saving reminder: %@", reminderErr);
    } else {
        NSLog(@"reminder saved: %@", reminder);
    }
    [self fetchAllReminders];
}

#pragma mark - properties

-(CreateReminderViewController *)createViewController
{
    if (!_createViewController) {
        _createViewController = [[CreateReminderViewController alloc] init];
        _createViewController.reminderDelegate = self;
    }
    return _createViewController;
}

#pragma mark - VIEW CONTROLLER LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    self.title = @"Event Kit Testing";
    
//    UIBarButtonItem *createBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                                               target:self
//                                                                               action:@selector(showCreateReminder)];
//    
//    self.navigationItem.rightBarButtonItem = createBBI;
    
//    self.remindersTable = [[UITableView alloc] initWithFrame:self.view.bounds
//                                                       style:UITableViewStyleGrouped];
    self.remindersTable.delegate = self;
    self.remindersTable.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(fetchAllReminders) forControlEvents:UIControlEventValueChanged];
    [self.remindersTable addSubview:self.refreshControl];
    
//    [self.view addSubview:self.remindersTable];
    
    [self fetchAllReminders];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}


@end
