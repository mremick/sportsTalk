//
//  Post.h
//  trashTalkers
//
//  Created by Matt Remick on 1/24/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Post : NSObject

@property (strong,nonatomic) NSString *objectId;
@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) PFUser *author;
@property (strong,nonatomic) PFFile *avatar; 


@end
