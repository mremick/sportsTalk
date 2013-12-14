//
//  EditProfileViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 12/11/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIImage+ProportionalFill.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

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
    [self registerForKeyboardNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.bioTextField.text = self.bio;
    self.favoriteTeamsTextField.text = self.favoriteTeams;
    self.avatarImageView.image = self.image; 
    self.dismissKeyboardButton.hidden = YES;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)submitEdits:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[@"shortBio"] = self.bioTextField.text;
    currentUser[@"favoriteTeams"] = self.favoriteTeamsTextField.text;
    
    NSData *imageData = UIImagePNGRepresentation(self.avatarImageView.image);
    PFFile *avatar = [PFFile fileWithData:imageData];
    currentUser[@"avatar"] = avatar;
    
    [currentUser saveInBackground];
    
    [self.navigationController popViewControllerAnimated:YES]; 
    
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
    [self.locationTextField resignFirstResponder];
    [self.bioTextField resignFirstResponder];
    [self.favoriteTeamsTextField resignFirstResponder];
}

- (IBAction)changeImage:(id)sender {
    
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
