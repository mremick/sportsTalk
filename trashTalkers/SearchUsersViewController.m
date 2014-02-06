//
//  SearchUsersViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 2/5/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "BBTableView.h"
#import <Parse/Parse.h>
#import "SearchUserCell.h"
#import "UIImageView+ParseFileSupport.h"

@interface SearchUsersViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (strong,nonatomic) NSArray *userResponse;
@property (strong,nonatomic) NSMutableArray *nonAnonUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchUsersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nonAnonUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    PFUser *returnedUser = [self.nonAnonUsers objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor colorWithRed:0.201 green:0.764 blue:0.380 alpha:1.000];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.201 green:0.764 blue:0.380 alpha:1.000];
    
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.avatarImageView.layer.cornerRadius = 32;
    
    cell.avatarBackground.layer.masksToBounds = YES;
    cell.avatarBackground.layer.cornerRadius = 33;
    
    cell.usernameLabel.text = returnedUser.username;
    cell.bio.text = returnedUser[@"shortBio"];
    cell.avatarImageView.file = returnedUser[@"avatar"];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"return selected");
    
    [self.searchBar resignFirstResponder];
    
    self.userResponse = [NSArray new];
    self.nonAnonUsers = [NSMutableArray new];
    
    PFQuery *usersQuery = [PFUser query];
    [usersQuery whereKey:@"username" containsString:self.searchBar.text];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSLog(@"OBJECTS: %@",objects);
            self.userResponse = objects;
            
            for (PFUser *user in self.userResponse) {
                if (user.username.length < 20) {
                    [self.nonAnonUsers addObject:user];
                }
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }
    }];
    
    return YES;
    
}

@end
