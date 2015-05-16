//
//  FMAdvancedComboSheetItem.m
//  FastCommander
//
//  Created by Piotr Zagawa on 20.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMAdvancedComboSheetItem.h"
#import "FMAdvancedComboSheetController.h"
#import "NSString+Utils.h"

@implementation FMAdvancedComboSheetItem
{
    NSString *_text;
    NSString *_title;
    NSString *_description;
    
    NSFont *_textTitleFont;
    NSColor *_textTitleColor;

    NSFont *_textDescriptionFont;
    NSColor *_textDescriptionColor;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.isSelected = NO;
        
        _textTitleFont = [NSFont fontWithName:@"Lucida Grande" size:13];
        _textTitleColor = [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:1.0];

        _textDescriptionFont = [NSFont fontWithName:@"Lucida Grande" size:11];
        _textDescriptionColor = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    }
    
    return self;
}

- (void)setDescription:(NSString *)value
{
    _text = [value copy];
    _description = [[[value trim] stringByDeletingSlashSuffix] lowercaseString];
    _title = [[_description lastPathComponent] uppercaseString];
    
    if ([_text isEqualToString:@"/"])
    {
        _description = _text;
        _title = @"ROOT DIRECTORY";
    }
    
    [self updateIconFromDescription];
}

- (NSString *)description
{
    return _description;
}

- (NSString *)title
{
    return _title;
}

- (NSString *)text
{
    return _text;
}

- (void)updateIconFromDescription
{
    self.icon = [NSWorkspace.sharedWorkspace iconForFile:self.description];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect rect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    //draw background
    if (self.isSelected)
    {
        [[NSColor selectedTextBackgroundColor] setFill];
        
        NSRectFill(rect);
    }
    else
    {
        [[NSColor whiteColor] setFill];

        NSRectFill(rect);
    }
    
    //draw a bottom divider
    NSRect rectBorder = rect;
    
    NSColor *borderColor  = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
    [borderColor set];
    
    NSPoint lineStart = NSMakePoint(rectBorder.origin.x, rectBorder.origin.y);
    NSPoint lineEnd = NSMakePoint(rectBorder.origin.x + rectBorder.size.width, rectBorder.origin.y);
    
    [NSBezierPath strokeLineFromPoint:lineStart toPoint:lineEnd];

    //icon rect
    NSRect iconRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.height, rect.size.height);

    //item icon
    if (self.icon != nil)
    {
        [self drawIcon:iconRect];
    }
    
    //right content rect
    NSRect textRect = NSMakeRect(iconRect.origin.x + iconRect.size.width, iconRect.origin.y, rect.size.width - iconRect.size.width, rect.size.height);

    CGFloat dividerPosY = textRect.size.height * 0.5;

    //right content title
    NSRect textTitleRect = NSMakeRect(textRect.origin.x, textRect.size.height - dividerPosY, textRect.size.width, textRect.size.height - dividerPosY);
    
    [self drawTitleText:_title inRectangle:textTitleRect];

    //right content description
    NSRect textDescriptionRect = NSMakeRect(textRect.origin.x, 0, textRect.size.width, textRect.size.height - textTitleRect.size.height);
    
    [self drawDescriptionText:_description inRectangle:textDescriptionRect];
}

- (void)drawTitleText:(NSString *)value inRectangle:(NSRect)rect
{
    NSColor *textColor = self.isSelected ? [NSColor selectedTextColor] : _textTitleColor;
    
    NSDictionary *_textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:_textTitleFont, NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];
    
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:value attributes:_textAttributes];
    
    float posX = rect.origin.x + 2;
    
    float posY = rect.origin.y + 1;
    
    [text drawAtPoint:NSMakePoint(posX, posY)];
}

- (void)drawDescriptionText:(NSString *)value inRectangle:(NSRect)rect
{
    NSColor *textColor = self.isSelected ? [NSColor selectedTextColor] : _textDescriptionColor;

    NSDictionary *_textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:_textDescriptionFont, NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];
    
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:value attributes:_textAttributes];
    
    float posX = rect.origin.x + 2;
    
    float posY = rect.origin.y + 9;
    
    [text drawAtPoint:NSMakePoint(posX, posY)];
}

- (void)drawIcon:(NSRect)rect
{
    NSRect iconRect = NSInsetRect(rect, 12, 12);
    
    CGFloat opacity = self.isSelected ? 1.0 : 0.9;
    
    [self.icon drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:opacity];
}

- (BOOL)acceptsFirstResponder
{
    return NO;
}

@end
