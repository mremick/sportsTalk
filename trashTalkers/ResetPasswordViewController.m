//
//  ResetPasswordViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/26/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "ResetPasswordViewController.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self registerForKeyboardNotifications]; 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.closeKeyboardButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Method

- (IBAction)sendEmailButton:(id)sender {
    
    self.emailAddress = self.emailTextField.text;
    [PFUser requestPasswordResetForEmailInBackground:self.emailAddress block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Successful" message:@"An email has been sent to you to change your password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Error" message:@"An error occurred sending you an email to chage your password. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }];
    
}

#pragma mark - UITextField Delegate Methods
    
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
    self.closeKeyboardButton.hidden = NO;
    //move keyboard here.
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.closeKeyboardButton.hidden = YES;
    
    
    //return keyboard here
}

- (IBAction)closeKeyboard:(id)sender {
    [self.emailTextField resignFirstResponder];
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES]; 
}


@end
