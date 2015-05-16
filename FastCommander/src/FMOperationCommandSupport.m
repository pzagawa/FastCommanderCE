//
//  FMOperationCommandSupport.m
//  FastCommander
//
//  Created by Piotr Zagawa on 20.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationCommandSupport.h"

@implementation FMOperationCommandSupport
{
    NSMutableDictionary *_map;
}

static const long value_source = 0x00ff;
static const long value_target = 0xff00;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_map = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSNumber *)encodeModeSource:(BOOL)modeSource andModeTarget:(BOOL)modeTarget
{
    long valueSource = modeSource ? value_source : 0;
    long valueTarget = modeTarget ? value_target : 0;

    return [NSNumber numberWithLong:(valueSource | valueTarget)];
}

- (BOOL)isModeSource:(NSNumber *)value
{
    if ((value.longValue & value_source) == value_source)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isModeTarget:(NSNumber *)value
{
    if ((value.longValue & value_target) == value_target)
    {
        return YES;
    }
    
    return NO;
}

- (void)set:(FMCommandId)commandId modeSource:(BOOL)modeSource modeTarget:(BOOL)modeTarget
{
    NSNumber *key = [NSNumber numberWithLong:commandId];
    
    NSNumber *value = [self encodeModeSource:modeSource andModeTarget:modeTarget];
    
    [self->_map setObject:value forKey:key];
}

- (BOOL)isOperationCommand:(FMCommandId)commandId withMode:(FMPanelMode)panelMode
{
    NSNumber *key = [NSNumber numberWithLong:commandId];

    NSNumber *value = [self->_map objectForKey:key];

    if (value != nil)
    {
        if (panelMode == FMPanelModeSource)
        {
            return [self isModeSource:value];
        }
        
        if (panelMode == FMPanelModeTarget)
        {
            return [self isModeTarget:value];
        }
    }
    
    return NO;
}

@end
