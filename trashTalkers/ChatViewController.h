//
//  ChatViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/19/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ChatCell.h"
#import "SVProgressHUD.h"

@interface ChatViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,PF_EGORefreshTableHeaderDelegate>

@property (nonatomic,retain) IBOutlet UITableView *chatTable;
@property (nonatomic,retain) PF_EGORefreshTableHeaderView *refreshheaderView;
@property (nonatomic) BOOL reloading; 

//this was a NSArray in the tutorial (thought he was wrong)
@property (nonatomic,retain) NSMutableArray *chatData;

@property (weak, nonatomic) IBOutlet UITextField *chatTextField;

- (void)registerForKeyboardNotifications;
- (void)freeKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;

//className methods and properties
@property (strong,nonatomic) NSString *className;

@property (weak, nonatomic) IBOutlet UIButton *closeKeyboardButton;

- (IBAction)closeKeyboard:(id)sender;

@property (strong,nonatomic) NSString *gameTitle;
@property (nonatomic,strong) NSNumber *numberOfUsers;



@end
