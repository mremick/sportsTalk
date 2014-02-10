//
//  SportsViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "SportsViewController.h"
#import <Parse/Parse.h>
#import "MSCellAccessory.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "GamesTableViewController.h"
#import "Reachability.h"

@interface SportsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *leaguesReturned;

@end

@implementation SportsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    PFUser *currenetUser = [PFUser currentUser];
    
    if (currenetUser) {
    }
    
    else {
        //perform segue to login view
        LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
        
        [self presentViewController:(LoginViewController *)loginViewController animated:YES completion:nil];
    }
    
    [SVProgressHUD show];
    
    PFQuery *leagueQuery = [PFQuery queryWithClassName:@"League"];
    [leagueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.leaguesReturned = objects;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            }];

            
        } else {
            NSLog(@"There was an error querying leagues");
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable)
        
    {
        // Write your code here.
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reachability" message:@"No internet connection found. Please check your internet status" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.leaguesReturned count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIColor *disclosureColor = [UIColor colorWithRed:0.167 green:0.630 blue:0.319 alpha:1.000];
    
    cell.textLabel.textColor = disclosureColor;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16.0];
    
    cell.textLabel.text = [[self.leaguesReturned objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gamesSegue"]) {
        GamesTableViewController *gamesVC = (GamesTableViewController *)[segue destinationViewController];
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        gamesVC.leagueName = [[self.leaguesReturned objectAtIndex:selectedPath.row] objectForKey:@"name"];
    }
}


- (IBAction)logOut:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self]; 
}
@end
