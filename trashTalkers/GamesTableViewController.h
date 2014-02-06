//
//  GamesTableViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 2/6/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface GamesTableViewController : UITableViewController

@property (strong,nonatomic) NSString *leagueName;
@property (strong,nonatomic) PFObject *leagueObject; 

@end
