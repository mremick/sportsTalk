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
@property (nonatomic) int chatDataCountHolder;

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
        userProfileVC.userName = selectedPost.username;
    }
    
}



- (NSInteger)numberOfRows
{
	return [self.chatData count];
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
    
    if ([[PFUser currentUser].username isEqualToString:currentPost.username]) {
        
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
    Post *currentPost = [self.chatData objectAtIndex:indexPath.row];
	return currentPost.date;
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
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        //[self enableSignUpButton];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Chat"
                                                        message:@"Please create an account to be able to chat with other users"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        //code to resign the keyboard
        UITextField *cell = [UITextField new];
        [self.view addSubview:cell];
        
        [cell becomeFirstResponder];
        [cell resignFirstResponder];
        
        [cell removeFromSuperview];
        cell = nil;
        
        [alert show];
        
    } else {
        
        if ([text length] > 0) {
            
            //code to resign the keyboard
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
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            
            
            
            
            
            
            
            
            
            
            PFObject *post = [PFObject objectWithClassName:@"Post"];
            post[@"text"] = newPost.text;
            post[@"author"] = [PFUser currentUser];
            post[@"date"] = [NSDate date];
            post[@"username"] = usernameForUser;
            post[@"avatar"] = [PFUser currentUser][@"avatar"];
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    PFQuery *roomQuery = [PFQuery queryWithClassName:@"Room"];
                    [roomQuery whereKey:@"name" equalTo:self.selectedGame.objectId];
                    
                    __block NSArray *results;
                    [roomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if (!error) {
                            results = objects;
                            
                            PFObject *room;
                            
                            if ([results count]) {
                                room = [results objectAtIndex:0];
                            } else {
                                room = [PFObject objectWithClassName:@"Room"];
                                room[@"name"] = self.selectedGame.objectId;
                            }
                            
                            PFRelation *postsRelation = [room relationforKey:@"Posts"];
                            [postsRelation addObject:post];
                            
                            PFRelation *usersForRoom = [room relationforKey:@"Users"];
                            [usersForRoom addObject:[PFUser currentUser]];
                            
                            
                            [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    NSLog(@"ROOM SHOULD BE SAVED");
                                } else {
                                    NSLog(@"%@",error);
                                }
                            }];
                            
                            PFRelation *userRelation = [[PFUser currentUser] relationforKey:@"Posts"];
                            [userRelation addObject:post];
                            
                            [PFUser currentUser][@"lastChatRoom"] = self.gameName;
                            
                            
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
                    
                    
                }
            }];
            
            
            text = @"";
            
        }

        
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
    
    [SVProgressHUD setStatus:@"Loading Chat"];
    [SVProgressHUD show];
    
    
    PFQuery *roomQuery = [PFQuery queryWithClassName:@"Room"];
    [roomQuery whereKey:@"name" equalTo:self.selectedGame.objectId];
    
    [roomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *results = objects;
            if ([results count]) {
                self.currentRoom = [results objectAtIndex:0];
                PFRelation *usersForRoom = [self.currentRoom relationforKey:@"Users"];
                [usersForRoom addObject:[PFUser currentUser]];
                [self.currentRoom saveInBackground];
                NSLog(@"results were found");
            } else {
                NSLog(@"results were not found");
                [SVProgressHUD dismiss];
                
            }
            
            
            
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
                        post.avatar = [dict objectForKey:@"avatar"];
                        NSLog(@"USERNAME :%@",post.username);
                        post.authorObjectId = [dict objectForKey:@"author"];
                        [self.chatData addObject:post];
                        //NSLog(@"USERNAME: %@",post.authorObjectId.username);
                        //                PFQuery *userQuery = [PFUser query];
                        //                userQuery.limit = 1;
                        //                [userQuery whereKey:@"objectId" equalTo:post.authorObjectId.objectId];
                        //                NSArray *returnedUser = [userQuery findObjects];
                        //                if ([results count]) {
                        //                    post.author = [returnedUser objectAtIndex:0];
                        //                    [self.chatData addObject:post];
                        //                }
                        
                        
                        
                        
                        //[self.chatData addObject:post];
                        
                        //NSLog(@"INDEX OF DICTS IN POSTS: %d and POST COUNT: %d",[posts indexOfObject:dict],posts.count-1);
                        
                        
                        
                        if ([posts indexOfObject:dict] == posts.count - 1) {
                            
                            self.chatDataCountHolder = (int)[self.chatData count];
                            
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
    [countQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *results = objects;
            
            PFObject *room1;
            
            if ([results count]) {
                 room1 = [results objectAtIndex:0];
                NSLog(@"results were found");
            } else {
                NSLog(@"results were NOT found");
                [SVProgressHUD dismiss];
                return;

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
                        PFQuery *lastQuery = postsRelation1.query;
                        [lastQuery orderByDescending:@"date"];
                        lastQuery.limit = theLimit;
                        
                        NSLog(@"LIMIT: %d",theLimit);
                        
                        [lastQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                //find succeeded
                                //NSLog(@"Successfully retrieved %d chats",[objects count]);
                                
                                NSArray *posts = objects;
                                NSMutableArray *sortedArray = [NSMutableArray new];
                                
                                //reverse the posts array
                                for (int i = (posts.count -1); i >= 0; i--) {
                                    NSLog(@"i:%d",i);
                                    [sortedArray addObject:[posts objectAtIndex:i]];
                                }
                                
                                
                                
                                for (NSDictionary *dict in sortedArray) {
                                    Post *post = [[Post alloc] init];
                                    post.text = [dict objectForKey:@"text"];
                                    post.date = [dict objectForKey:@"date"];
                                    post.avatar = [dict objectForKey:@"avatar"];
                                    NSLog(@"POST: %@",post.text);
                                    //[self.chatData addObject:post];
                                    [self.chatData insertObject:post atIndex:0];
                                    //                            PFQuery *userQuery = [PFUser query];
                                    //                            [userQuery whereKey:@"objectId" equalTo:authorObjectId.objectId];
                                    //                            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                    //                                if (!error) {
                                    //                                    if ([objects count]) {
                                    //                                        post.author = [objects objectAtIndex:0];
                                    //
                                    //                                        //NSLog(@"AUTHOR: %@",post.author);
                                    //                                        [self.chatData insertObject:post atIndex:0];
                                    //                                        NSLog(@"POST: %@",post.text);
                                    //                                        dispatch_async(dispatch_get_main_queue(), ^{
                                    //                                            //[self.tableView reloadData];
                                    //                                        });
                                    //                                    }
                                    //                                }
                                    
                                }
                                
                                
                                //if ([posts indexOfObject:dict] == posts.count - 1) {
                                
                                
                                //[self.chatData addObjectsFromArray:objects];
                                NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                                
                                //NSLog(@"CHAT DATA: %@",self.chatData);
                                int ind;
                                
                                for (ind = 0; ind < posts.count; ind++) {
                                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                                    [insertIndexPaths addObject:newPath];
                                }
                                
                                //getting back to the main thread to update the UI
                                NSLog(@"table update code got called");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    //error check here
                                    NSLog(@"CHAT DATA COUNT: %d   COUNT HOLDER: %d",[self.chatData count],self.chatDataCountHolder + theLimit);
                                    if ([self.chatData count] == (self.chatDataCountHolder + theLimit)) {
                                        self.chatDataCountHolder = [self.chatData count];
                                        [self.tableView beginUpdates];
                                        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                                        [self.tableView endUpdates];
                                        [self.tableView reloadData];
                                        [self.tableView scrollsToTop];
                                        [self.refreshControl endRefreshing];
                                        [SVProgressHUD dismiss];
                                        if ([self.refreshControl isRefreshing]) {
                                            [self.refreshControl endRefreshing];
                                        }

                                        
                                        
                                    } else {
                                        [SVProgressHUD dismiss];
                                        if ([self.refreshControl isRefreshing]) {
                                            [self.refreshControl endRefreshing];
                                        }

                                    }
                                    
                                    
                                    
                                });
                                
                                //}
                                //}];
                                
                                
                                
                                
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
                            [self.tableView reloadData];
                        }
                    }
                }
            }];


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
