//
//  FMProviderFileItem.h
//  FastCommander
//
//  Created by Piotr Zagawa on 10.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//
//  Proxy item for preparing list items collecion for virtual providers, like zip
//

#import <Foundation/Foundation.h>

@class ZZArchiveEntry;

@interface FMProviderFileItem : NSObject

@property (readonly, weak) ZZArchiveEntry *archiveEntry;

@property (readonly) NSString *filePath;
@property (readonly) long long fileSize;
@property (readonly) long long fileSizeCompressed;
@property (readonly) NSDate *modificationDate;
@property (readonly) BOOL isDirectory;
@property (readonly) BOOL isSymbolicLink;
@property (readonly) BOOL isHidden;

@property id volumeId;

- (id)initWithArchiveEntry:(ZZArchiveEntry *)entry;
- (id)initWithFileItem:(FMProviderFileItem *)item;
- (id)initDirectoryItem:(FMProviderFileItem *)item withPath:(NSString *)path;

@end
