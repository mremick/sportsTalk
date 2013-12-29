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

@interface CurrentUserProfileViewController ()

@end

@implementation CurrentUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUser
{
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
                self.favoriteTeamsLabel.text = self.userProfile[@"favoriteTeams"];
                self.shortBioLabel.text = self.userProfile[@"shortBio"];
                self.userImage.file = self.userProfile[@"avatar"];
                self.locationLabel.text = self.userProfile[@"location"];
                [SVProgressHUD dismiss];
            });
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

@end
