//
//  FMFileTableViewDrawRow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 27.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFilesTableView.h"

@interface FMFilesTableViewDrawRow : NSObject

@property (weak) FMFilesTableView *tableView;

- (void)draw:(NSInteger)rowIndex clipRect:(NSRect)clipRect listItem:(FMPanelListItem *)listItem;

- (void)updateTheme;

@end
