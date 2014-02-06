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

@interface SignUpViewController ()

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
                
                [self.navigationController popToRootViewControllerAnimated:YES]; 
            }
        }];
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
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType |= UIImagePickerControllerSourceTypeCamera;
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:^{
                         //completion
    }];
    
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
