//
//  FriendsCell.h
//  trashTalkers
//
//  Created by Matt Remick on 2/5/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *avatarBackground;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;

@end
