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
#import "Post.h"

#define MAX_ENTRIES_LOADED 25


@interface ChatViewController ()

@property (strong,nonatomic) NSOperationQueue *backgroundQueue;


@end

@implementation ChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.chatTable setContentInset:UIEdgeInsetsMake(0,300,100,0)];
    
    NSLog(@"TESTING CLASS NAME: %@",self.className); 
    
	// Do any additional setup after loading the view.
    self.chatTextField.delegate = self;
    self.chatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.chatData = [[NSMutableArray alloc] init];
    
    self.backgroundQueue.maxConcurrentOperationCount = 1;

    
    
    /*
    CGRect rect = CGRectMake(self.tabBarController.view.bounds.size.width + 30, self.tabBarController.view.bounds.size.height, 100, 100);
    self.chatTextField = [[UITextField alloc] initWithFrame:rect];
    [self.view addSubview:self.chatTextField];
    
     */
    
    [self registerForKeyboardNotifications];
    
    //Implementing the pull to refresh view
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f - (self.chatTable.bounds.size.height + 0), self.view.frame.size.width, self.chatTable.bounds.size.height)];
    [self.chatTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadLocalChat) forControlEvents:UIControlEventValueChanged];
    
    [self.chatTable reloadData];
    
    self.firstLoad = 0;
    NSLog(@"viewDidLoad");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadLocalChat];
    self.closeKeyboardButton.hidden = YES;
    
    self.navigationItem.title = self.gameTitle;
   
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"lastChatRoom"] = self.gameTitle;
    self.userAvatar = currentUser[@"avatar"];
    [currentUser saveInBackground];
    NSLog(@"ViewWillAppear");
    self.firstLoad += 1;
    
    self.navigationController.navigationBar.hidden = NO;

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
        
        Post *newPost = [[Post alloc] init];
        
        newPost.text = self.chatTextField.text;
        newPost.author = currentUser;
        newPost.date = [NSDate date];
        newPost.avatar = currentUser[@"avatar"];
        
        NSString *usernameForUser = [NSString new];
        
        if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
            usernameForUser = [PFUser currentUser][@"usernameForAnonUser"];
        } else {
            usernameForUser = [PFUser currentUser].username;
        }
        
        newPost.username = usernameForUser;
        
        
        
        [self.chatData insertObject:newPost atIndex:0];
        
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        
        [self.chatTable beginUpdates];
        [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.chatTable endUpdates];
        
        //[self.chatTable reloadData];
        
        /*New Code*/
        
//        PFObject *room = [PFObject objectWithClassName:@"Room"];
        __block NSString *chatTextString = self.chatTextField.text;
        NSLog(@"_room: %@",_room);
        
        
        
//        //_room = [PFObject objectWithClassName:@"Room"];
//
//        
//        
//        PFRelation *usersForRoom = [room relationforKey:@"Users"];
//        [usersForRoom addObject:[PFUser currentUser]];
        
        //may need a __block variable for the post
        
        PFObject *post = [PFObject objectWithClassName:@"Post"];
        post[@"text"] = newPost.text;
        post[@"author"] = [PFUser currentUser];
        post[@"date"] = [NSDate date];
        post[@"username"] = usernameForUser;
    
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                PFQuery *roomQuery = [PFQuery queryWithClassName:@"Room"];
                [roomQuery whereKey:@"name" equalTo:self.className];
                
                NSError *error;
                NSArray *results = [roomQuery findObjects:&error];
                
                PFObject *room;
                
                if ([results count]) {
                    room = [results objectAtIndex:0];
                } else {
                    room = [PFObject objectWithClassName:@"Room"];
                    room[@"name"] = self.className;
                }

                PFRelation *postsRelation = [room relationforKey:@"Posts"];
                [postsRelation addObject:post];
                
                [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"room should be saved");
                    } else {
                        NSLog(@"%@",error);
                    }
                }];

                PFRelation *userRelation = [[PFUser currentUser] relationforKey:@"Posts"];
                [userRelation addObject:post];
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"user should be saved");
                    } else {
                        NSLog(@"%@",error);
                    }
                }];
            }
            
            else {
                NSLog(@"%@",error);
            }
            
        }];
        
        self.chatTextField.text = @"";

    }
    
    //reload the data
    //[self loadLocalChat];
    
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
    const int movementDistance = 215; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - Refresh Table View Methods / Data Source Loading / Reloading methods

/*

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
 
 */

#pragma mark - ScrollView Delegate Methods 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshheaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshheaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

/*

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
 
 */

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
        
        
        
        
        
//        NSString *chatText = [[self.chatData objectAtIndex:row] objectForKey:@"text"];
//        NSString *theUserName = [[self.chatData objectAtIndex:row] objectForKey:@"userName"];
        
        Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
        
        PFFile *imageFile = currentPost.author[@"avatar"];


        UIFont *font = [UIFont fontWithName:@"Arial" size:13.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:currentPost.text attributes:attributes];
        
        
        CGRect rect = [currentPost.text boundingRectWithSize:CGSizeMake(225.0f, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attributes
                                          context:nil];
        CGSize size = rect.size;
        
        cell.textString.frame = CGRectMake(76, 23, size.width +20, size.height + 20);
        cell.textString.textAlignment = NSLineBreakByWordWrapping;
        
        cell.userAvatar.layer.masksToBounds = YES;
        cell.userAvatar.layer.cornerRadius = 35;
        
        cell.imageView.layer.cornerRadius = 35;
        cell.imageView.layer.masksToBounds = YES;
        
        //NSDate *theDate = [[self.chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:currentPost.date];
        
        cell.textString.attributedText = attrString;
        [cell.textString sizeToFit];
        cell.timeLabel.text = timeString;
        
        //cell.userLabel.text = currentPost.author.username;
        
        if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
            cell.userLabel.text = currentPost.author[@"usernameForAnonUser"];
            
        } else {
            cell.userLabel.text = currentPost.author.username;

        }


        if (imageFile) {
            cell.userAvatar.file = imageFile;
        }
        
        else {
            cell.userAvatar.image = [UIImage imageNamed:@"1024px_2.png"];
        }
        
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];//[self.chatData objectAtIndex:self.chatData.count-indexPath.row-1];
    
   // NSString *cellText = [[self.chatData objectAtIndex:self.chatData.count-indexPath.row-1] objectForKey:@"text"];
    
    NSString *cellText = currentPost.text;
    

    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:13.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    
    CGRect boundingRect = [cellText boundingRectWithSize:constraintSize
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                          attributes:[NSDictionary dictionaryWithObjectsAndKeys:cellFont, NSFontAttributeName, nil]
                                             context:nil];
                                     //60
    return boundingRect.size.height + 60;
}

#pragma mark - Parse! 
- (void)loadPostsForEmptyRoom
{
    
//    //PFQuery *query = commentsRelation.query;
//    [query orderByAscending:@"createdAt"];
//    //[query findObjectsInBackgroundWithBlock:
    
    
    PFQuery *roomQuery = [PFQuery queryWithClassName:@"Room"];
    [roomQuery whereKey:@"name" equalTo:self.className];
    
    NSError *error;
    NSArray *results = [roomQuery findObjects:&error];
    
    PFObject *room;
    
    if ([results count]) {
        room = [results objectAtIndex:0];
        NSLog(@"results were found");
    } else {
        NSLog(@"results were not found");
    }
    
    [SVProgressHUD setStatus:@"Loading Chat"];
    [SVProgressHUD show];
    
    PFRelation *postsRelation = room[@"Posts"];
    PFQuery *query = postsRelation.query;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error Fetching Posts: %@", error);
        } else {
            NSArray *posts = objects;
            //NSLog(@"OBJECTS: %@",objects);
            
            for (NSDictionary *dict in posts) {
                Post *post = [[Post alloc] init];
                post.text = [dict objectForKey:@"text"];
                post.date = [dict objectForKey:@"date"];
                post.username = [dict objectForKey:@"username"];
                post.authorObjectId = [dict objectForKey:@"author"];
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"objectId" equalTo:post.authorObjectId.objectId];
                NSArray *returnedUser = [userQuery findObjects];
                if ([results count]) {
                    post.author = [returnedUser objectAtIndex:0];
                    [self.chatData addObject:post];
                }
                
                
                
                
                //[self.chatData addObject:post];
                
                //NSLog(@"INDEX OF DICTS IN POSTS: %d and POST COUNT: %d",[posts indexOfObject:dict],posts.count-1);

                
                
                    if ([posts indexOfObject:dict] == posts.count - 1) {
                        
                        //if (self.chatData.count == postHolder.count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"RELOAD TALBE VIEW");
                                
                                [self.chatTable reloadData];
                                if ([self.refreshControl isRefreshing]) {
                                    [self.refreshControl endRefreshing];
                                } else {
                                    [SVProgressHUD dismiss];
                                }
                            });

                    }
            }
        }
    }];
    
     
     //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
     //query.cachePolicy = kPFCachePolicyNetworkElseCache;
    NSLog(@"last line of the initial load method");
}

- (void)loadNewPosts
{
    __block int totalNumberOfEntries = 0;
    
    
    PFQuery *countQuery = [PFQuery queryWithClassName:@"Room"];
    [countQuery whereKey:@"name" equalTo:self.className];
    
    NSError *error1;
    NSArray *results1 = [countQuery findObjects:&error1];
    
    PFObject *room1;
    
    if ([results1 count]) {
        room1 = [results1 objectAtIndex:0];
        NSLog(@"results were found");
    } else {
        NSLog(@"results were not found");
    }
    
    
    
    PFRelation *postsRelation1 = room1[@"Posts"];
    
    NSLog(@"CHAT DATA COUNT AFTER INITIAL LOAD: %lu",(unsigned long)[self.chatData count]);
    
    [postsRelation1.query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSLog(@"There are currently %d entries and the count of CHAT DATA IS:%lu",number,(unsigned long)[self.chatData count]);
            totalNumberOfEntries = number;
            
            if (totalNumberOfEntries > [self.chatData count]) {
                //NSLog(@"Retrieving data");
                int theLimit = 0;
                
                if ((totalNumberOfEntries - [self.chatData count]) > MAX_ENTRIES_LOADED) {
                    theLimit = MAX_ENTRIES_LOADED;
                }
                
                else {
                    //may have lost precision with a casting
                    theLimit = totalNumberOfEntries - (int)[self.chatData count];
                }
                
                //there may be a problem here
                countQuery.limit = theLimit;
                
                [postsRelation1.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        //find succeeded
                        //NSLog(@"Successfully retrieved %d chats",[objects count]);
                        
                        NSArray *posts = objects;
                        for (NSDictionary *dict in posts) {
                            Post *post = [[Post alloc] init];
                            post.text = [dict objectForKey:@"text"];
                            post.date = [dict objectForKey:@"date"];
                            PFUser *authorObjectId = [dict objectForKey:@"author"];
                            PFQuery *userQuery = [PFUser query];
                            [userQuery whereKey:@"objectId" equalTo:authorObjectId.objectId];
                            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if (!error) {
                                    if ([objects count]) {
                                        post.author = [objects objectAtIndex:0];
                                        
                                        //NSLog(@"AUTHOR: %@",post.author);
                                        [self.chatData addObject:post];
                                        NSLog(@"added objects in chatData in SECOND load");
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.chatTable reloadData];
                                        });
                                    }
                                }
                            }];
                        }
                        
                        //[self.chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        
                        //NSLog(@"CHAT DATA: %@",self.chatData);
                        
                        for (int ind = 0; ind < [objects count]; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        
                        //getting back to the main thread to update the UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chatTable beginUpdates];
                            [self.chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                            [self.chatTable endUpdates];
                            [self.chatTable reloadData];
                            [self.chatTable scrollsToTop];
                            
                            
                            
                            if ([self.refreshControl isRefreshing]) {
                                [self.refreshControl endRefreshing];
                            }
                            
                            else {
                                [SVProgressHUD dismiss];
                            }
                            
                        });
                        
                    }
                    
                    else {
                        NSLog(@"An error occurred");
                    }
                }];
                
                
            }
            
            else {
                number = [self.chatData count];
                if ([self.refreshControl isRefreshing]) {
                    [self.refreshControl endRefreshing];
                }
            }
        }
    }];
}

//need to find where this is called
- (void)loadLocalChat
{
    NSLog(@"FIRSTLOAD: %d",self.firstLoad);
    if (self.firstLoad != 0) {
        if (![self.className isEqualToString:self.classNameHolder]) {
            [self.chatData removeAllObjects];
        }
    }
    
    
    if ([self.chatData count] == 0) {
        
        [self loadPostsForEmptyRoom];
    } else {
        [self loadNewPosts];
    }
        
    
        
    self.classNameHolder = self.className;
    [self.chatTable reloadData];
        NSLog(@"end of loadLoaclChat");


}

- (IBAction)closeKeyboard:(id)sender
{
    [self.chatTextField resignFirstResponder];
}

#pragma mark - number of Users in chatroom


#pragma mark - Navigation 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserProfileViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.chatTable indexPathForSelectedRow];
        NSUInteger row = [self.chatData count]-[indexPath row]-1;
        Post *selectedPost = [self.chatData objectAtIndex:row];
        vc.userName = selectedPost.author.username;
    }
}
    
@end
