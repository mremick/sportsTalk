//
//  AppDelegate.m
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

/* Need to test the app delegate methods on an actual device*/

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"kYmwfwIJgcjSqPSJb3ma87F92jX1XB3yrewOmAwb"
                  clientKey:@"2uMxJJOrtqc5x35C0XU4KEQ5JwDzOWlzWt6ylVfE"];
            
    //Analytics for app opens
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"Online"] = @"Online";
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Online status should have been changed on Parse");
        }
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"Online"] = @"Offline";
    [currentUser save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"Online"] = @"Offline";
    
    [currentUser save];
    NSLog(@"BG");
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"Online"] = @"Offline";
    [currentUser save];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"AC");
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"Online"] = @"Online";
    [currentUser save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"Online"] = @"Offline";
    [currentUser save];
}











@end
