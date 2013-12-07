//
//  UserProfileViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/30/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UserProfileViewController : UIViewController

@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *favoriteTeams;
@property (strong,nonatomic) NSString *shortBio;

@property (strong,nonatomic) NSArray *user;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteTeamsLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortBioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end
