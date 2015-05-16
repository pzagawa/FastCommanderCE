//
//  FMDockInfoView.m
//  FastCommander
//
//  Created by Piotr Zagawa on 08.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMDockInfoView.h"
#import "NSColor+Hex.h"

@implementation FMDockInfoView
{
    NSDockTile *_dockTile;
    NSRect _dockTileFrame;

    BOOL _isProgressVisible;
    BOOL _isIndeterminate;

    NSImage *_iconBkg;

    NSGradient *_gradPanel;
    NSGradient *_gradPanelShadow;
    NSGradient *_gradProgressBkg;
    NSGradient *_gradProgressFrame;
    NSGradient *_gradProgress;
    NSGradient *_gradProgressError;
}

+ (FMDockInfoView *)createDockInfoView
{
    NSDockTile *dockTile = [[NSApplication sharedApplication] dockTile];
    
    NSRect dockTileFrame = NSMakeRect(0, 0, dockTile.size.width ,dockTile.size.height);
    
    FMDockInfoView *dockInfoView = [[FMDockInfoView alloc] initWithFrame:dockTileFrame];
    
    dockInfoView->_dockTile = dockTile;
    dockInfoView->_dockTileFrame = dockTileFrame;
    
    return dockInfoView;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _isProgressVisible = false;
        _isIndeterminate = NO;
        _progressValue = 0;
        _isErrorColor = NO;
        
        _iconBkg = [NSApplication.sharedApplication.applicationIconImage copy];

        //gradients
        _gradPanel = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithHexRGB:0xffc9c9c9] endingColor:[NSColor colorWithHexRGB:0xffa9a9a9]];
        
        _gradPanelShadow = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1.0] endingColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.0]];

        NSArray *progressBkgColors = @[[NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0],
                                       [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0],
                                       [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        
        _gradProgressBkg = [[NSGradient alloc] initWithColors:progressBkgColors];

        NSArray *progressFrameColors = @[[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0],
                                         [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1.0],
                                         [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1.0],
                                       [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1.0]];
        
        _gradProgressFrame = [[NSGradient alloc] initWithColors:progressFrameColors];

        NSArray *progressColors = @[[NSColor colorWithDeviceRed:0.0 green:0.6 blue:0.9 alpha:1.0],
                                    [NSColor colorWithDeviceRed:0.0 green:0.2 blue:0.4 alpha:1.0]];
        
        _gradProgress = [[NSGradient alloc] initWithColors:progressColors];
        
        NSArray *progressColorsError = @[[NSColor colorWithDeviceRed:1.0 green:0.4 blue:0.4 alpha:1.0],
                                         [NSColor colorWithDeviceRed:0.6 green:0.0 blue:0.0 alpha:1.0]];
        
        _gradProgressError = [[NSGradient alloc] initWithColors:progressColorsError];
    }
    
    return self;
}

-(void)dealloc
{
    [NSApp setApplicationIconImage:nil];
    [_dockTile setContentView:nil];
    
    [_dockTile display];
}

- (void)drawRect:(NSRect)dirtyRect
{
    const float marginTop = 22;
    const float marginHorz = 28;
    const float shadowScale = 0.3;
    const float progressTop = 11;
    
    NSRect rect = self.bounds;
    
    //draw icon background
    [_iconBkg drawAtPoint:NSMakePoint(0, 0) fromRect:self.bounds operation:NSCompositeCopy fraction:1.0f];

    //draw panel
    NSRect rectPanel = rect;
    
    rectPanel.size.height = rect.size.height * 0.25;
    rectPanel.size.width = rect.size.width - marginHorz;
    
    rectPanel.origin.y = (rect.size.height - rectPanel.size.height) - marginTop;
    rectPanel.origin.x = (rect.size.width * 0.5) - (rectPanel.size.width * 0.5);
    
    [_gradPanel drawInRect:rectPanel angle:-90];
    
    //draw panel bottom shadow
    NSRect rectPanelShadow = rectPanel;

    rectPanelShadow.size.height = rectPanel.size.height * shadowScale;
    rectPanelShadow.origin.y = rectPanel.origin.y - rectPanelShadow.size.height;
    
    [_gradPanelShadow drawInRect:rectPanelShadow angle:-90];
    
    //draw progres
    NSRect rectProgressFrame = rectPanel;

    rectProgressFrame.size.width = rectPanel.size.width;
    rectProgressFrame.size.height = rectPanel.size.height * 0.5;
    
    rectProgressFrame.origin.x = rectPanel.origin.x + ((rectPanel.size.width * 0.5) - (rectProgressFrame.size.width * 0.5));
    rectProgressFrame.origin.y = rectPanel.origin.y + progressTop;

    //draw progress frame
    [_gradProgressFrame drawInRect:rectProgressFrame angle:-90];
    
    //draw progress background
    NSRect rectProgressBkg = NSInsetRect(rectProgressFrame, 1, 1);
    
    [_gradProgressBkg drawInRect:rectProgressBkg angle:-90];
    
    //draw progress
    if (self->_isIndeterminate)
    {
        [self drawIndeterminateProgress:rectProgressBkg];
    }
    else
    {
        [self drawDefaultProgress:rectProgressBkg];        
    }
}

- (void)drawDefaultProgress:(NSRect)rectProgressFrame
{
    //draw progress
    NSRect rectProgress = rectProgressFrame;
    
    rectProgress.size.width = (rectProgress.size.width / 100) * self->_progressValue;
    
    if (rectProgress.size.width > rectProgressFrame.size.width)
    {
        rectProgress.size.width = rectProgressFrame.size.width;
    }
    
    if (self->_isErrorColor)
    {
        [_gradProgressError drawInRect:rectProgress angle:-90];
    }
    else
    {
        [_gradProgress drawInRect:rectProgress angle:-90];
    }
}

- (void)drawIndeterminateProgress:(NSRect)rectProgressFrame
{
    //draw progress
    NSRect rectProgress = rectProgressFrame;
    
    rectProgress.size.width = rectProgressFrame.size.width;
    
    if (self->_isErrorColor)
    {
        [_gradProgressError drawInRect:rectProgress angle:-90];
    }
    else
    {
        [_gradProgress drawInRect:rectProgress angle:-90];
    }
    
    //draw strip bars
    NSRect rectBarsFrame = NSInsetRect(rectProgress, 1, 1);
    
    int barCount = 3;
    
    CGFloat barWidth = rectBarsFrame.size.height;

    CGFloat space = (rectBarsFrame.size.width - ((barWidth + barWidth) * barCount)) * 0.5;

    CGFloat offset = barWidth + space;

    for (int index = 0; index < barCount; index++)
    {
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        NSPoint point = NSMakePoint(rectBarsFrame.origin.x + offset, rectBarsFrame.origin.y);
        [path moveToPoint:point];
        
        point = NSMakePoint(point.x - barWidth, rectBarsFrame.origin.y + rectBarsFrame.size.height);
        [path lineToPoint:point];
        
        point = NSMakePoint(point.x + barWidth, point.y);
        [path lineToPoint:point];
        
        point = NSMakePoint(point.x + barWidth, point.y - rectBarsFrame.size.height);
        [path lineToPoint:point];
        
        point = NSMakePoint(point.x + barWidth, point.y);
        [path lineToPoint:point];

        [path closePath];

        [path setLineWidth:barWidth];
        [NSColor.whiteColor set];
        [path fill];
        
        offset += (barWidth * 2);
    }
}

- (void)setProgressValue:(long)value
{
    if (value == _progressValue)
    {
        return;
    }
    
    _progressValue = value;
    
    [_dockTile display];    
}

- (void)setIsProgressVisible:(BOOL)value
{
    _isProgressVisible = value;
 
    if (_isProgressVisible)
    {
        [_dockTile setContentView:self];
    }
    else
    {
        [NSApp setApplicationIconImage:nil];
        [_dockTile setContentView:nil];
    }
    
    [_dockTile display];
}

- (void)setIsErrorColor:(BOOL)value
{
    if (self->_isErrorColor != value)
    {
        self->_isErrorColor = value;
        
        if (self->_isProgressVisible)
        {
            [_dockTile display];
        }
    }
}

- (void)showDefault
{
    self->_isIndeterminate = NO;

    self.isProgressVisible = YES;
}

- (void)showIndeterminate
{
    self->_isIndeterminate = YES;

    self.isProgressVisible = YES;
}

- (void)hide
{
    self.isProgressVisible = NO;
}

@end
