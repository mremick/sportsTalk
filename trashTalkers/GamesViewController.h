//
//  GamesViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/16/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GamesViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *games;
@property (strong,nonatomic) NSString *className; 


@end
