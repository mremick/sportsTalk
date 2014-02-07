//
//  Post.h
//  trashTalkers
//
//  Created by Matt Remick on 1/24/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol PostDelegate <NSObject>

- (void)imageWasDownloaded:(NSIndexPath *)indexPath;

@end

@interface Post : NSObject

@property (strong,nonatomic) NSString *objectId;
@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) PFUser *author;
@property (strong,nonatomic) PFFile *avatar;
@property (strong,nonatomic) PFUser *authorObjectId;
@property (strong,nonatomic) NSString *username;
@property (nonatomic) BOOL isDownloading;
@property (strong,nonatomic) NSOperationQueue *backgroundQueue;
@property (strong,nonatomic) UIImage *avatarImage;

@property (unsafe_unretained) id<PostDelegate> delegate;



- (void)downloadUserAvatar:(NSIndexPath *)indexPath;


@end
