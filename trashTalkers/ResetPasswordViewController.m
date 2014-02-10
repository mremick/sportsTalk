//
//  ResetPasswordViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/26/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "Reachability.h"

@interface ResetPasswordViewController ()
- (IBAction)goBackButtonSelected:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendEmailButton;

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
    
    self.sendEmailButton.layer.masksToBounds = YES;
    self.sendEmailButton.layer.cornerRadius = 20.0f;
    [self.sendEmailButton.layer setBorderWidth:2.50f];
    [self.sendEmailButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
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
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable)
        
    {
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
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reachability" message:@"No internet connection found. Please check your internet status to retrieve a new password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.emailTextField resignFirstResponder];
    
    return YES; 
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)goBackButtonSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
