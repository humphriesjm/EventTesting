//
//  AppDelegate.m
//  JHEventTesting
//
//  Created by Jason Humphries on 1/21/14.
//  Copyright (c) 2014 Humphries Data Design. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupEventStore];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)setupEventStore
{
    self.mainEventStore = [[EKEventStore alloc] init];
    [self.mainEventStore requestAccessToEntityType:EKEntityTypeReminder
                                    completion:
     ^(BOOL granted, NSError *error) {
         if (!error) {
             if (granted) {
                 NSLog(@"GRANTED!");
             } else {
                 NSLog(@"NOT GRANTED!");
             }
         } else {
             NSLog(@"error with event store access: %@", error);
         }
     }];
}

@end
