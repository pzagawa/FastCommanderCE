//
//  FMFileProcessingResolver.h
//  FastCommander
//
//  Created by Piotr Zagawa on 28.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPanelListItem.h"

@interface FMFileProcessingResolver : NSObject

- (id)init;

- (BOOL)onFileItemSelected:(FMPanelListItem *)listItem forPanelSide:(FMPanelSide)panelSide;
- (BOOL)onPathSet:(NSString *)value forPanelSide:(FMPanelSide)panelSide;

@end
