//
//  UserProfileViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/30/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIImageView+ParseFileSupport.h"
#import "SVProgressHUD.h"
#import "SportsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UserProfileViewController ()

@property (strong,nonatomic) NSString *postCountString;
@property (strong,nonatomic) SportsViewController *sportsVC;
- (IBAction)backButtonSelected:(id)sender;
//@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;

@end

@implementation UserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //setting up the image temporarily
    self.userImage.image = [UIImage imageNamed:@"placeholder.jpg"];
    
    self.currentUser = [PFUser currentUser];
    
    self.editProfileButton.layer.masksToBounds = YES;
    self.editProfileButton.layer.cornerRadius = 20.0;
    [self.editProfileButton.layer setBorderWidth:2.0];
    [self.editProfileButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.addFriendButton.layer.masksToBounds = YES;
    self.addFriendButton.layer.cornerRadius = 20.0;
    [self.addFriendButton.layer setBorderWidth:2.0];
    [self.addFriendButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    
    
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.cornerRadius = 65;
    
    [self.userImage.layer setBorderWidth:3.0];
    [self.userImage.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
        
        //pop them to chat room
    

    
    self.favoriteTeamsLabel.text = @"";
    self.shortBioLabel.text = @"";
    
    NSLog(@"IN USER PROFILE");
    NSLog(@"USERNAME:%@",self.userName);
    
    [self loadUser];
    [self loadPostsCount];
    
    [self loadFriends];
    
    [super viewWillAppear:animated];
    
    self.userNameLabel.text = self.userName;
    self.navigationItem.title = self.userName;
    self.editProfileButton.hidden = YES;
    
}

- (void)buttonTitleMethod
{
    if ([self isFriend:self.userProfile]) {
        self.addFriendButton.titleLabel.text = [NSString stringWithFormat:@"Unfollow"];
        self.addFriendButton.titleLabel.textColor = [UIColor whiteColor];
    }
    
    else {
        self.addFriendButton.titleLabel.text = [NSString stringWithFormat:@"Follow"];
        self.addFriendButton.titleLabel.textColor = [UIColor whiteColor];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUser
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.userName];
    
    [SVProgressHUD showWithStatus:@"Loading User"];
    
    

    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
           
            self.user = objects;
            
            //assiging properties
            self.userProfile = [self.user objectAtIndex:0];
            
            self.favoriteTeams = self.userProfile[@"favoriteTeams"];
            self.shortBio = self.userProfile[@"shortBio"];
            self.lastChatRoom = self.userProfile[@"lastChatRoom"];
            self.onlineStatus = self.userProfile[@"Online"];
            self.imageFile = self.userProfile[@"avatar"];
            self.location = self.userProfile[@"location"];
            self.objectId = self.userProfile.objectId;
            
            
            //setting labels text
            self.favoriteTeamsLabel.text = self.favoriteTeams;
            self.shortBioLabel.text = self.shortBio;
            self.lastChatRoomLabel.text = [NSString stringWithFormat:@"Last Chatroom in: %@",self.lastChatRoom];
            self.onlineStatusLabel.text = self.onlineStatus;
            self.userImage.file = self.imageFile;
            self.locationLabel.text = self.location;
            

        }
        
        else {
            NSLog(@"An error occurred querying for a user");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkForCurrentUser];
            [SVProgressHUD dismiss];
        });
    }];
    
}

- (void)checkForCurrentUser
{
    PFUser *currentUser = [PFUser currentUser];
    
    NSLog(@"check for current user called");
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.addFriendButton.hidden = YES;
        self.editProfileButton.hidden = YES;
    } else {
        if ([currentUser.objectId isEqualToString:self.userProfile.objectId]) {
            self.addFriendButton.hidden = YES;
            self.editProfileButton.hidden = NO;
            
        }
        
        else {
            self.addFriendButton.hidden = NO;
            self.editProfileButton.hidden = YES;
        }

    }
    
}

- (void)loadFriends
{
    self.friends = [NSMutableArray array];
    PFRelation *relation = [[PFUser currentUser] relationforKey:@"friendsRelation"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if (error) {
            NSLog(@"Error fetvhing friends");
        }
        
        else {
            [self.friends addObjectsFromArray:results];

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self buttonTitleMethod];

        });
    }];
    
    //[self performSelector:@selector(buttonTitleMethod) withObject:nil afterDelay:2.0];
}

- (IBAction)addFriend:(id)sender {
    
    //self.userProfile
    PFRelation *friendsRelation = [self.currentUser relationforKey:@"friendsRelation"];
    
    //if they are a friend remove them
    NSLog(@"IS FRIEND:%d",[self isFriend:self.userProfile]);
    if ([self isFriend:self.userProfile]) {
        //remove from array of freinds
        for (PFUser *friend in self.friends) {
            if ([friend.objectId isEqualToString:self.userProfile.objectId]) {
                [self.friends removeObject:self.userProfile];
                

                /*
                NSString *message = [NSString stringWithFormat:@"%@ has been removed from your friends",friend.username];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Removed"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                 
                 */
                
                self.addFriendButton.titleLabel.text = @"Add Friend";
                
                break;
            }
        }
        
        [friendsRelation removeObject:self.userProfile];
    }
    
    //add them as a friend
    else {
        //add them as a friend
        [self.friends addObject:self.userProfile];
        
        //adding a relation or friend using PFRelation, save it asyncrounously
        [friendsRelation addObject:self.userProfile];
        
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@",error,[error userInfo]);
        }
    }];
    
    [self performSelector:@selector(buttonTitleMethod) withObject:nil afterDelay:2.0];

}

- (BOOL)isFriend:(PFUser *)user
{
    for (PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
            break;
        }
    }
    
    return NO;
}

- (void)loadPostsCount
{
    PFRelation *postsForUser = [PFUser currentUser][@"Posts"];
    
    [postsForUser.query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.postCountString = [NSString new];
            self.postCountString = [NSString stringWithFormat:@"%d Posts",number];
            self.postsLabel.text = self.postCountString;
        } else {
            self.postsLabel.text = @"error retrieving posts";
        }
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editProfile"]) {
        EditProfileViewController *vc = [segue destinationViewController];
        vc.bio = self.shortBio;
        vc.favoriteTeams = self.favoriteTeams;
        vc.userName = self.userName;
        vc.location = self.location; 
        vc.image = self.userImage.image;
    }
}
- (IBAction)backButtonSelected:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
