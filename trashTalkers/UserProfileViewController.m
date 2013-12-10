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
    [self loadFriends];
    
    //setting up the image temporarily
    self.userImage.image = [UIImage imageNamed:@"placeholder.jpg"];
    
    self.currentUser = [PFUser currentUser];
    
    NSLog(@"IS FRIEND: %d",[self isFriend:self.userProfile]); 
    
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
            
            self.userProfile = [self.user objectAtIndex:0];
            NSLog(@"USER: %@",self.userProfile);
            self.favoriteTeams = self.userProfile[@"favoriteTeams"];
            self.shortBio = self.userProfile[@"shortBio"];
            self.objectId = self.userProfile.objectId;
            
            self.favoriteTeamsLabel.text = self.favoriteTeams;
            self.shortBioLabel.text = self.shortBio;
            

        }
        
        else {
            NSLog(@"An error occurred querying for a user");
        }
    }];
    
    
    
    //NSLog(@"SHORT BIO: %@",self.shortBio);
                                    

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
            NSLog(@"FRIENDS: %@",self.friends);
        }
    }];
}

- (IBAction)addFriend:(id)sender {
    
    //self.userProfile
    PFRelation *friendsRelation = [self.currentUser relationforKey:@"friendsRelation"];
    
    NSLog(@"IS FRIEND: %d",[self isFriend:self.userProfile]);
    NSLog(@"OBJECT ID: %@",self.userProfile.objectId);
    
    //if they are a friend remove them
    if ([self isFriend:self.userProfile]) {
        //remove from array of freinds
        for (PFUser *friend in self.friends) {
            if ([friend.objectId isEqualToString:self.userProfile.objectId]) {
                [self.friends removeObject:self.userProfile];
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
    
    
}

//helper method to check is someone is a friend
- (BOOL)isFriend:(PFUser *)user
{
    NSLog(@"IS FRIEND?: %d",[self isFriend:self.userProfile]);
    //for in loop to iterate through all friends
    for (PFUser *friend in self.friends) {
        //comparing friends and all users and comparing their unique Ids
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
}
@end
