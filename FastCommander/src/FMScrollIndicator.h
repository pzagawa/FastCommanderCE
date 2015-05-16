//
//  FMScrollIndicator.h
//  FMScrollIndicator
//
//  Created by Piotr Zagawa on 11.10.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMScrollIndicator : NSView

@property NSColor *backgroundColor;
@property NSColor *barColor;

@property CGFloat documentViewHeight;
@property CGFloat documentHeight;
@property CGFloat documentPosition;

- (void)registerScrollEventsFor:(NSClipView *)contentView;
- (void)unregisterScrollEventsFor:(NSClipView *)contentView;

- (void)updateWith:(NSClipView *)contentView;

@end
