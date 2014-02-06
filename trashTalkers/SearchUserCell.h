//
//  SearchUserCell.h
//  trashTalkers
//
//  Created by Matt Remick on 2/5/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong,nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong,nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet UIView *avatarBackground;

@end
