//
//  Room.h
//  trashTalkers
//
//  Created by Matt Remick on 1/24/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject

@property (strong,nonatomic) NSString *objectId;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSDate *createdAt;
@property (strong,nonatomic) NSMutableArray *posts;
@property (nonatomic) NSUInteger numberOfUsersInRoom;


@end
