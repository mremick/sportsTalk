//
//  ChatCell.h
//  trashTalkers
//
//  Created by Matt Remick on 11/16/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell
{
    IBOutlet UILabel *userLabel;
    IBOutlet UITextView *textString;
    IBOutlet UILabel *timeLabel;
}

@property (strong,retain) IBOutlet UILabel *userLabel;
@property (strong,retain) IBOutlet UITextView *textString;
@property (strong,retain) IBOutlet UILabel *timeLabel; 


@end
