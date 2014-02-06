//
//  EditProfileViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 12/11/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIImage+ProportionalFill.h"
#import "UserProfileViewController.h"

@interface EditProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIButton *submitChangesButton;
@property (weak, nonatomic) IBOutlet UIView *avatarBackground;
- (IBAction)backButtonSelected:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *locationWordLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioWordLimitLabel;
@property (nonatomic) int locationCount;
@property (nonatomic) int bioCount;

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
    
    [self setupToolbar];
    
    self.changeImageButton.layer.masksToBounds = YES;
    self.changeImageButton.layer.cornerRadius = 20.0f;
    
    [[self.changeImageButton layer] setBorderWidth:1.0f];
    [[self.changeImageButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    self.submitChangesButton.layer.masksToBounds = YES;
    self.submitChangesButton.layer.cornerRadius = 20.0f;
    
    [[self.submitChangesButton layer] setBorderWidth:1.0f];
    [[self.submitChangesButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    self.avatarBackground.layer.masksToBounds = YES;
    self.avatarBackground.layer.cornerRadius = 69;
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 65;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"BIO:%@   LOCATION:%@",[PFUser currentUser][@"shortBio"],[PFUser currentUser][@"location"]);
    
    self.bioTextField.text = [PFUser currentUser][@"shortBio"];
    //self.favoriteTeamsTextField.text = self.favoriteTeams;
    self.avatarImageView.image = self.image; 
    self.dismissKeyboardButton.hidden = YES;
    self.locationTextField.text = [PFUser currentUser][@"location"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Toolbar setup

- (void)setupToolbar
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.bioTextField.inputAccessoryView = numberToolbar;
    self.favoriteTeamsTextField.inputAccessoryView = numberToolbar;
    self.locationTextField.inputAccessoryView = numberToolbar;
}


-(void)doneWithNumberPad{
    [self.bioTextField resignFirstResponder];
    [self.favoriteTeamsTextField resignFirstResponder];
    [self.locationTextField resignFirstResponder];

}


- (IBAction)submitEdits:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (self.locationTextField.text.length > 20 && self.bioTextField.text.length > 70) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many Characters For Location and Bio"
                                                        message:@"The maximum characters allwed for location are 20 and for your bio is 70"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else if (self.locationTextField.text.length > 20) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many Characters For Location"
                                                        message:@"The maximum characters allwed for location are 20"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];

    } else if (self.bioTextField.text.length > 70) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many Characters For Bio"
                                                        message:@"The maximum characters allwed for bio are 70"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        currentUser[@"shortBio"] = self.bioTextField.text;
        //currentUser[@"favoriteTeams"] = self.favoriteTeamsTextField.text;
        currentUser[@"location"] = self.locationTextField.text;
        NSData *imageData = UIImagePNGRepresentation(self.avatarImageView.image);
        PFFile *avatar = [PFFile fileWithData:imageData];
        currentUser[@"avatar"] = avatar;
        
        [currentUser saveInBackground];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Changes Made!"
                                                         message:@"Changes will show soon"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
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
    [self.locationTextField resignFirstResponder];
    [self.bioTextField resignFirstResponder];
    [self.favoriteTeamsTextField resignFirstResponder];
}

- (IBAction)changeImage:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    /* Camera wasn't working on my device */
    
    /*
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType |= UIImagePickerControllerSourceTypeCamera;
    }
    */
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

/*

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UserProfileViewController *vc = [segue destinationViewController];
    vc.userImage.image = self.avatarImageView.image;
}
 
*/



- (IBAction)backButtonSelected:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
