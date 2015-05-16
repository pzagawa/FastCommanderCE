//
//  FMBufferFinder.m
//  FastCommander
//
//  Created by Piotr Zagawa on 22.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMBufferFinder.h"
#import "FMBufferFinderText.h"

@implementation FMBufferFinder
{
    NSString *_text;
    NSMutableArray *_finderTextList;
}

- (id)initWithText:(NSString *)text
{
    self = [super init];
    
    if (self)
    {
        self->_text = text;
        
        self->_finderTextList = [FMBufferFinderText encodedTextList:text];
    }
    
    return self;
}

- (void)reset
{
    for (FMBufferFinderText *finderText in self->_finderTextList)
    {
        [finderText reset];
    }
    
    self->_isPatternMatch = NO;
    self->_matchPosition = -1;
}

- (BOOL)process:(uint8_t *)buffer withSize:(NSInteger)size
{
    if (self->_finderTextList.count == 0)
    {
        return NO;
    }
    
    for (FMBufferFinderText *finderText in self->_finderTextList)
    {
        [finderText testPatternMatch:buffer withSize:size];
    
        if (finderText.isPatternMatch)
        {
            self->_isPatternMatch = YES;
            self->_matchPosition = finderText.matchPosition;
            break;
        }
    }

    return YES;
}

@end
