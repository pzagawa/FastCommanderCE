//
//  FMPosixPermissions.h
//  FastCommander
//
//  Created by Piotr Zagawa on 22.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMPanelListProvider;

@interface FMPosixPermissions : NSObject

@property (readonly) NSUInteger bitsToSet;
@property (readonly) NSUInteger bitsToClear;

- (void)aggregateFileItemsPermissions:(NSMutableArray *)fileItems withProvider:(FMPanelListProvider *)provider;

+ (NSString *)octalTextFromBits:(NSUInteger)bitsToSet;
+ (NSUInteger)bitsFromOctalText:(NSString *)octalText;

+ (NSCellStateValue)state:(NSUInteger)mask withBitsToSet:(NSUInteger)bitsToSet andBitsToClear:(NSUInteger)bitsToClear;

@end
