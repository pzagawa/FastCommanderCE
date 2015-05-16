//
//  NSPanelTextFieldCell.h
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMFilesTableView.h"

@interface NSPanelTextFieldCell : NSTextFieldCell

@property (weak) FMFilesTableView *tableView;

- (id)init;
- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
