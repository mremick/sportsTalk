//
//  ChatCellContentView.m
//  trashTalkers
//
//  Created by Matt Remick on 2/5/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "ChatCellContentView.h"

@implementation ChatCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    //// Frames
    NSLog(@"Content View Frame: %f, %f, %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    _frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect frame = _frame;
    
    if (_isLeft) {
        //// ChatBubble Drawing
        UIBezierPath* chatBubblePath = [UIBezierPath bezierPath];
        [chatBubblePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90089 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13892 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.04606 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22373 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.08826 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.04661 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05258 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.04606 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55505 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89583 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.04606 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61301 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89583 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08976 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73491 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89583 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.08133 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73491 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25636 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48121 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58981 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90087 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55505 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.95153 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73062 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22373 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90089 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04815 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.95155 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame))];
        [chatBubblePath closePath];
        [[UIColor whiteColor] setStroke];
        chatBubblePath.lineWidth = 2;
        [chatBubblePath stroke];
    } else {
        //// ChatBubble Drawing
        UIBezierPath* chatBubblePath = [UIBezierPath bezierPath];
        [chatBubblePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.87358 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.96644 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22373 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92424 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.96589 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05258 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.96644 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55505 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89583 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.96644 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61301 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89583 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.92274 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73491 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89583 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93117 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73491 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75614 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42269 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11163 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55505 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.06097 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73265 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73062 * CGRectGetHeight(frame))];
        [chatBubblePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22373 * CGRectGetHeight(frame))];
        [chatBubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11161 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01875 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04815 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.06095 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06280 * CGRectGetHeight(frame))];
        [chatBubblePath closePath];
        [[UIColor whiteColor] setStroke];
        chatBubblePath.lineWidth = 2;
        [chatBubblePath stroke];

    }
}


@end
