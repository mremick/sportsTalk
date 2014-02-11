//
//  SignUpViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 11/15/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "UIImage+ProportionalFill.h"
#import "LoginViewController.h"
#import "Reachability.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UIButton *changePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self registerForKeyboardNotification];
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        //set background image to the larger one
        //self.backgroundImageView.image = [UIImage imageNamed:@"TheLargerImage"];
    }
    
    [self setupToolbar];
    
    self.signUpButton.layer.masksToBounds = YES;
    self.signUpButton.layer.cornerRadius = 20.0f;
    [self.signUpButton.layer setBorderWidth:2.50f];
    [self.signUpButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    
    
    
    self.avatarImageView.image = [UIImage imageNamed:@"avatar.png"]; 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.dismissKeyboardButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp:(id)sender {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable)
        
    {
        NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *retypedPassword = [self.retypePasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //weak error checking
        if ([username length] == 0 || [password length] == 0 || [retypedPassword length] == 0 || [email length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"Please make sure you have filled all text fields"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        
        else if (![password isEqualToString:retypedPassword]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"Please make sure your passwords are the same"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        
        else {
            
            [SVProgressHUD showWithStatus:@"Signing Up"];
            
            //create a new user
            PFUser *user = [PFUser user];
            user.username = username;
            user.password = password;
            user.email = email;
            user[@"shortBio"] = @"I haven't filled out a bio yet..";
            user[@"location"] = @"Webspere, INTERNET";
            
            NSData *imageData = UIImagePNGRepresentation(self.avatarImageView.image);
            PFFile *avatar = [PFFile fileWithData:imageData];
            user[@"avatar"] = avatar;
            
            
            //maybe add a quick description here or favorite sports or sports teams
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
                
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    
                    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                    
                }
            }];
        }

    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reachability" message:@"No internet connection found. Please check your internet status" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
}

- (void)registerForKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow
{
    self.dismissKeyboardButton.hidden = NO;
    [self animateTextField:self.retypePasswordTextField up:YES];
    [self animateTextField:self.emailTextField up:YES];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    return YES;
}


- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    
    if (textField.tag == 1) {
        NSLog(@"RETYPE PASSWORD SELECTED");
    } else if (textField.tag == 2) {
        NSLog(@"EMAIL ADRRESS SELCTED");
    }
    //was 209
//    const int movementDistance = 215; // tweak as needed
//    const float movementDuration = 0.3f; // tweak as needed
//    
//    int movement = (up ? -movementDistance : movementDistance);
//    
//    [UIView beginAnimations: @"anim" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: movementDuration];
//    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
//    [UIView commitAnimations];
}

- (void)keyboardWillHide
{
    self.dismissKeyboardButton.hidden = YES;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.retypePasswordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.shortBioTextField resignFirstResponder];
    [self.favoriteTeamsTextField resignFirstResponder];
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
    self.retypePasswordTextField.inputAccessoryView = numberToolbar;
    self.emailTextField.inputAccessoryView = numberToolbar;
}


-(void)doneWithNumberPad{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.retypePasswordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

- (IBAction)addPhoto:(id)sender {
    
    UIActionSheet *mySheet;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        mySheet = [[UIActionSheet alloc] initWithTitle:@"Pick Photo"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"Camera",@"Photo Library", nil];
    }
    
    else {
        mySheet = [[UIActionSheet alloc] initWithTitle:@"Pick Photo"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"Photo Library", nil];
    }
    
    [mySheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:^{
            //imagePicker code here
        }];
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Photo Library"]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:^{
            //photo library code here
        }];
        
        
        
        
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        //completiom
    }];
    
    //TO DO ONCE THE PHOTO HAS BEEN SELECTED
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        UIImage *thumbnail = [originalImage imageCroppedToFitSize:CGSizeMake(250, 250)];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = thumbnail;
        });
    });
    
}
@end
