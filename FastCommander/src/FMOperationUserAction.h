//
//  FMOperationUserAction.h
//  FastCommander
//
//  Created by Piotr Zagawa on 17.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"

@interface FMOperationUserAction : NSObject

typedef enum
{
    FMOperationUserActionType_NONE = 0,
    FMOperationUserActionType_SKIP = 1,
    FMOperationUserActionType_OVERWRITE = 2,
    FMOperationUserActionType_RETRY = 3,
    
} FMOperationUserActionType;

@property (readonly) FMOperationUserActionType actionType;

@property (readonly) BOOL isActionSet;

- (void)reset;

- (void)setAction:(FMOperationUserActionType)action forStatus:(FMFileItemStatus)status;
- (void)setApplyToAll:(BOOL)applyToAll forStatus:(FMFileItemStatus)status;

- (FMOperationUserActionType)actionValueForStatus:(FMFileItemStatus)status;
- (BOOL)applyToAllValueForStatus:(FMFileItemStatus)status;

- (void)resetActionType;
- (void)updateActionTypeForStatus:(FMFileItemStatus)status;

- (NSString *)actionName;

@end
