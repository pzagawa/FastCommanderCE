//
//  FMResources.m
//  FastCommander
//
//  Created by Piotr Zagawa on 21.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMResources.h"
#import "FMThemeManager.h"

@implementation FMResources
{
    FMTheme *_theme;
}

+ (FMResources *)instance
{
    static FMResources *singleton = nil;
    
    @synchronized(self)
    {
        if (!singleton)
        {
            singleton = [[FMResources alloc] init];
        }
        
        return singleton;
    }
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self updateTheme];
        
        self.imageModeSource = [NSImage imageNamed:@"icon_panel_source"];
        self.imageModeTarget = [NSImage imageNamed:@"icon_panel_target"];
        
        self.imageOperationCopy = [NSImage imageNamed:@"toolbarCopyTemplate"];
        self.imageOperationMove = [NSImage imageNamed:@"toolbarMoveTemplate"];
        
        //shadow btn down
        self.shadowBtnDown = [[NSShadow alloc] init];
        [self.shadowBtnDown setShadowBlurRadius:0.0f];
        [self.shadowBtnDown setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [self.shadowBtnDown setShadowColor:[NSColor whiteColor]];
        
        //shadow btn up
        self.shadowBtnUp = [[NSShadow alloc] init];
        [self.shadowBtnUp setShadowBlurRadius:1.0f];
        [self.shadowBtnUp setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [self.shadowBtnUp setShadowColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5]];

        //observe theme change
        [FMThemeManager.instance addObserver:self forKeyPath:@"theme" options:0 context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == FMThemeManager.instance)
    {
        if ([keyPath isEqualToString:@"theme"])
        {
            [self updateTheme];
        }
    }
}

- (void)updateTheme
{
    self->_theme = FMThemeManager.instance.theme;
    
    NSImage *imageItemSelected = [NSImage imageNamed:@"icon_item_selected"];
    
    self.imageItemSelected = [self imageTintedWithColor:_theme.iconSelectedRow image:[imageItemSelected copy]];
    self.imageItemSelectedInverted = [self imageTintedWithColor:_theme.iconSelectedRowInv image:[imageItemSelected copy]];
}

- (NSImage *)imageTintedWithColor:(NSColor *)tint image:(NSImage *)image
{
    if (tint)
    {
        [image lockFocus];
        [tint set];
        
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);

        [image unlockFocus];
    }
    
    return image;
}

@end
