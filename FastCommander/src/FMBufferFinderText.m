//
//  FMBufferFinderText.m
//  FastCommander
//
//  Created by Piotr Zagawa on 22.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMBufferFinderText.h"

@implementation FMBufferFinderText
{
    NSData *_encoded1;
    NSData *_encoded2;
    
    long _patternIndex;
    
    long long _totalPosition;
    
    uint8_t *_startBuffer;
}

- (id)initText:(NSString *)text withEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    
    if (self)
    {
        [self reset];

        //create encoded binary patterns
        NSString *lcase = text.lowercaseString;
        NSString *ucase = text.uppercaseString;
        
        if (lcase.length == ucase.length)
        {
            self->_encoded1 = [self validate:[lcase dataUsingEncoding:encoding]];
            self->_encoded2 = [self validate:[ucase dataUsingEncoding:encoding]];
        }
        else
        {
            self->_encoded1 = [self validate:[text dataUsingEncoding:encoding]];
            self->_encoded2 = nil;
        }
    }
    
    return self;
}

- (NSData *)validate:(NSData *)data
{
    if (data != nil)
    {
        if (data.length > 0)
        {
            return data;
        }
    }
    
    return nil;
}

- (void)reset
{
    self->_patternIndex = 0;
    self->_totalPosition = 0;
    self->_matchPosition = -1;
}

- (void)testPatternMatch:(uint8_t *)buffer withSize:(NSInteger)size
{
    if (self.isPatternMatch)
    {
        return;
    }
    
    _startBuffer = buffer;
    
    [self testPatternMatchBuffer:buffer withSize:size];        

    _totalPosition += size;
}

- (void)testPatternMatchBuffer:(uint8_t *)buffer withSize:(NSInteger)size
{
    uint8_t *endLocation = buffer + size;

    uint8_t *startLocation = nil;

    if (_patternIndex == 0)
    {
        startLocation = [self startLocation:buffer withEndLocation:endLocation];
    }
    else
    {
        startLocation = buffer;
    }
    
    if (startLocation != nil)
    {
        while (startLocation < endLocation)
        {
            if ([self isPatternMatchLocation:startLocation])
            {
                //byte is equal, check next one
                _patternIndex++;
                startLocation++;
                
                if (self.isPatternMatch)
                {
                    break;
                }
            }
            else
            {
                //byte NOT equal, start again from next location
                startLocation++;
                
                startLocation = [self startLocation:startLocation withEndLocation:endLocation];
                
                if (startLocation == nil)
                {
                    break;
                }
            }
        }
    }
}

//returns location of first matching byte of encoded1 OR encoded2 pattern
- (uint8_t *)startLocation:(uint8_t *)bufferStart withEndLocation:(uint8_t *)bufferEnd
{
    _patternIndex = 0;
    
    size_t size = bufferEnd - bufferStart;

    uint8_t *location = nil;

    uint8_t *location1 = nil;
    uint8_t *location2 = nil;
    
    if (self->_encoded1 != nil)
    {
        uint8_t *patternBytes = (uint8_t *)_encoded1.bytes;
        
        uint8_t patternByte = patternBytes[_patternIndex];
        
        location1 = memchr(bufferStart, patternByte, size);
    }

    if (self->_encoded2 != nil)
    {
        uint8_t *patternBytes = (uint8_t *)_encoded2.bytes;
        
        uint8_t patternByte = patternBytes[_patternIndex];
        
        location2 = memchr(bufferStart, patternByte, size);
    }
    
    if (location1 == nil)
    {
        location = location2;
    }

    if (location2 == nil)
    {
        location = location1;
    }
    
    if (location1 != nil && location2 != nil)
    {
        location = (location1 < location2) ? location1 : location2;
    }

    size_t offset = location - _startBuffer;

    _matchPosition = _totalPosition + offset;

    return location;
}

- (BOOL)isPatternMatchLocation:(uint8_t *)location
{
    if ([self isPattern:_encoded1 matchLocation:location])
    {
        return YES;
    }

    if ([self isPattern:_encoded2 matchLocation:location])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPattern:(NSData *)pattern matchLocation:(uint8_t *)location
{
    if (pattern == nil)
    {
        return NO;
    }
    
    uint8_t *patternBytes = (uint8_t *)pattern.bytes;
        
    uint8_t patternByte = patternBytes[_patternIndex];
        
    if (*location == patternByte)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPatternMatch
{
    if (_patternIndex == self->_encoded1.length)
    {
        return YES;
    }

    return NO;
}

+ (void)addText:(NSString *)text withEncoding:(NSStringEncoding)encoding toArray:(NSMutableArray *)list
{
    FMBufferFinderText *item = [[FMBufferFinderText alloc] initText:text withEncoding:encoding];
    
    if (item->_encoded1 != nil)
    {
        [list addObject:item];
    }
}

+ (NSMutableArray *)encodedTextList:(NSString *)text
{
    NSMutableArray *list = [[NSMutableArray alloc] init];

    [self addText:text withEncoding:NSASCIIStringEncoding toArray:list];
    [self addText:text withEncoding:NSUTF8StringEncoding toArray:list];
    
    return list;
}

@end
