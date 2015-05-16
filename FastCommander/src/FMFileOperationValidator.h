//
//  FMFileOperationValidator.h
//  FastCommander
//
//  Created by Piotr Zagawa on 01.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"

@class FMCommand;
@class FMPanelListProvider;

@interface FMFileOperationValidator : NSObject

@property (weak) FMPanelListProvider *sourceProvider;
@property (weak) FMPanelListProvider *targetProvider;

- (id)init;

- (BOOL)validate:(FMCommand *)command;

@end
