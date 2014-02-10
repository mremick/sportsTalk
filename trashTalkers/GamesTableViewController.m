//
//  GamesTableViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 2/6/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "GamesTableViewController.h"
#import <Parse/Parse.h>
#import "ChatViewController.h"
#import "ChatBubbleViewController.h"

@interface GamesTableViewController ()

@property (strong,nonatomic) NSMutableArray *games;


@end

@implementation GamesTableViewController

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
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.games = [NSMutableArray new];

    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    //NSLog(@"DATE: %@",dateString);
    
    
    
    PFQuery *gamesForLeague = [PFQuery queryWithClassName:@"Game"];
    [gamesForLeague whereKey:@"League" equalTo:self.leagueName];
    
    PFQuery *gamesForDate = [PFQuery queryWithClassName:@"Game"];
    [gamesForDate whereKey:@"gameDate" equalTo:dateString];
    
    [gamesForDate findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *returnedGames = objects;
            NSLog(@"returned games:%@",returnedGames);
            for (PFObject *game in returnedGames) {
                if ([[game objectForKey:@"leagueName"] isEqualToString:self.leagueName]) {
                    [self.games addObject:game];
                }
            }
            
            NSLog(@"games:%@",self.games);
            [self.tableView reloadData];
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
    PFObject *game = [self.games objectAtIndex:indexPath.row];
    
    NSString *stringForCell = [NSString stringWithFormat:@"%@ vs. %@",game[@"team1Name"],game[@"team2Name"]];
    
    cell.textLabel.text = stringForCell; 
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToChatroom"]) {
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        //ChatViewController *chatVC = (ChatViewController *)[segue destinationViewController];
        PFObject *game = [self.games objectAtIndex:selectedPath.row];
        NSString *gameName = [NSString stringWithFormat:@"%@ vs. %@",game[@"team1Name"],game[@"team2Name"]];
        ChatBubbleViewController *chatBubbleVC = (ChatBubbleViewController *)[segue destinationViewController];
        chatBubbleVC.gameName = gameName; 
        chatBubbleVC.selectedGame = [self.games objectAtIndex:selectedPath.row];
        

        
    }
}



@end
