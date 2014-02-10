//
//  EditProfileViewController.h
//  trashTalkers
//
//  Created by Matt Remick on 12/11/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditProfileViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) NSString *bio;
@property (strong,nonatomic) NSString *favoriteTeams;
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *location; 
@property (strong,nonatomic) UIImage *image; 
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *bioTextField;
@property (weak, nonatomic) IBOutlet UITextView *favoriteTeamsTextField;
- (IBAction)changeImage:(id)sender;

- (IBAction)submitEdits:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dismissKeyboardButton;
- (IBAction)dismissKeyboard:(id)sender;

@end
