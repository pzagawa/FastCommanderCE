//
//  FMThemeSublime.m
//  FastCommander
//
//  Created by Piotr Zagawa on 29.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeSublime.h"
#import "NSColor+Hex.h"

@implementation FMThemeSublime

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Sublime";

        self.listBackground = [NSColor colorWithHexRGB:0x272823];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0xffe792];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x383730];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0xfd9720];
        self.iconSelectedRowInv = [NSColor colorWithHexRGB:0x272823];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0x8f908a];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0xf8f8f2];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x75715c];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xfd9720];

        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0xe6db74];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0x66d9e7];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0xf9285d];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xa6de28];
        
        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor colorWithHexRGB:0x000000];;
        self.rowDirectoryHighlightText = [NSColor colorWithHexRGB:0x000000];
        self.rowHiddenHighlightText = [NSColor colorWithHexRGB:0x000000];
        self.rowArchiveHighlightText = [NSColor colorWithHexRGB:0x000000];
        self.rowHighlightTextShadow = [NSColor colorWithHexRGB:0xaf9732];
    }
    
    return self;
}

@end
