//
//  FMBufferFinderText.h
//  FastCommander
//
//  Created by Piotr Zagawa on 22.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMBufferFinderText : NSObject

@property (readonly) BOOL isPatternMatch;
@property (readonly) long long matchPosition;

+ (NSMutableArray *)encodedTextList:(NSString *)text;

- (void)reset;
- (void)testPatternMatch:(uint8_t *)buffer withSize:(NSInteger)size;

@end
