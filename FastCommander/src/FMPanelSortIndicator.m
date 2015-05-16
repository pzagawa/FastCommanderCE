//
//  FMPanelSortIndicator.m
//  FastCommander
//
//  Created by Piotr Zagawa on 03.01.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "FMPanelSortIndicator.h"

@implementation FMPanelSortIndicator
{
    BOOL _isSortMode;
    
    NSColor *_frameColor;
    NSColor *_bkgColor;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self->_isSortMode = NO;

        _frameColor = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        _bkgColor = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
    
    return self;
}

- (void)setIsSortMode:(BOOL)value
{
    if (value == _isSortMode)
    {
        return;
    }
    
    _isSortMode = value;
    
    if (value == NO)
    {
        self.sortKey = nil;
        self.isDirectionASC = NO;
    }
    
    [self setNeedsDisplay:YES];
}
    
- (void)redraw
{
    [self setNeedsDisplay:YES];
}

- (BOOL)isSortMode
{
    return _isSortMode;
}

- (NSString *)textValue
{
    if (self.isSortMode)
    {
        return @"123";
    }
    else
    {
        return @"";
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.isSortMode == NO)
    {
        return;
    }
    
    //draw frame
    NSRect frameBounds = dirtyRect;
    
    [_frameColor set];
    NSRectFill(frameBounds);

    //draw background
    NSRect bkgBounds = NSInsetRect(dirtyRect, 1, 1);

    [_bkgColor set];
    NSRectFill(bkgBounds);

    NSRect innerBounds = NSInsetRect(dirtyRect, 1, 1);

    NSRect r = NSInsetRect(innerBounds, 3, 5);

    NSBezierPath *path = [NSBezierPath bezierPath];

    if (self.isDirectionASC)
    {
        r.origin.y = r.origin.y - 1;
        
        [path moveToPoint:NSMakePoint(r.origin.x + (r.size.width * 0.5f), r.origin.y)];
        [path lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y + r.size.height)];
        [path lineToPoint:NSMakePoint(r.origin.x, r.origin.y + r.size.height)];
        [path lineToPoint:NSMakePoint(r.origin.x + (r.size.width * 0.5f), r.origin.y)];
    }
    else
    {
        [path moveToPoint:NSMakePoint(r.origin.x + (r.size.width * 0.5f), r.origin.y + r.size.height)];
        [path lineToPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y)];
        [path lineToPoint:NSMakePoint(r.origin.x, r.origin.y)];
        [path lineToPoint:NSMakePoint(r.origin.x + (r.size.width * 0.5f), r.origin.y + r.size.height)];
    }
    
    [path closePath];
    
    [NSColor.whiteColor set];
    [path fill];
}

@end
