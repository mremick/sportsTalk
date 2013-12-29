//
//  SportsViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "SportsViewController.h"
#import <Parse/Parse.h>
#import "GamesViewController.h"
#import "MSCellAccessory.h"

@interface SportsViewController ()

@end

@implementation SportsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    
    PFUser *currenetUser = [PFUser currentUser];
    
    if (currenetUser) {
        NSLog(@"Current User: %@",currenetUser.username);
    }
    
    else {
        //perform segue to login view
        [self performSegueWithIdentifier:@"showLogin" sender:self]; 
    }
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    NSLog(@"VIEW DID LOAD CALLED!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
}
 */

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIColor *disclosureColor = [UIColor colorWithRed:0.2274 green:0.7647 blue:0.3568 alpha:1.0];
    
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor];
    
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showGames" sender:indexPath];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
}


*/
- (IBAction)logOut:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self]; 
}
@end
