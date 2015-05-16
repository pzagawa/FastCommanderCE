//
//  FMScrollAnimation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 05.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMScrollAnimation : NSAnimation <NSAnimationDelegate>

typedef void (^OnScrollAnimFinishBlock)(void);

@property (weak) NSScrollView *scrollView;

@property (strong) OnScrollAnimFinishBlock onFinish;

+ (void)scroll:(NSScrollView *)scrollView toPoint:(NSPoint)targetPoint withBlockOnFinish:(OnScrollAnimFinishBlock)onFinish;

@end
