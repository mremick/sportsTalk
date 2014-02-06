//
//  ChatCell.h
//  trashTalkers
//
//  Created by Matt Remick on 11/16/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCellContentView.h"

@interface ChatCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *userLabel;
@property (nonatomic,retain) IBOutlet UITextView *textString;
@property (nonatomic,retain) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIView *avatarBackground;
@property (weak, nonatomic) IBOutlet ChatCellContentView *chatBubbleView;


@end
