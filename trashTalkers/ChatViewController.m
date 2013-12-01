//
//  ChatViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/19/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "ChatViewController.h"
#import "UserProfileViewController.h"

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
    
    //setting up the toolbar above the keyboard
    //[self toolbarSetup];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.chatData = [[NSMutableArray alloc] init];
    [self loadLocalChat];
    self.closeKeyboardButton.hidden = YES; 
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
        
        /* Things to add once someone enters text so they can be saved */
        
        //1 game they chatted in
        //2 their unique ID
        
        
        
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
    [self animateTextField:self.tfEntry up:YES];
    self.closeKeyboardButton.hidden = NO;
    //move keyboard here.
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSLog(@"Keyboard will hide!");
    [self animateTextField:self.tfEntry up:NO];
    self.closeKeyboardButton.hidden = YES;
    

    //return keyboard here
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    //was 80
    const int movementDistance = 209; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
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
    
    NSUInteger row = [self.chatData count]-[indexPath row]-1;
    
    if (row < [self.chatData count]) {
        NSString *chatText = [[self.chatData objectAtIndex:row] objectForKey:@"text"];
        NSString *theUserName = [[self.chatData objectAtIndex:row] objectForKey:@"userName"];
        
        cell.textLabel.textAlignment = NSLineBreakByWordWrapping;
        //cell.textString.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        /* adjusting the height of the cell based on the amounf of text */
        
        //tutorial had the font as helvetica and size 14
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Helvetica" size:14], NSFontAttributeName,
                                    nil];
        
        
        CGRect rect = [chatText boundingRectWithSize:CGSizeMake(225.0f, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attributes
                                          context:nil];
        CGSize size = rect.size;
        
        cell.textString.frame = CGRectMake(75, 14, size.width +20, size.height + 20);
        
        //a lot of formatting code after this that I'm skipping for now
        cell.textString.textAlignment = NSLineBreakByWordWrapping;
        
        
        NSDate *theDate = [[self.chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:theDate];
        
        cell.textString.text = chatText;
        [cell.textString sizeToFit];
        
        cell.timeLabel.text = timeString;
        cell.userLabel.text = theUserName; 
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Original
    NSString *cellText = [[self.chatData objectAtIndex:self.chatData.count-indexPath.row-1] objectForKey:@"text"];
    
    //test
    //NSString *cellText = [[self.chatData objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    //playing with formatting 
   

    
    //This font is adjusting the cells 
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    //CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect boundingRect = [cellText boundingRectWithSize:constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:[NSDictionary dictionaryWithObjectsAndKeys:cellFont, NSFontAttributeName, nil]
                                             context:nil];

    
    return boundingRect.size.height + 40;
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

- (IBAction)closeKeyboard:(id)sender
{
    [self.tfEntry resignFirstResponder];
}

#pragma mark - Navigation 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserProfileViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.chatTable indexPathForSelectedRow];
        NSUInteger row = [self.chatData count]-[indexPath row]-1;
        vc.userName = [[self.chatData objectAtIndex:row] objectForKey:@"userName"];
    }
}
    
@end
