//
//  ChatViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/19/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "ChatViewController.h"
#import "UserProfileViewController.h"
#import "UIImageView+ParseFileSupport.h"

#define MAX_ENTRIES_LOADED 25


@interface ChatViewController ()

@end

@implementation ChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.chatTable setContentInset:UIEdgeInsetsMake(0,300,100,0)];
            
    NSLog(@"TESTING CLASS NAME: %@",self.className); 
    
	// Do any additional setup after loading the view.
    self.chatTextField.delegate = self;
    self.chatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    /*
    CGRect rect = CGRectMake(self.tabBarController.view.bounds.size.width + 30, self.tabBarController.view.bounds.size.height, 100, 100);
    self.chatTextField = [[UITextField alloc] initWithFrame:rect];
    [self.view addSubview:self.chatTextField];
    
     */
    
    [self registerForKeyboardNotifications];
    
    //Implementing the pull to refresh view
    
    //
    
    //The problem with the pull to refresh is more than likely here
    if (self.refreshheaderView == nil) {
        PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - (self.chatTable.bounds.size.height + 0), self.view.frame.size.width, self.chatTable.bounds.size.height)];
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
    
    self.navigationItem.title = self.gameTitle;
   
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"lastChatRoom"] = self.gameTitle;
    [currentUser saveInBackground]; 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Chat Textfield

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"The text: %@",self.chatTextField.text);
    [textField resignFirstResponder];
    [self.chatTextField resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender
{
    [self.chatTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"The text: %@",self.chatTextField.text);
    [textField resignFirstResponder];
    
    if ([self.chatTextField.text length] > 0) {
        
        //updating the table immeadiately
        
        PFUser *currentUser = [PFUser currentUser];
        
        NSArray *objects = [NSArray arrayWithObjects:self.chatTextField.text,currentUser.username,[NSDate date], nil];
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
        
        //NSLog(@"CLASSNAME (TextFieldShouldreturn): %@",self.className);
        
        //going for the parsing
        PFObject *newMessage = [PFObject objectWithClassName:self.className];
        [newMessage setObject:self.chatTextField.text forKey:@"text"];
        [newMessage setObject:currentUser.username forKey:@"userName"];
        [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage setObject:currentUser[@"avatar"] forKey:@"avatar"];
        
        /* Things to add once someone enters text so they can be saved */
        
        //1 game they chatted in
        //2 their unique ID
        
        
        
        [newMessage saveInBackground];
        self.chatTextField.text = @"";

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
    [self animateTextField:self.chatTextField up:YES];
    self.closeKeyboardButton.hidden = NO;
    //move keyboard here.
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSLog(@"Keyboard will hide!");
    [self animateTextField:self.chatTextField up:NO];
    self.closeKeyboardButton.hidden = YES;
    

    //return keyboard here
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    //was 209
    const int movementDistance = 167; // tweak as needed
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
    //this is called when pull to refresh is pulled..
    self.chatData = [[NSMutableArray alloc] init];

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
        PFFile *imageFile = [[self.chatData objectAtIndex:row] objectForKey:@"avatar"];

        UIFont *font = [UIFont fontWithName:@"Arial" size:13.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:chatText attributes:attributes];
        
        
        CGRect rect = [chatText boundingRectWithSize:CGSizeMake(225.0f, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attributes
                                          context:nil];
        CGSize size = rect.size;
        
        cell.textString.frame = CGRectMake(76, 23, size.width +20, size.height + 20);
        cell.textString.textAlignment = NSLineBreakByWordWrapping;
        
        NSDate *theDate = [[self.chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:theDate];
        
        cell.textString.attributedText = attrString;
        [cell.textString sizeToFit];
        cell.timeLabel.text = timeString;
        cell.userLabel.text = theUserName;
        cell.userAvatar.file = imageFile;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[self.chatData objectAtIndex:self.chatData.count-indexPath.row-1] objectForKey:@"text"];

    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:13.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    
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
    
    [self.chatData removeAllObjects];
    
    if ([self.chatData count] == 0) {
        
        //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");
        
        [SVProgressHUD showWithStatus:@"Loading Chat"];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //NSLog(@"Successfully retrieved %d chats from cache",[objects count]);
                [self.chatData removeAllObjects];
                [self.chatData addObjectsFromArray:objects];
                
                //getting back on the main thread to update the UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chatTable reloadData];
                    [SVProgressHUD dismiss];
                });
                
                NSLog(@"CHAT DATA COUNT: %d",[self.chatData count]);
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
            //NSLog(@"There are currently %d entries",number);
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
                
                [countQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        //find succeeded
                        //NSLog(@"Successfully retrieved %d chats",[objects count]);
                        
                        
                        
                        [self.chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        
                        //NSLog(@"CHAT DATA: %@",self.chatData);
                        
                        for (int ind = 0; ind < [objects count]; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        
                        //getting back to the main thread to update the UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chatTable beginUpdates];
                            [self.chatTable reloadData];
                            [self.chatTable scrollsToTop];
                            [SVProgressHUD dismiss];

                        });
                        
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
    [self.chatTextField resignFirstResponder];
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
