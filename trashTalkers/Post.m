//
//  Post.m
//  trashTalkers
//
//  Created by Matt Remick on 1/24/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "Post.h"

@implementation Post

-(id)init
{
    if (self = [super init]) {
        self.backgroundQueue = [NSOperationQueue new];
    }
    
    return self;
}

- (void)downloadUserAvatar:(NSIndexPath *)indexPath
{
    
    _isDownloading = YES;
    
    //PFFile *aFile = _author[@"avatar"];
    
    [self.avatar getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    _avatarImage = [UIImage imageWithData:data];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.delegate imageWasDownloaded:indexPath];
                    }];
        
                }
        
                else {
                    NSLog(@"ERROR: %@",error);
                }
            }];
    
}

@end
