//
//  FMPanelSortIndicator.h
//  FastCommander
//
//  Created by Piotr Zagawa on 03.01.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMPanelSortIndicator : NSButton

@property BOOL isSortMode;

@property BOOL isDirectionASC;
@property (copy) NSString *sortKey;

- (void)redraw;

@end
