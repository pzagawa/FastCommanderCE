//
//  FMThemeCustom1.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeCustom1.h"
#import "NSColor+Hex.h"

@implementation FMThemeCustom1

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Mono";
        
        self.listBackground = [NSColor colorWithHexRGB:0x1E1E1E];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0x606060];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x101010];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0x035D20];
        self.iconSelectedRowInv = [NSColor colorWithHexRGB:0xa0a0a0];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0xa0a0a0];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0xe8e8e8];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x585858];
        self.rowArchiveText = [NSColor colorWithHexRGB:0x587868];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0x43bD80];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0x63eDb0];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x239D60];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0x43bD80];
        
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
