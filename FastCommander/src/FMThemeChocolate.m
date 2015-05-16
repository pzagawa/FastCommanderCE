//
//  FMThemeChocolate.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeChocolate.h"
#import "NSColor+Hex.h"

@implementation FMThemeChocolate

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Black Mesa";

        self.listBackground = [NSColor colorWithHexRGB:0x292421];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0xFF7F24];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x393431];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0xFF6103];
        self.iconSelectedRowInv = [NSColor whiteColor];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0xF4A460];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0xFFDAB9];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x8B4513];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xff6655];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0xF4b470];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0xFFeAc9];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x8B4513];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xff8877];
        
        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor whiteColor];
        self.rowDirectoryHighlightText = [NSColor whiteColor];
        self.rowHiddenHighlightText = [NSColor whiteColor];
        self.rowArchiveHighlightText = [NSColor whiteColor];
        self.rowHighlightTextShadow = [NSColor colorWithHexRGB:0x292421];
    }
    
    return self;
}

@end
