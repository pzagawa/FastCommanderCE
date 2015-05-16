//
//  PanelListItem.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.03.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"

@class FMProviderFileItem;

@interface FMPanelListItem : NSObject <NSCopying>

@property (readonly) FMPanelListItemType itemType;
@property (readonly) NSURL *url;
@property (readonly) NSString *resourcePath;
@property (readonly) BOOL isSelected;

@property (readonly) NSString *fileName;
@property (readonly) NSString *fileExtension;
@property (readonly) NSNumber *fileSize;
@property (readonly) NSDate *modificationDate;

@property (readonly) id volumeId;

@property (readonly) BOOL isDirectory;
@property (readonly) BOOL isSymbolicLink;
@property (readonly) BOOL isReadable;
@property (readonly) BOOL isWritable;
@property (readonly) BOOL isExecutable;
@property (readonly) BOOL isHidden;
@property (readonly) BOOL isLooksBetterHidden;

@property (readonly) BOOL isArchive;
@property (readonly) BOOL isDirectorySize;

@property (readonly) NSString *unifiedFilePath;

@property (readonly) NSString *displayFileName;
@property (readonly) NSString *attributesText;
@property (readonly) NSString *fileSizeText;

@property (readonly) NSString *symbolicLinkPath;

- (id)initWithURL:(NSURL *)value itemType:(FMPanelListItemType)itemType;
- (id)initWithResource:(NSString *)value providerFileItem:(FMProviderFileItem *)providerFileItem itemType:(FMPanelListItemType)itemType;

- (id)copyWithZone:(NSZone *)zone;

- (NSString *)description;

- (BOOL)isItemsSelectionMatch:(NSString *)pattern;

- (void)setItemTypeDirUp;
- (void)setSelected:(BOOL)value;
- (void)setDirectorySize:(long long)value;

@end
