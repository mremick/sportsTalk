//
//  NASCARRacesViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/21/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "NASCARRacesViewController.h"
#import "ChatViewController.h"

@interface NASCARRacesViewController ()

@end

@implementation NASCARRacesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.games = [[NSMutableArray alloc] init];
    self.className = [[NSString alloc] init];
    
    PFQuery *gamesQuery = [PFQuery queryWithClassName:@"GameLists"];
    
    [gamesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSLog(@"OBJECTS: %@",objects);
            
            [self.games removeAllObjects];
            [self.games addObjectsFromArray:[[objects objectAtIndex:0] objectForKey:@"NASCARRaces"]];
            NSLog(@"Games: %@",self.games);
            NSLog(@"Games Count: %d",[self.games count]);
            [self.tableView reloadData];
            
        }
        
        else {
            NSLog(@"An error occurred!");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.games count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [self.games objectAtIndex:indexPath.row];
    
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatViewController *viewController = (ChatViewController *)segue.destinationViewController;
        NSIndexPath *chosenIndexPath = [self.tableView indexPathForSelectedRow];
        
        self.className = [[NSString alloc] initWithString:[NSString stringWithFormat:@"NASCAR%d",chosenIndexPath.row]];
        viewController.gameTitle = [self.games objectAtIndex:chosenIndexPath.row];

        NSLog(@"CLASSNAME (prepareForSegue): %@",self.className);
        viewController.className = [[NSString alloc] initWithString:self.className];
        //viewController.className = self.className;
        
        /* What John had*/
        PFObject *room = self.games[chosenIndexPath.row];
        viewController.room = room;
    }
}

@end
