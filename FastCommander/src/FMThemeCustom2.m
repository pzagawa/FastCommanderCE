//
//  FMThemeCustom2.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeCustom2.h"
#import "NSColor+Hex.h"

@implementation FMThemeCustom2

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Black";
        
        self.listBackground = [NSColor blackColor];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0x80629D];
        self.listSelectedRow = [NSColor blackColor];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0x678CB1];
        self.iconSelectedRowInv = [NSColor colorWithHexRGB:0xa7cCf1];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0xC0C0C0];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0x7D8C93];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x2F393C];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xa57b61];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0xe0e0e0];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0x9DaCb3];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x4F595C];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xc59b81];
        
        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor whiteColor];
        self.rowDirectoryHighlightText = [NSColor whiteColor];
        self.rowHiddenHighlightText = [NSColor whiteColor];
        self.rowArchiveHighlightText = [NSColor whiteColor];
        self.rowHighlightTextShadow = [NSColor blackColor];
    }
    
    return self;
}

@end
