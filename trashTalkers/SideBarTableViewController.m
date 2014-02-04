//
//  SideBarTableViewController.m
//  trashTalkers
//
//  Created by Matt Remick on 2/1/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "SideBarTableViewController.h"
#import "ChatViewController.h"
#import "FriendsViewController.h"
#import "CurrentUserProfileViewController.h"
#import "UIImageView+ParseFileSupport.h"

@interface SideBarTableViewController () {
    UIImageView *navBarHairlineImageView;
}

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong,nonatomic) ChatViewController *chatVC;
@property (strong,nonatomic) FriendsViewController *friendsVC;
@property (strong,nonatomic) CurrentUserProfileViewController *currentUserProfileVC;
@property (strong,nonatomic) NSArray *viewControllerArray;
@property (strong,nonatomic) UIViewController *topVC;
- (IBAction)openSideBar:(id)sender;

//should this be strong?
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *avatarBackground;

@end

@implementation SideBarTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];


    self.tableView.delegate = self;
    
    UIColor *barColor = [UIColor colorWithRed:0.201 green:0.769 blue:0.380 alpha:1.000];
    
    self.userAvatarImageView.layer.masksToBounds = YES;
    self.userAvatarImageView.layer.cornerRadius = 48;
    self.userAvatarImageView.file = [PFUser currentUser][@"avatar"];
    self.usernameLabel.text = [PFUser currentUser].username;
    
    self.avatarBackground.layer.masksToBounds = YES;
    self.avatarBackground.layer.cornerRadius = 46;

    
    self.navigationController.navigationBar.backgroundColor = barColor;
    self.chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatVC"];
    self.friendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"friendsVC"];
    self.currentUserProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"currentUserProfileVC"];

    self.topVC = self.chatVC;
    
    self.viewControllerArray = [NSArray new];
    self.viewControllerArray = @[self.currentUserProfileVC,self.chatVC,self.friendsVC];
    
    [self addChildViewController:self.chatVC];
    self.chatVC.view.frame = self.view.frame;
    
    [self.view addSubview:self.chatVC.view];
    [self.chatVC didMoveToParentViewController:self.chatVC];
    
    [self setupPanGesture];
    
     
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    navBarHairlineImageView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //navBarHairlineImageView.hidden = NO;

}
#pragma mark - Gesture Recognizer

- (void)setupPanGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slidePanel:)];
    
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;

    [self.topVC.view addGestureRecognizer:pan];
}

#pragma mark - Side Bar Animation Methods

- (void)slidePanel:(id)sender
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    
    CGPoint velocity = [pan velocityInView:self.view];
    CGPoint translation = [pan translationInView:self.view];
    
    NSLog(@"Velocity %f",velocity.x);
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        if (self.topVC.view.frame.origin.x+ translation.x > 0) {
            //if the finger is moving left move the view with the finger
            self.topVC.view.center = CGPointMake(self.topVC.view.center.x + translation.x, self.topVC.view.center.y);
            
            [(UIPanGestureRecognizer *)sender setTranslation:CGPointMake(0,0) inView:self.view];
            
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        //if the sliding view is past halfway of the locl it in place
        if (self.topVC.view.frame.origin.x > self.view.frame.size.width / 2) {
            [self lockSideBar];
        }
        
        if (self.topVC.view.frame.origin.x < self.view.frame.size.width / 2) {
            [UIView animateWithDuration:.4 animations:^{
                //self.topVC.view.frame = self.view.bounds;
                [self closeSideBar];
            } completion:^(BOOL finished) {
                //[self closeSideBar];
            }];
        }
    }

    
}

- (void)lockSideBar
{
    [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.topVC.view.frame = CGRectMake(self.view.frame.size.width * .8, self.topVC.view.frame.origin.y, self.topVC.view.frame.size.width, self.topVC.view.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];

}

- (void)closeSideBar
{
    
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedDuration animations:^{
        NSLog(@"self.y %f search y%f",self.view.frame.origin.y,self.topVC.view.frame.origin.y);
        self.topVC.view.frame = self.view.frame;
    } completion:^(BOOL finished) {
        //
    }];

}



#pragma mark - Table view data source


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newVC = [self.viewControllerArray objectAtIndex:indexPath.row];
    
    //adding the view controller as a child view controller
    [self addChildViewController:newVC];
    
    //setting the frame of the new of the new view controller to the size of the view
    //newVC.view.frame = self.view.bounds;
    
    //adding the view
    [self.view addSubview:newVC.view];
    [newVC didMoveToParentViewController:newVC];
    
    //animate old view out
    //animate new view in
    
//    if (indexPath.row == 0) {
//        [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.topVC.view.frame = CGRectMake(self.view.frame.size.width, self.topVC.view.frame.origin.y, self.topVC.view.frame.size.width, self.topVC.view.frame.size.height);
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//                //changed to bounds for profile becuase I'm taking out the nav bar
//                newVC.view.frame = self.view.bounds;
//            } completion:^(BOOL finished) {
//                NSLog(@"setup pan gesture on new view controller");
//                [self setupPanGesture];
//            }];
//        }];
//
//    } else {
        [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.topVC.view.frame = CGRectMake(self.view.frame.size.width, self.topVC.view.frame.origin.y - 1, self.topVC.view.frame.size.width, self.topVC.view.frame.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                newVC.view.frame = self.view.frame; //bounds
            } completion:^(BOOL finished) {
                NSLog(@"setup pan gesture on new view controller");
                [self setupPanGesture];
            }];
        }];

    //}
    
    //remove child
    [self.topVC.view removeFromSuperview];
    [self.topVC removeFromParentViewController];
    
    self.topVC = newVC;

}

- (IBAction)openSideBar:(id)sender {
    
    if (self.topVC.view.frame.origin.x > self.view.frame.size.width / 2) {
        [self closeSideBar];

    } else {
        [self lockSideBar];
    }
    
}
@end
