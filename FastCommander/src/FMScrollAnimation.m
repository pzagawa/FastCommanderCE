//
//  FMScrollAnimation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 05.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMScrollAnimation.h"

@implementation FMScrollAnimation
{
    NSPoint _originPoint;
    NSPoint _targetPoint;
}

+ (void)scroll:(NSScrollView *)scrollView toPoint:(NSPoint)targetPoint withBlockOnFinish:(OnScrollAnimFinishBlock)onFinish
{
    [scrollView setNeedsDisplay:YES];
    
    FMScrollAnimation *animation = [[FMScrollAnimation alloc] initWithDuration:0.15 animationCurve:NSAnimationEaseInOut];
    
    animation.scrollView = scrollView;
    animation.onFinish = onFinish;
    
    animation->_originPoint = scrollView.documentVisibleRect.origin;    
    animation->_targetPoint = targetPoint;
    
    animation.frameRate = 60;
    animation.delegate = animation;
    
    animation.animationBlockingMode = NSAnimationNonblockingThreaded;
    
    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^
    {
        [animation startAnimation];
    }]];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self.scrollView.documentView setNeedsLayout:YES];
    [self.scrollView setNeedsDisplay:YES];

    [self processUiMessages];

    if (self.onFinish != nil)
    {
        self.onFinish();
    }
}

- (void)processUiMessages
{
    NSDate *dtr = [[NSDate alloc] initWithTimeIntervalSinceNow:0.2];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:dtr];
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];

    NSPoint progressPoint = self->_originPoint;
    
    progressPoint.x += progress * (self->_targetPoint.x - self->_originPoint.x);
    progressPoint.y += progress * (self->_targetPoint.y - self->_originPoint.y);
    
    [self.scrollView.documentView scrollPoint:progressPoint];
}

@end
