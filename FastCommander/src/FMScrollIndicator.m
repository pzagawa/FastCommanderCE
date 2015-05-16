//
//  FMScrollIndicator.h
//  FastCommander
//
//  Created by Piotr Zagawa on 11.10.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMScrollIndicator.h"

@implementation FMScrollIndicator
{
    CGFloat _documentViewHeight;
    CGFloat _documentHeight;
    CGFloat _documentPosition;
    
    NSColor *_frameColor;
    NSColor *_bkgColor;
    
    CGFloat _border;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _documentViewHeight = 0;
        _documentHeight = 0;
        _documentPosition = 0;

        self.backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:0.4 blue:0.6 alpha:0];
        self.barColor = [NSColor colorWithCalibratedRed:0.7 green:0.8 blue:0.9 alpha:0];
        
        _border = 2;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    BOOL isDocumentSmaller = NO;
    
    //draw background
    NSRect rectBkg = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self.backgroundColor set];

    NSRectFill(rectBkg);

    //draw bar
    NSRect rectBarFrame = NSInsetRect(rectBkg, _border, _border);
    
    CGFloat barFrameHeight = rectBarFrame.size.height;
    
    CGFloat barHeight = (self.documentViewHeight / self.documentHeight) * barFrameHeight;
    
    if (barHeight > barFrameHeight)
    {
        barHeight = barFrameHeight;
        
        isDocumentSmaller = YES;
    }

    if (isDocumentSmaller == NO)
    {
        CGFloat barMoveRange = barFrameHeight - barHeight;
    
        NSRect rectBar = rectBarFrame;

        rectBar.size.height = barHeight;

        CGFloat minPosition = barMoveRange + _border;
        CGFloat maxPosition = _border;

        CGFloat barPosition = minPosition - ((self.documentPosition / (self.documentHeight - self.documentViewHeight)) * barMoveRange);

        if (barPosition > minPosition)
        {
            barPosition = minPosition;
        }
    
        if (barPosition < maxPosition)
        {
            barPosition = maxPosition;
        }
    
        rectBar.origin.y = barPosition;

        [[self.barColor highlightWithLevel:0.3] set];

        NSRectFill(rectBar);
    }
}

- (CGFloat)documentViewHeight
{
    return _documentViewHeight;
}

- (void)setDocumentViewHeight:(CGFloat)value
{
    self->_documentViewHeight = value;
    
    [self setNeedsDisplay:YES];
}

- (CGFloat)documentHeight
{
    return _documentHeight;
}

- (void)setDocumentHeight:(CGFloat)value
{
    self->_documentHeight = value;

    [self setNeedsDisplay:YES];
}

- (CGFloat)documentPosition
{
    return _documentPosition;
}

- (void)setDocumentPosition:(CGFloat)value
{
    self->_documentPosition = value;

    [self setNeedsDisplay:YES];
}

- (void)registerScrollEventsFor:(NSClipView *)contentView
{
    [contentView setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollContentBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];
}

- (void)unregisterScrollEventsFor:(NSClipView *)contentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:contentView];
}

- (void)scrollContentBoundsDidChange:(NSNotification *)notification
{
    NSClipView *contentView=[notification object];
    
    [self updateWith:contentView];
}

- (void)updateWith:(NSClipView *)contentView
{
    self.documentViewHeight = contentView.documentVisibleRect.size.height;
    self.documentHeight = contentView.documentRect.size.height;
    self.documentPosition = contentView.documentVisibleRect.origin.y;
}

@end
