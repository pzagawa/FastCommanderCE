//
//  FMDirectoryWatcher.h
//  FastCommander
//
//  Created by Piotr Zagawa on 04.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDirectoryWatcher : NSObject

@property BOOL directoryContentChanged;

- (id)initWithPath:(NSString *)path;

@end
