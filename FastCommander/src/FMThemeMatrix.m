//
//  FMThemeMatrix.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeMatrix.h"
#import "NSColor+Hex.h"

@implementation FMThemeMatrix

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.themeName = @"Matrix";

        self.listBackground = [NSColor colorWithHexRGB:0x002200];
        self.listHighlightedRow = [NSColor colorWithHexRGB:0x00CD00];
        self.listSelectedRow = [NSColor colorWithHexRGB:0x002a00];
        self.iconSelectedRow = [NSColor colorWithHexRGB:0x3D9140];
        self.iconSelectedRowInv = [NSColor colorWithHexRGB:0x010101];
        
        //default row text color set
        self.rowDefaultText = [NSColor colorWithHexRGB:0x3D9140];
        self.rowDirectoryText = [NSColor colorWithHexRGB:0x43CD80];
        self.rowHiddenText = [NSColor colorWithHexRGB:0x256B54];
        self.rowArchiveText = [NSColor colorWithHexRGB:0x44cc99];
        
        //selected row text color set
        self.rowDefaultSelectedText = [NSColor colorWithHexRGB:0x2D8130];
        self.rowDirectorySelectedText = [NSColor colorWithHexRGB:0x33bD70];
        self.rowHiddenSelectedText = [NSColor colorWithHexRGB:0x155B44];
        self.rowArchiveSelectedText = [NSColor colorWithHexRGB:0x34bc89];
        
        //highlighted row text color set
        self.rowDefaultHighlightText = [NSColor colorWithHexRGB:0x010101];
        self.rowDirectoryHighlightText = [NSColor colorWithHexRGB:0x010101];
        self.rowHiddenHighlightText = [NSColor colorWithHexRGB:0x010101];
        self.rowArchiveHighlightText = [NSColor colorWithHexRGB:0x010101];
        self.rowHighlightTextShadow = [NSColor colorWithHexRGB:0x008800];
    }
    
    return self;
}

@end
