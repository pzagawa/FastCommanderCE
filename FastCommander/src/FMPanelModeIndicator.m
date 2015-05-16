//
//  FMPanelModeIndicator.m
//  FastCommander
//
//  Created by Piotr Zagawa on 13.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPanelModeIndicator.h"

@implementation FMPanelModeIndicator
{
    BOOL _isSource;
    
    NSString *_text1;
    NSString *_text2;
    
    NSFont *_textFont;
    
    NSColor *_frameColor;
    NSColor *_bkgColor;
    
    NSGradient *_bkgGradient;
    
    NSGradient *_alternateGradient;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self->_isSource = YES;
        
        self->_text1 = @"SOURCE";
        self->_text2 = @"TARGET";
        
        _textFont = [NSFont fontWithName:@"Lucida Grande" size:11];

        _frameColor = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        _bkgColor = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        
        NSArray *bkgGradientColors = @[[NSColor colorWithDeviceRed:0.92 green:0.92 blue:0.92 alpha:1.0],
                                       [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1.0]];
        
        _bkgGradient = [[NSGradient alloc] initWithColors:bkgGradientColors];
        
        //gradient 1
        NSArray *alternateGradientColors1 = @[[NSColor colorWithDeviceRed:0.5 green:0.9 blue:1 alpha:1.0],
                                             [NSColor colorWithDeviceRed:0.5 green:0.9 blue:1 alpha:1.0]];
        
        _alternateGradient = [[NSGradient alloc] initWithColors:alternateGradientColors1];
    }
    
    return self;
}

- (void)setIsSource:(BOOL)value
{
    if (value == _isSource)
    {
        return;
    }
    
    _isSource = value;
    
    [self setNeedsDisplay:YES];
}

- (BOOL)isSource
{
    return _isSource;
}

- (NSString *)textValue
{
    if (self.isSource)
    {
        return _text1;
    }
    else
    {
        return _text2;
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    //draw frame
    NSRect frameBounds = dirtyRect;
    
    [_frameColor set];

    NSRectFill(frameBounds);

    //draw background
    NSRect bkgBounds = NSInsetRect(dirtyRect, 1, 1);
    
    if (self.isSource)
    {
        [_bkgGradient drawInRect:bkgBounds angle:-90];
    }
    else
    {
        [_alternateGradient drawInRect:bkgBounds angle:-90];
    }

    NSRect innerBounds = NSInsetRect(dirtyRect, 1, 1);

    //text on progress
    [self drawText:innerBounds];
}

- (void)drawText:(NSRect)rect
{
    NSColor *textColor = nil;
    
    if (self.isSource)
    {
        textColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    else
    {
        textColor = [NSColor colorWithCalibratedRed:0.0 green:0.1 blue:0.3 alpha:1.0];
    }
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:_textFont, NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];

    NSAttributedString *text = [[NSAttributedString alloc] initWithString:self.textValue attributes:textAttributes];
    
    float posX = (rect.size.width * 0.5f) - (text.size.width * 0.5f);
    
    float rectCenterY = (float)(rect.size.height) * 0.5f;

    float textHeight = [_textFont ascender] + fabs([_textFont descender]) + _textFont.leading - 1;

    float textCenterY = (textHeight * 0.5f);
    
    float posY = rectCenterY - textCenterY;
    
    [text drawAtPoint:NSMakePoint(posX, posY)];
}

@end
