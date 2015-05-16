//
//  FMLightProgressBar.m
//  TestCustomTopHeader
//
//  Created by Piotr Zagawa on 13.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMLightProgressBar.h"

@implementation FMLightProgressBar
{
    long long _progressValue;
    NSString *_progressText;

    NSFont *_textFont;

    NSColor *_textColor0;
    NSColor *_textColor1;
    NSColor *_textColor2;
    NSColor *_textColor3;

    NSColor *_frameColor;
    NSColor *_bkgColor;
    
    NSGradient *_bkgGradient;
    
    NSGradient *_progressGradient1;
    NSGradient *_progressGradient2;
    NSGradient *_progressGradient3;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self->_progressText = @"";
        
        self->_progressValue = 0;
        self->_progressMin = 0;
        self->_progressMax = 100;

        _textFont = [NSFont fontWithName:@"Lucida Grande" size:11];

        _textColor0 = [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        _textColor1 = [NSColor colorWithCalibratedRed:0.0 green:0.15 blue:0.0 alpha:1.0];
        _textColor2 = [NSColor colorWithCalibratedRed:0.2 green:0.1 blue:0.0 alpha:1.0];
        _textColor3 = [NSColor colorWithCalibratedRed:0.3 green:0.0 blue:0.1 alpha:1.0];

        _frameColor = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        _bkgColor = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        
        NSArray *bkgGradientColors = @[[NSColor colorWithDeviceRed:0.92 green:0.92 blue:0.92 alpha:1.0],
                                       [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1.0]];
        
        _bkgGradient = [[NSGradient alloc] initWithColors:bkgGradientColors];
        
        //gradient 1
        NSArray *progressGradientColors1 = @[[NSColor colorWithDeviceRed:0.3 green:0.9 blue:0.7 alpha:1.0],
                                             [NSColor colorWithDeviceRed:0.3 green:0.9 blue:0.7 alpha:1.0]];
        
        _progressGradient1 = [[NSGradient alloc] initWithColors:progressGradientColors1];

        //gradient 2
        NSArray *progressGradientColors2 = @[[NSColor colorWithDeviceRed:1 green:0.85 blue:0.6 alpha:1.0],
                                             [NSColor colorWithDeviceRed:1 green:0.85 blue:0.6 alpha:1.0]];

        _progressGradient2 = [[NSGradient alloc] initWithColors:progressGradientColors2];

        //gradient 3
        NSArray *progressGradientColors3 = @[[NSColor colorWithDeviceRed:1 green:0.8 blue:0.9 alpha:1.0],
                                             [NSColor colorWithDeviceRed:1 green:0.8 blue:0.9 alpha:1.0]];
        
        _progressGradient3 = [[NSGradient alloc] initWithColors:progressGradientColors3];
    }
    
    return self;
}

- (int)progressType
{
    long long valueWarning = self.progressMax - (self.progressMax * 0.20);
    long long valueCritical = self.progressMax - (self.progressMax * 0.10);
    
    if (self.progressValue > valueCritical)
    {
        return 3;
    }
    
    if (self.progressValue > valueWarning)
    {
        return 2;
    }
    
    if (self.progressValue == 0)
    {
        return 0;
    }
    
    return 1;
}

- (NSGradient *)progressGradient
{
    int type = self.progressType;
    
    if (type == 3)
    {
        return _progressGradient3;
    }

    if (type == 2)
    {
        return _progressGradient2;
    }

    return _progressGradient1;
}

- (NSColor *)textColor
{
    int type = self.progressType;
    
    if (type == 3)
    {
        return _textColor3;
    }
    
    if (type == 2)
    {
        return _textColor2;
    }

    if (type == 1)
    {
        return _textColor1;
    }

    return _textColor0;
}

- (void)setProgressValue:(long long)value
{
    if (value == _progressValue)
    {
        return;
    }
    
    _progressValue = value;
    
    [self setNeedsDisplay:YES];
}

- (long long)progressValue
{
    return _progressValue;
}

- (void)setProgressText:(NSString *)value
{
    if ([value isEqualToString:_progressText])
    {
        return;
    }
    
    _progressText = [value copy];
    
    [self setNeedsDisplay:YES];
}

- (NSString *)progressText
{
    return _progressText;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //draw frame
    NSRect frameBounds = dirtyRect;
    
    [_frameColor set];

    NSRectFill(frameBounds);

    //draw background
    NSRect bkgBounds = NSInsetRect(dirtyRect, 1, 1);
    
    [_bkgGradient drawInRect:bkgBounds angle:-90];
    
    //progress bar
    NSRect progressBounds = NSInsetRect(dirtyRect, 1, 1);
    
    [self drawProgressBar:progressBounds];

    //text on progress
    [self drawText:progressBounds];
}

- (void)drawProgressBar:(NSRect)progressBounds
{
    NSRect rect = progressBounds;
 
    //calc rect width
    long long range = llabs(self.progressMax - self.progressMin);
    
    double step = (double)(rect.size.width) / (double)range;
    
    rect.size.width = self.progressValue * step;
    
    if (rect.size.width > progressBounds.size.width)
    {
        rect.size.width = progressBounds.size.width;
    }
    
    //draw
    [self.progressGradient drawInRect:rect angle:-90];
}

- (void)drawText:(NSRect)rect
{
    NSDictionary *_textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:_textFont, NSFontAttributeName, self.textColor, NSForegroundColorAttributeName, nil];

    NSAttributedString *text = [[NSAttributedString alloc] initWithString:self.progressText attributes:_textAttributes];
    
    float posX = (rect.size.width * 0.5f) - (text.size.width * 0.5f);
    
    float rectCenterY = (float)(rect.size.height) * 0.5f;

    float textHeight = [_textFont ascender] + fabs([_textFont descender]) + _textFont.leading - 1;

    float textCenterY = (textHeight * 0.5f);
    
    float posY = rectCenterY - textCenterY;
    
    [text drawAtPoint:NSMakePoint(posX, posY)];
}

@end
