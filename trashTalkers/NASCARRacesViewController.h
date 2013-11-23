//
//  NASCARRacesViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/21/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NASCARRacesViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *games;
@property (strong,nonatomic) NSString *className; 

@end
