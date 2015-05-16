//
//  FMOperationCommandSupport.h
//  FastCommander
//
//  Created by Piotr Zagawa on 20.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"

@interface FMOperationCommandSupport : NSObject

- (void)set:(FMCommandId)commandId modeSource:(BOOL)modeSource modeTarget:(BOOL)modeTarget;
- (BOOL)isOperationCommand:(FMCommandId)commandId withMode:(FMPanelMode)panelMode;

@end
