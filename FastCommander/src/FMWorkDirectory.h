//
//  WorkDirectory.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.03.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPanelListItem.h"

@interface FMWorkDirectory : NSObject

@property NSURL *directory;
@property NSError *error;

- (NSDirectoryEnumerationOptions)getOptions;

- (id)initWithDirectory:(NSString *)value;
- (void)setWorkDirectory:(NSString *)value;
- (NSArray *)loadUrlItems;

- (NSString *)getUpDirectoryName;
- (NSURL *)getUpDirectory;
- (NSURL *)getDownDirectory:(NSString *)value;

+ (BOOL)isRootDirectory:(NSString *)path;
+ (BOOL)isLocalDirectory:(NSString *)path;
+ (BOOL)isPathAccessible:(NSString *)path;
+ (NSString *)getPreviousName:(NSString *)previousPath currPath:(NSString *)currentPath;

+ (NSArray *)getMountedVolumes;

+ (NSURL *)getUserDirectory;
+ (NSURL *)getUsersDirectory;
+ (NSURL *)getDocumentsDirectory;
+ (NSURL *)getDownloadsDirectory;
+ (NSURL *)getPublicDirectory;
+ (NSURL *)getDesktopDirectory;
+ (NSURL *)getMoviesDirectory;
+ (NSURL *)getMusicDirectory;
+ (NSURL *)getPicturesDirectory;

@end
