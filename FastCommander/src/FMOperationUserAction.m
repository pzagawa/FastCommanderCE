//
//  FMOperationUserAction.m
//  FastCommander
//
//  Created by Piotr Zagawa on 17.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationUserAction.h"

@implementation FMOperationUserAction
{
    NSMutableDictionary *_mapOperationStatusToAction;
    NSMutableDictionary *_mapOperationStatusToApplyToAll;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_mapOperationStatusToAction = [[NSMutableDictionary alloc] init];
        self->_mapOperationStatusToApplyToAll = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)reset
{
    [self->_mapOperationStatusToAction removeAllObjects];
    [self->_mapOperationStatusToApplyToAll removeAllObjects];
}

- (void)setAction:(FMOperationUserActionType)action forStatus:(FMFileItemStatus)status
{
    NSNumber *key = [NSNumber numberWithInteger:status];
    
    NSNumber *value = [NSNumber numberWithLong:action];
    
    [self->_mapOperationStatusToAction setObject:value forKey:key];
}

- (void)setApplyToAll:(BOOL)applyToAll forStatus:(FMFileItemStatus)status
{
    NSNumber *key = [NSNumber numberWithInteger:status];
    
    NSNumber *value = [NSNumber numberWithBool:applyToAll];
    
    [self->_mapOperationStatusToApplyToAll setObject:value forKey:key];
}

- (FMOperationUserActionType)actionValueForStatus:(FMFileItemStatus)status
{
    NSValue *key = [NSNumber numberWithInteger:status];

    NSNumber *value = [self->_mapOperationStatusToAction objectForKey:key];
    
    if (value == nil)
    {
        return FMOperationUserActionType_NONE;
    }
    
    return (FMOperationUserActionType)value.longValue;
}

- (BOOL)applyToAllValueForStatus:(FMFileItemStatus)status
{
    NSValue *key = [NSNumber numberWithInteger:status];
    
    NSNumber *value = [self->_mapOperationStatusToApplyToAll objectForKey:key];
    
    if (value == nil)
    {
        return NO;
    }
    
    return value.boolValue;
}

- (void)resetActionType
{
    self->_actionType = FMOperationUserActionType_NONE;
}

- (void)updateActionTypeForStatus:(FMFileItemStatus)status
{
    FMOperationUserActionType actionType = [self actionValueForStatus:status];
    
    if (actionType != FMOperationUserActionType_NONE)
    {
        BOOL applyToAll = [self applyToAllValueForStatus:status];
        
        if (applyToAll)
        {
            self->_actionType = actionType;
            return;
        }
    }
    
    self->_actionType = FMOperationUserActionType_NONE;
}

- (NSString *)actionName
{
    switch (self.actionType)
    {
        case FMOperationUserActionType_NONE:
            return @"";
        case FMOperationUserActionType_SKIP:
            return @"SKIPPING";
        case FMOperationUserActionType_OVERWRITE:
            return @"OVERWRITING";
        case FMOperationUserActionType_RETRY:
            return @"RETRYING";
        default:
            return @"";
    }
}

- (BOOL)isActionSet
{
    if (self.actionType == FMOperationUserActionType_NONE)
    {
        return NO;
    }
    
    return YES;
}

@end
