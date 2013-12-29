//
//  LoginViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
