//
//  UserProfileViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/30/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EditProfileViewController.h"

@interface UserProfileViewController : UIViewController

@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *favoriteTeams;
@property (strong,nonatomic) NSString *shortBio;
@property (strong,nonatomic) NSString *objectId;
@property (strong,nonatomic) NSString *lastChatRoom;
@property (strong,nonatomic) NSString *onlineStatus;
@property (strong,nonatomic) NSString *location;

@property (strong,nonatomic) NSArray *user;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteTeamsLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortBioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *lastChatRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

//properties to add friends

@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
- (IBAction)addFriend:(id)sender;

@property (strong,nonatomic) PFFile *imageFile; 
@property (strong,nonatomic) PFUser *userProfile; 
@property (strong,nonatomic) PFUser *currentUser;
@property (strong,nonatomic) NSMutableArray *friends;
@property (strong,nonatomic) NSMutableArray *convertedFriends; 
- (BOOL)isFriend:(PFUser *)user;

@end
