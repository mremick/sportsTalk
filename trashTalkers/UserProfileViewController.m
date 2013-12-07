//
//  UserProfileViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/30/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadUser];
    
    //setting up the image temporarily
    self.userImage.image = [UIImage imageNamed:@"placeholder.jpg"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userNameLabel.text = self.userName;
    self.navigationItem.title = self.userName;

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
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
           
            self.user = objects;
            NSLog(@"USER: %@",self.user);
            self.favoriteTeams = [[self.user objectAtIndex:0] objectForKey:@"favoriteTeams"];
            self.shortBio = [[self.user objectAtIndex:0] objectForKey:@"shortBio"];

            self.favoriteTeamsLabel.text = self.favoriteTeams;
            self.shortBioLabel.text = self.shortBio; 

        }
        
        else {
            NSLog(@"An error occurred querying for a user");
        }
    }];
    
    
    
    //NSLog(@"SHORT BIO: %@",self.shortBio);
                                    

}

@end
