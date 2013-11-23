//
//  ChatViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/19/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "ChatViewController.h"

#define MAX_ENTRIES_LOADED 25


@interface ChatViewController ()

@end

@implementation ChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    NSLog(@"TESTING CLASS NAME: %@",self.className); 
    
	// Do any additional setup after loading the view.
    self.tfEntry.delegate = self;
    self.tfEntry.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self registerForKeyboardNotifications];
    
    //Implementing the pull to refresh view
    
    if (self.refreshheaderView == nil) {
        PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.chatTable.bounds.size.height, self.view.frame.size.width, self.chatTable.bounds.size.height)];
        view.delegate = self;
        [self.chatTable addSubview:view];
        self.refreshheaderView = view;
    }
    
    //update the last update
    [self.refreshheaderView refreshLastUpdatedDate];
}

-(void)createClassName:(NSString *)classname
{
    self.className = classname;
    NSLog(@"createClassName Called! #1");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.chatData = [[NSMutableArray alloc] init];
    [self loadLocalChat];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Chat Textfield

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"The text: %@",self.tfEntry.text);
    [textField resignFirstResponder];
    [self.tfEntry resignFirstResponder]; 
}

- (IBAction)backgroundTap:(id)sender
{
    [self.tfEntry resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"The text: %@",self.tfEntry.text);
    [textField resignFirstResponder];
    
    if ([self.tfEntry.text length] > 0) {
        
        //updating the table immeadiately
        
        NSArray *objects = [NSArray arrayWithObjects:self.tfEntry.text,[PFUser currentUser].username,[NSDate date], nil];
        NSArray *keys = [NSArray arrayWithObjects:@"text",@"userName",@"date", nil];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        [self.chatData addObject:dictionary];
        
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        
        [self.chatTable beginUpdates];
        
        [self.chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        
        [self.chatTable endUpdates];
        [self.chatTable reloadData];
        
        NSLog(@"CLASSNAME (TextFieldShouldreturn): %@",self.className);
        
        //going for the parsing
        PFObject *newMessage = [PFObject objectWithClassName:self.className];
        [newMessage setObject:self.tfEntry.text forKey:@"text"];
        [newMessage setObject:[PFUser currentUser].username forKey:@"userName"];
        [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage saveInBackground];
        self.tfEntry.text = @"";

    }
    
    //reload the data
    [self loadLocalChat];
    
    return NO;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification                                               object:nil];
}

- (void)freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSLog(@"Keyboard was shown!");
    
    //move keyboard here.
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSLog(@"Keyboard will hide!");
    
    //return keyboard here 
}


#pragma mark - Refresh Table View Methods / Data Source Loading / Reloading methods

- (void)reloadTableViewDataSource
{
    //shoule be call the tableview's data source model to reload
    //put here just for demo
    
    self.reloading = YES;
    [self loadLocalChat];
    [self.chatTable reloadData];
}

- (void)doneLoadingTableViewData
{
    //model should call this when it's done loading
    self.reloading = NO;
    [self.refreshheaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.chatTable];
}

#pragma mark - ScrollView Delegate Methods 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshheaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshheaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeader Delegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(PF_EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(PF_EGORefreshTableHeaderView *)view
{
    //should return if data source model is reloading
    return self.reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(PF_EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:@"chatCellIdentifier"];
    
    //think the row problem may be occuring here...
    NSUInteger row = [self.chatData count]-[indexPath row]-1;

    
    if (row < [self.chatData count]) {
        NSString *chatText = [[self.chatData objectAtIndex:row] objectForKey:@"text"];
        NSString *theUserName = [[self.chatData objectAtIndex:row] objectForKey:@"userName"];
        
        //a lot of formatting code after this that I'm skipping for now
        
        
        NSDate *theDate = [[self.chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:theDate];
        
        cell.textLabel.text = chatText;
        cell.timeLabel.text = timeString;
        cell.userLabel.text = theUserName; 
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[self.chatData objectAtIndex:self.chatData.count-indexPath.row-1] objectForKey:@"text"];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 40;
}

#pragma mark - Parse! 

//need to find where this is called
- (void)loadLocalChat
{
    NSLog(@"CLASSNAME (loadLocalChat): %@",self.className);
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    //if no objects are loaded in memory, we look to the cache first to fill the table
    //and the subsequently do a query against the network
    
    if ([self.chatData count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"Successfully retrieved %d chats from cache",[objects count]);
                [self.chatData removeAllObjects];
                [self.chatData addObjectsFromArray:objects];
                [self.chatTable reloadData];
                NSLog(@"CHAT DATA: %@",self.chatData);

            }
            
            else {
                NSLog(@"An error occured loading chat from cache");
            }
        }];
    }
    
    __block int totalNumberOfEntries = 0;
    PFQuery *countQuery = [PFQuery queryWithClassName:self.className];
    [countQuery orderByAscending:@"createdAt"];
    [countQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSLog(@"There are currently %d entries",number);
            totalNumberOfEntries = number;
            
            if (totalNumberOfEntries > [self.chatData count]) {
                //NSLog(@"Retrieving data");
                int theLimit;
                
                if ((totalNumberOfEntries - [self.chatData count]) > MAX_ENTRIES_LOADED) {
                    theLimit = MAX_ENTRIES_LOADED;
                }
                
                else {
                    theLimit = totalNumberOfEntries - [self.chatData count];
                }
                
                //there may be a problem here
                countQuery.limit = theLimit;
                
                //new query may neeb to be declared here..
                
                [countQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        //find succeeded
                        NSLog(@"Successfully retrieved %d chats",[objects count]);
                        [self.chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        
                        NSLog(@"CHAT DATA: %@",self.chatData);
                        
                        for (int ind = 0; ind < [objects count]; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        
                        [self.chatTable beginUpdates];
                        [self.chatTable reloadData];
                        [self.chatTable scrollsToTop];
                    }
                    
                    else {
                        NSLog(@"An error occurred");
                    }
                }];
                
                
            }
            
            else {
                number = [self.chatData count];
            }
        }
    }];
    
}




@end
