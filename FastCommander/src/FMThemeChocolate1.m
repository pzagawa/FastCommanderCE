//
//  FMThemeChocolate1.m
//  FastCommander
//
//  Created by Piotr Zagawa on 02.11.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeChocolate1.h"
#import "NSColor+Hex.h"

@implementation FMThemeChocolate1

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Black Mesa Low";

        self.listBackground = [NSColor colorWithHexRGB:0x181412];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0xaa4400];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x080402];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0xcc6600];
        self.iconSelectedRowInv = [NSColor whiteColor];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0xbb9977];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0xddccbb];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x554433];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xdd5555];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0xcc8866];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0xeeddcc];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x554433];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xee5555];
        
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
