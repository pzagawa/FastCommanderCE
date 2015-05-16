//
//  FMCommandManager.h
//  FastCommander
//
//  Created by Piotr Zagawa on 09.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCommand.h"

@interface FMCommandManager : NSObject

+ (void)executeCommand:(FMCommand *)command;

@end
