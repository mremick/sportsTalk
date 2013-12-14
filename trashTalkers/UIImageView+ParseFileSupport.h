//
//  UIImageView+ParseFileSupport.h
//  trashTalkers
//
//  Created by Matt Remick on 12/13/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UIImageView (ParseFileSupport)

- (void)setFile:(PFFile *)file;

@end
