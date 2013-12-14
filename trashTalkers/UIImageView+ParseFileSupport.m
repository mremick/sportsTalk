//
//  UIImageView+ParseFileSupport.m
//  trashTalkers
//
//  Created by Matt Remick on 12/13/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "UIImageView+ParseFileSupport.h"

@implementation UIImageView (ParseFileSupport)

- (void)setFile:(PFFile *)file
{
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.image = image;
        }
        
        else {
            self.image = nil;
            NSLog(@"ERROR: %@",error);
        }
    }];
}


@end
