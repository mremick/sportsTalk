//
//  CurrentUserProfileViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 12/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "CurrentUserProfileViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+ParseFileSupport.h"
#import "EditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CurrentUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *avatarBackground;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
- (IBAction)goBackButtonSelected:(id)sender;
@property (strong,nonatomic) NSString *postCountString;
@property (weak, nonatomic) IBOutlet UILabel *postsLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastChatRoomLabel;

@end

@implementation CurrentUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.cornerRadius = 65;
    [self.userImage.layer setBorderWidth:2.5];
    [self.userImage.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.editProfileButton.layer.masksToBounds = YES;
    self.editProfileButton.layer.cornerRadius = 20.0f;
    
    [[self.editProfileButton layer] setBorderWidth:1.0f];
    [[self.editProfileButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self loadUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUser
{
    
    //disable edit profile button
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        self.editProfileButton.hidden = YES;
        self.userNameLabel.text = @"Anonymous";
        self.bioLabel.text = @"Anonymous users don't get a bio :)";
        self.postsLabel.text = @"0 posts";
        self.locationLabel.text = @"Being Anonymous";
        self.userImage.image = [UIImage imageNamed:@"blackIcon.png"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to View Your Profile"
                                                        message:@"Please create an account to be able to customzise a profile"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
        
        
        
        
        //[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        
        //[self performSegueWithIdentifier:@"fromFriendsToSports" sender:nil];
        
        
    } else {
        
        self.editProfileButton.hidden = NO;
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:currentUser.username];
        
        [SVProgressHUD showWithStatus:@"Loading Profile"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                self.userProfile = [objects objectAtIndex:0];
                
                //assign objects based on a success
                dispatch_async(dispatch_get_main_queue(), ^{
                    //assign labels in the UI here on the main thread
                    self.userNameLabel.text = self.userProfile.username;
                    self.bioLabel.text = self.userProfile[@"shortBio"];
                    self.userImage.file = self.userProfile[@"avatar"];
                    self.locationLabel.text = self.userProfile[@"location"];
                    self.onlineStatusLabel.text = self.userProfile[@"Online"];
                    self.lastChatRoomLabel.text = [NSString stringWithFormat:@"Last Chatroom seen in: %@",self.userProfile[@"lastChatRoom"]];
                    [SVProgressHUD dismiss];
                });
            }
        }];
        
        [self loadUserPosts];


    }
    
    
}

- (void)loadUserPosts
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
        vc.bio = self.shortBioLabel.text;
        vc.favoriteTeams = self.favoriteTeamsLabel.text;
        vc.userName = self.userNameLabel.text;
        vc.image = self.userImage.image;
    }
}


- (IBAction)goBackButtonSelected:(id)sender {
    
    [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.view.frame = CGRectMake(self.view.frame.size.width * .8, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];

}
@end
