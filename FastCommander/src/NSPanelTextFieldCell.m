//
//  NSPanelTextFieldCell.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "NSPanelTextFieldCell.h"

@implementation NSPanelTextFieldCell

@synthesize tableView;

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    return nil;
}

@end
