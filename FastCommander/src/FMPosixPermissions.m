//
//  FMPosixPermissions.m
//  FastCommander
//
//  Created by Piotr Zagawa on 22.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPosixPermissions.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMCustomTypes.h"

@implementation FMPosixPermissions
{
    int bits_state_counter[9];
    NSUInteger items_count;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self reset];
    }
    
    return self;
}

- (void)reset
{
    for (int index = 0; index < 9; index++)
    {
        self->bits_state_counter[index] = 0;
    }
    
    items_count = 0;
}

- (void)aggregateFileItemsPermissions:(NSMutableArray *)fileItems withProvider:(FMPanelListProvider *)provider
{
    [self reset];
    
    //iterate items
    for (FMFileItem *fileItem in fileItems)
    {
        NSUInteger permissions = [provider posixPermissionsForPath:fileItem.filePath];
        
        permissions &= 0b111111111;
        
        //user
        bits_state_counter[0] += (permissions & POSIX_BIT_USER_R) >> 8;
        bits_state_counter[1] += (permissions & POSIX_BIT_USER_W) >> 7;
        bits_state_counter[2] += (permissions & POSIX_BIT_USER_X) >> 6;
        
        //group
        bits_state_counter[3] += (permissions & POSIX_BIT_GRUP_R) >> 5;
        bits_state_counter[4] += (permissions & POSIX_BIT_GRUP_W) >> 4;
        bits_state_counter[5] += (permissions & POSIX_BIT_GRUP_X) >> 3;
        
        //other
        bits_state_counter[6] += (permissions & POSIX_BIT_OTHR_R) >> 2;
        bits_state_counter[7] += (permissions & POSIX_BIT_OTHR_W) >> 1;
        bits_state_counter[8] += (permissions & POSIX_BIT_OTHR_X) >> 0;
    }
    
    self->items_count = fileItems.count;
}

//format: 0b000000000 / rwxrwxrwx / ugo
- (NSUInteger)bitsToSet
{
    NSUInteger value = 0;
    
    //user
    value |= (bits_state_counter[0] == self->items_count) ? POSIX_BIT_USER_R : 0;
    value |= (bits_state_counter[1] == self->items_count) ? POSIX_BIT_USER_W : 0;
    value |= (bits_state_counter[2] == self->items_count) ? POSIX_BIT_USER_X : 0;

    //group
    value |= (bits_state_counter[3] == self->items_count) ? POSIX_BIT_GRUP_R : 0;
    value |= (bits_state_counter[4] == self->items_count) ? POSIX_BIT_GRUP_W : 0;
    value |= (bits_state_counter[5] == self->items_count) ? POSIX_BIT_GRUP_X : 0;
    
    //other
    value |= (bits_state_counter[6] == self->items_count) ? POSIX_BIT_OTHR_R : 0;
    value |= (bits_state_counter[7] == self->items_count) ? POSIX_BIT_OTHR_W : 0;
    value |= (bits_state_counter[8] == self->items_count) ? POSIX_BIT_OTHR_X : 0;
    
    return value;
}

//format: 0b000000000 / rwxrwxrwx / ugo
- (NSUInteger)bitsToClear
{
    NSUInteger value = 0;

    //user
    value |= (bits_state_counter[0] == 0) ? POSIX_BIT_USER_R : 0;
    value |= (bits_state_counter[1] == 0) ? POSIX_BIT_USER_W : 0;
    value |= (bits_state_counter[2] == 0) ? POSIX_BIT_USER_X : 0;
    
    //group
    value |= (bits_state_counter[3] == 0) ? POSIX_BIT_GRUP_R : 0;
    value |= (bits_state_counter[4] == 0) ? POSIX_BIT_GRUP_W : 0;
    value |= (bits_state_counter[5] == 0) ? POSIX_BIT_GRUP_X : 0;
    
    //other
    value |= (bits_state_counter[6] == 0) ? POSIX_BIT_OTHR_R : 0;
    value |= (bits_state_counter[7] == 0) ? POSIX_BIT_OTHR_W : 0;
    value |= (bits_state_counter[8] == 0) ? POSIX_BIT_OTHR_X : 0;
    
    return value;
}

+ (NSString *)octalTextFromBits:(NSUInteger)bitsToSet
{
    NSUInteger user = (bitsToSet & POSIX_BITS_USER) >> 6;
    NSUInteger grup = (bitsToSet & POSIX_BITS_GRUP) >> 3;
    NSUInteger othr = (bitsToSet & POSIX_BITS_OTHR);
    
    return [NSString stringWithFormat:@"%ld%ld%ld", user, grup, othr];
}

+ (NSUInteger)bitsFromOctalText:(NSString *)octalText
{
    if (octalText != nil)
    {
        if (octalText.length == 3)
        {
            NSUInteger value = 0;
            
            NSUInteger userValue = [[octalText substringWithRange:NSMakeRange(0, 1)] integerValue];
            NSUInteger grupValue = [[octalText substringWithRange:NSMakeRange(1, 1)] integerValue];
            NSUInteger othrValue = [[octalText substringWithRange:NSMakeRange(2, 1)] integerValue];
            
            if (userValue <= 7)
            {
                value |= userValue << 6;
            }
            
            if (grupValue <= 7)
            {
                value |= grupValue << 3;
            }
            
            if (othrValue <= 7)
            {
                value |= othrValue;
            }
            
            return value;
        }
    }
    
    return 0;
}

+ (NSCellStateValue)state:(NSUInteger)mask withBitsToSet:(NSUInteger)bitsToSet andBitsToClear:(NSUInteger)bitsToClear
{
    if ((bitsToSet & mask) > 0)
    {
        return NSOnState;
    }
    
    if ((bitsToClear & mask) > 0)
    {
        return NSOffState;
    }
    
    return NSMixedState;
}

@end
