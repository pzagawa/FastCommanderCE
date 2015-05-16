//
//  FMContextMenu.h
//  FastCommander
//
//  Created by Piotr Zagawa on 27.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMPanelListItem;
@class FMPanelListProvider;

@interface FMContextMenuAppItem : NSObject

@property NSURL *fileUrl;
@property NSURL *appUrl;

@end

@interface FMContextMenu : NSObject

- (NSMenu *)menuForItem:(FMPanelListItem *)listItem;

- (void)actionOpenWith:(id)sender;
- (void)actionCheckSize:(id)sender;

@end
