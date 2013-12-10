//
//  FriendsViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 12/9/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (strong,nonatomic) PFUser *currentUser;
@property (strong,nonatomic) NSMutableArray *friends; 

@end
