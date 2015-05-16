//
//  FMThemeMac.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeMac.h"
#import "NSColor+Hex.h"

@implementation FMThemeMac

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Mac";

        self.listBackground = [NSColor whiteColor];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0xff9944];
        self.listSelectedRow = [NSColor colorWithHexRGB:0xf4f4f4];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0x1C86EE];
        self.iconSelectedRowInv = [NSColor whiteColor];

        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0x666666];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0x2a2a2a];
        self.rowHiddenText = [NSColor colorWithHexRGB:0xa6a6a6];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xff4466];

        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0x4b6b9b];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0x2b4b7b];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x7babdb];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xff4488];

        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor whiteColor];
        self.rowDirectoryHighlightText = [NSColor whiteColor];
        self.rowHiddenHighlightText = [NSColor whiteColor];
        self.rowArchiveHighlightText = [NSColor whiteColor];
        self.rowHighlightTextShadow = [NSColor colorWithHexRGB:0x884400];
    }
    
    return self;
}

@end
