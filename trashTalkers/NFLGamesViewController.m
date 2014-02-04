//
//  NFLGamesViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/20/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "NFLGamesViewController.h"
#import "ChatViewController.h"


@interface NFLGamesViewController ()

@property (strong,nonatomic) NSMutableArray *roomNames;
@property (strong,nonatomic) NSMutableArray *roomCount;

@end

@implementation NFLGamesViewController


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
            [self.games addObjectsFromArray:[[objects objectAtIndex:0] objectForKey:@"NFLGames"]];

            [self.tableView reloadData];
            
        }
        
        else {
            NSLog(@"An error occurred!");
        }
    }];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.roomNames = [NSMutableArray new];

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
    
    cell.textLabel.text = [self.games objectAtIndex:indexPath.row];

    
    
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatViewController *viewController = (ChatViewController *)segue.destinationViewController;
        NSIndexPath *chosenIndexPath = [self.tableView indexPathForSelectedRow];
        
        self.className = [[NSString alloc] initWithString:[NSString stringWithFormat:@"NFL%d",chosenIndexPath.row]];
        
        viewController.gameTitle = [self.games objectAtIndex:chosenIndexPath.row];
        viewController.className = [[NSString alloc] initWithString:self.className];
        
        self.className = self.games[chosenIndexPath.row];
        //increment the number of users
        
        PFObject *room = self.games[chosenIndexPath.row];
        viewController.room = room;
    }
}

@end
