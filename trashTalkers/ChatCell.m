//
//  ChatCell.m
//  trashTalkers
//
//  Created by Matt Remick on 11/16/13.
//  Copyright (c) 2013 Matt Remick. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
