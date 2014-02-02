//
//  LoginViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "DTAlertView.h"

@interface LoginViewController () <UIAlertViewDelegate>
- (IBAction)signInAnonymously:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //hide back button
    self.navigationItem.hidesBackButton = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        //set background image to the larger one
        //self.backgroundImageView.image = [UIImage imageNamed:@"TheLargerImage"];
    }
    
    [self setupToolbar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //weak error checking
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Please make sure you have entered both a username and a password"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                //error checking
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                                message:@"An error occured loggin in. Please try again"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
            }
            
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)setupToolbar
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.usernameTextField.inputAccessoryView = numberToolbar;
    self.passwordTextField.inputAccessoryView = numberToolbar;
}


-(void)doneWithNumberPad{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
}


- (IBAction)signInAnonymously:(id)sender {
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
        } else {
            NSLog(@"Anonymous user logged in.");
        }
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Need a Username" message:@"Enter a temporary username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show]; 
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];

    if (buttonIndex == 0) {
        if (textField.text.length == 0) {
            //[self.navigationController popViewControllerAnimated:YES];
        } else {
            [PFUser currentUser][@"usernameForAnonUser"] = textField.text;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        

    }else {
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

@end
