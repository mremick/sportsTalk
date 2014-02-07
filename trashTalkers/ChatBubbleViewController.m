//
//  ChatBubbleViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 2/6/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "ChatBubbleViewController.h"
#import <Parse/Parse.h>
#import "Post.h"
#import "SVProgressHUD.h"
#import "UserProfileViewController.h"

#define MAX_ENTRIES_LOADED 25


@interface ChatBubbleViewController () <AMBubbleTableDataSource,AMBubbleTableDelegate,PostDelegate>


@property (nonatomic,retain) PF_EGORefreshTableHeaderView *refreshheaderView;
@property (strong,nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL reloading;

//this was a NSArray in the tutorial (thought he was wrong)
@property (nonatomic,retain) NSMutableArray *chatData;
@property (strong,nonatomic) UIImage *userAvatar;


- (void)registerForKeyboardNotifications;
- (void)freeKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;

//className methods and properties
@property (strong,nonatomic) NSString *className;
@property (strong,nonatomic) NSString *classNameHolder;

@property (weak, nonatomic) IBOutlet UIButton *closeKeyboardButton;

- (IBAction)closeKeyboard:(id)sender;

@property (nonatomic,strong) NSNumber *numberOfUsers;

@property (nonatomic) int firstLoad;

@property (nonatomic, weak) PFObject *room;


@property (strong,nonatomic) NSOperationQueue *backgroundQueue;
@property (strong,nonatomic) PFObject *currentRoom;
@property (strong,nonatomic) UIColor *backgroundColor;
@end

@implementation ChatBubbleViewController

- (void)viewDidLoad
{
	// Bubble Table setup
	
	[self setDataSource:self]; // Weird, uh?
	[self setDelegate:self];
    
    //self.tableView.delegate = self;
    
	
	[self setTitle:@"Chat"];
    
    self.chatData = [NSMutableArray new];
    
    self.tableView.bounds = self.view.frame;
	
	// Dummy data
		
	// Set a style
	[self setTableStyle:AMBubbleTableStyleFlat];
	
	[self setBubbleTableOptions:@{AMOptionsBubbleDetectionType: @(UIDataDetectorTypeAll),
								  AMOptionsBubblePressEnabled: @NO,
								  AMOptionsBubbleSwipeEnabled: @NO}];
	
	// Call super after setting up the options
    
    [super viewDidLoad];

    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f - (self.tableView.bounds.size.height + 0), self.view.frame.size.width, self.tableView.bounds.size.height)];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadLocalChat) forControlEvents:UIControlEventValueChanged];
    
    
    self.firstLoad = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadLocalChat];
    self.closeKeyboardButton.hidden = YES;
    
    self.navigationItem.title = self.gameName;
    
    PFUser *currentUser = [PFUser currentUser];
    self.userAvatar = currentUser[@"avatar"];
    [currentUser saveInBackground];
    
    NSLog(@"ViewWillAppear");
    self.firstLoad += 1;
    
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    PFRelation *usersForRoom = [self.currentRoom relationforKey:@"Users"];
    //[usersForRoom addObject:[PFUser currentUser]];
    [usersForRoom removeObject:[PFUser currentUser]];
    [self.currentRoom saveInBackground];
    

}

- (void)swipedCellAtIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame andDirection:(UISwipeGestureRecognizerDirection)direction
{
	NSLog(@"swiped");
}


#pragma mark - AMBubbleTableDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index:%d",indexPath.row);
    
    [self performSegueWithIdentifier:@"showUserProfile" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUserProfile"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        UserProfileViewController *userProfileVC = [segue destinationViewController];
        Post *selectedPost = [self.chatData objectAtIndex:path.row];
        userProfileVC.userName = selectedPost.author.username;
    }
    
}



- (NSInteger)numberOfRows
{
	return [self.chatData count];
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
    
    if ([[PFUser currentUser].username isEqualToString:currentPost.author.username]) {
        
        return AMBubbleCellSent;
            }
    
    else {
        return AMBubbleCellReceived;
    }

	//return [self.data[indexPath.row][@"type"] intValue];
    //isLeft isRight

}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
    return currentPost.text;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [NSDate date];
}

- (UIImage*)avatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
    currentPost.delegate = self;
    
    UIImage *finalAvatar;
    if (currentPost.avatarImage) {
        finalAvatar = currentPost.avatarImage;
    }
    
    else {
        if (!currentPost.isDownloading) {
            [currentPost downloadUserAvatar:indexPath];
        }
    }

	return finalAvatar;
}

- (void)imageWasDownloaded:(NSIndexPath *)indexPath
{
    
    //[self.tableView reloadItemsAtIndexPaths:@[indexPath]];
    NSLog(@"delegate being called to refresh");
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - AMBubbleTableDelegate



- (void)didSendText:(NSString*)text
{
    
   
    
    if ([text length] > 0) {
        
        //updating the table immeadiately
        //AMBubbleTableViewController *vc = [[AMBubbleTableViewController alloc] init];
       //[[vc textView] resignFirstResponder];
        
        //[vc.textView resignFirstResponder];
        
        UITextField *cell = [UITextField new];
        [self.view addSubview:cell];
        
        [cell becomeFirstResponder];
        [cell resignFirstResponder];
        
        [cell removeFromSuperview];
        cell = nil;
        
        
        
        PFUser *currentUser = [PFUser currentUser];
        
        Post *newPost = [[Post alloc] init];
        
        newPost.text = text;
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
        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [self.chatData insertObject:newPost atIndex:0];
        
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        
        
        //[self.chatTable reloadData];
        
        /*New Code*/
        
        //        PFObject *room = [PFObject objectWithClassName:@"Room"];
        __block NSString *chatTextString = text;
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
                [roomQuery whereKey:@"name" equalTo:self.selectedGame.objectId];
                
                NSError *error;
                NSArray *results = [roomQuery findObjects:&error];
                
                PFObject *room;
                
                if ([results count]) {
                    room = [results objectAtIndex:0];
                } else {
                    room = [PFObject objectWithClassName:@"Room"];
                    room[@"name"] = self.selectedGame.objectId;
                }
                
                PFRelation *postsRelation = [room relationforKey:@"Posts"];
                [postsRelation addObject:post];
                
                
                
                [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"ROOM SHOULD BE SAVED");
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
        
        text = @"";
        
    }
    
    //reload the data
    //[self loadLocalChat];

	
	
	// [super reloadTableScrollingToBottom:YES];
}

- (NSString*)usernameForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
	return currentPost.username;
}

- (UIColor*)usernameColorForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UIColor greenColor];
}


#pragma mark - Parse!
- (void)loadPostsForEmptyRoom
{
    
    //    //PFQuery *query = commentsRelation.query;
    //    [query orderByAscending:@"createdAt"];
    //    //[query findObjectsInBackgroundWithBlock:
    
    NSLog(@"NAME: %@",self.selectedGame.objectId);
    
    
    PFQuery *roomQuery = [PFQuery queryWithClassName:@"Room"];
    [roomQuery whereKey:@"name" equalTo:self.selectedGame.objectId];
    
    NSError *error1;
    NSArray *results = [roomQuery findObjects:&error1];
    
    if ([results count]) {
        self.currentRoom = [results objectAtIndex:0];
        PFRelation *usersForRoom = [self.currentRoom relationforKey:@"Users"];
        [usersForRoom addObject:[PFUser currentUser]];
        [self.currentRoom saveInBackground];
        NSLog(@"results were found");
    } else {
        NSLog(@"results were not found");
    }
    
    [SVProgressHUD setStatus:@"Loading Chat"];
    [SVProgressHUD show];
    
    PFRelation *usersForRoom = self.currentRoom[@"Users"];
    NSLog(@"CURRENT ROOM:%@",self.currentRoom);
    [usersForRoom.query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d Users)",self.gameName,number];
            NSLog(@"nav title should be changes no.:%d",number);
        }];
    }];
    
    PFRelation *postsRelation = self.currentRoom[@"Posts"];
    PFQuery *query = postsRelation.query;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error Fetching Posts: %@", error);
        } else {
            
            NSArray *posts = objects;
            
            if (![posts count]) {
                [SVProgressHUD dismiss];
            }
            
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
                        
                        [self.tableView reloadData];
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
    [countQuery whereKey:@"name" equalTo:self.selectedGame.objectId];
    
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
                    
                    theLimit = totalNumberOfEntries - (int)[self.chatData count];
                }
                
                //there may be a problem here
                postsRelation1.query.limit = theLimit;
                NSLog(@"limit: %d",theLimit);
                
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
                                            [self.tableView reloadData];
                                        });
                                    }
                                }
                            }];
                        }
                        
                        //[self.chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        
                        //NSLog(@"CHAT DATA: %@",self.chatData);
                        NSLog(@"OBJECT COUNT:%d",[objects count]);
                        
                        for (int ind = 0; ind < [objects count]; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        
                        //getting back to the main thread to update the UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView beginUpdates];
                            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                            [self.tableView endUpdates];
                            [self.tableView reloadData];
                            [self.tableView scrollsToTop];
                            
                            
                            
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
        if (![self.selectedGame.objectId isEqualToString:self.classNameHolder]) {
            [self.chatData removeAllObjects];
        }
    }
    
    
    if ([self.chatData count] == 0) {
        
        [self loadPostsForEmptyRoom];
    } else {
        [self loadNewPosts];
    }
    
    
    
    self.classNameHolder = self.selectedGame.objectId;
    [self.tableView reloadData];
    NSLog(@"end of loadLoaclChat");
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
