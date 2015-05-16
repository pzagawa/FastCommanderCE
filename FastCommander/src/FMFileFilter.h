//
//  FMFileFilter.h
//  FastCommander
//
//  Created by Piotr Zagawa on 12.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMFileFilter : NSObject

- (id)initWithDirectory:(NSString *)directoryPath;

- (BOOL)isFirstLevelFile:(NSString *)filePath;
- (BOOL)isInsideFile:(NSString *)filePath;

@end
