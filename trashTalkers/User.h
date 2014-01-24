//
//  User.h
//  trashTalkers
//
//  Created by Matt Remick on 1/24/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong,nonatomic) NSString *username;
@property (strong,nonatomic) NSString *emailAddress;
@property (strong,nonatomic) NSString *favoriteTeams;
@property (strong,nonatomic) NSMutableArray *friends;
@property (strong,nonatomic) NSString *shortBio;
@property (nonatomic) BOOL isOnline;
@property (strong,nonatomic) NSString *lastChatRoom;
@property (strong,nonatomic) UIImage *avatar;
@property (strong,nonatomic) NSString *location;
@property (strong,nonatomic) NSMutableArray *posts;

@end
