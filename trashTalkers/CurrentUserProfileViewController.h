//
//  CurrentUserProfileViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 12/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CurrentUserProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *favoriteTeamsLabel;
@property (weak, nonatomic) IBOutlet UITextView *shortBioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong,nonatomic) PFUser *userProfile; 

@end
