//
//  ChatBubbleViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 2/6/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "AMBubbleTableViewController.h"
#import <Parse/Parse.h>


@interface ChatBubbleViewController : AMBubbleTableViewController

@property (strong,nonatomic) PFObject *selectedGame;
@property (strong,nonatomic) NSString *gameName; 


@end
