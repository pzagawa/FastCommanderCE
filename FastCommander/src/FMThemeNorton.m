//
//  FMThemeNorton.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeNorton.h"
#import "NSColor+Hex.h"

@implementation FMThemeNorton

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Norton";
        
        self.listBackground = [NSColor colorWithHexRGB:0x24246A];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0x0099cc];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x34347A];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0x0099cc];
        self.iconSelectedRowInv = [NSColor whiteColor];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0x43CD80];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0xf0f0f0];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x606060];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xff7799];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0x63eDb0];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0xf8f8ff];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x9090a0];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xff99bb];
        
        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor whiteColor];
        self.rowDirectoryHighlightText = [NSColor whiteColor];
        self.rowHiddenHighlightText = [NSColor whiteColor];
        self.rowArchiveHighlightText = [NSColor whiteColor];
        self.rowHighlightTextShadow = [NSColor colorWithHexRGB:0x080855];
    }
    
    return self;
}

@end
