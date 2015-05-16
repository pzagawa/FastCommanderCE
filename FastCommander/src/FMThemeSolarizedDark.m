//
//  FMThemeSolarizedDark.m
//  FastCommander
//
//  Created by Piotr Zagawa on 26.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeSolarizedDark.h"
#import "NSColor+Hex.h"

@implementation FMThemeSolarizedDark

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Solarized Dark";
        
        self.listBackground = [NSColor colorWithHexRGB:0x002b36];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0x268bd2];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x073642];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0x268bd2];
        self.iconSelectedRowInv = [NSColor colorWithHexRGB:0xfdf6e3];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0x839496];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0x93a1a1];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x586e75];
        self.rowArchiveText = [NSColor colorWithHexRGB:0xcb4b16];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0x839496];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0x93a1a1];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x586e75];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0xcb4b16];
        
        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor colorWithHexRGB:0xfdf6e3];
        self.rowDirectoryHighlightText = [NSColor colorWithHexRGB:0xfdf6e3];
        self.rowHiddenHighlightText = [NSColor colorWithHexRGB:0xfdf6e3];
        self.rowArchiveHighlightText = [NSColor colorWithHexRGB:0xfdf6e3];
        self.rowHighlightTextShadow = [NSColor colorWithHexRGB:0x060b62];
    }
    
    return self;
}

@end
