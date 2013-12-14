//
//  SignUpViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *retypePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *favoriteTeamsTextField;
@property (weak, nonatomic) IBOutlet UITextField *shortBioTextField;
@property (weak, nonatomic) IBOutlet UIButton *dismissKeyboardButton;



- (IBAction)dismissKeyboard:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
- (IBAction)addPhoto:(id)sender;

- (IBAction)signUp:(id)sender;

@end
