//
//  FriendsViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 12/9/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "FriendsViewController.h"
#import "UIImageView+ParseFileSupport.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friends = [NSMutableArray array];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currentUser = [PFUser currentUser];
    
    PFRelation *relation = [[PFUser currentUser] relationforKey:@"friendsRelation"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if (error) {
            NSLog(@"Error fetvhing friends");
        }
        
        else {
            [self.friends removeAllObjects];
            [self.friends addObjectsFromArray:results];
            NSLog(@"FRIENDS: %@",self.friends);
            [self.tableView reloadData];
        }
    }];
    
    [self performSelector:@selector(reloadTheTable) withObject:nil afterDelay:1.0];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTheTable
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFUser *friend = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = friend.username;
    
    if (friend[@"avatar"]) {
        cell.imageView.file = friend[@"avatar"];
    }
    
    else {
        cell.imageView.image = [UIImage imageNamed:@"avatar.png"];
    }
    
    
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserProfileViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFUser *friend = [self.friends objectAtIndex:indexPath.row];
        vc.userName = friend.username;
    }
}

 

@end
