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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userNameLabel.text = self.userName;
    self.navigationController.title = self.userName; 
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
        }
        
        else {
            NSLog(@"An error occurred querying for a user");
        }
    }];
    
    self.favoriteTeams = [[self.user objectAtIndex:0] objectForKey:@"favoriteTeams"];
    self.shortBio = [[self.user objectAtIndex:0] objectForKey:@"shortBio"];
    
    //NSLog(@"FAVORITE TEAMS: %@",self.favoriteTeams);
    //NSLog(@"SHORT BIO: %@",self.shortBio);
                                    

}

@end
