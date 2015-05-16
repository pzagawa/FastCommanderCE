//
//  FMBufferFinder.h
//  FastCommander
//
//  Created by Piotr Zagawa on 22.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMBufferFinder : NSObject

@property (readonly) NSString *text;
@property (readonly) BOOL isPatternMatch;
@property (readonly) long long matchPosition;

- (id)initWithText:(NSString *)text;

- (void)reset;
- (BOOL)process:(uint8_t *)buffer withSize:(NSInteger)size;

@end
