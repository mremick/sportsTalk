//
//  ResetPasswordViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/26/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ResetPasswordViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) NSString *emailAddress; 
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)sendEmailButton:(id)sender;

- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
- (IBAction)closeKeyboard:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeKeyboardButton;

@end
