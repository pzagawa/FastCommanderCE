//
//  FMPanelListProvider.h
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"

@class FMFileItem;
@class FMFileOperation;
@class FMPanelListItem;
@class FMOperationCommandSupport;

typedef enum
{
    FMProviderTypeUnknown = 0,
    FMProviderTypeLocal = 1,
    FMProviderTypeZip = 2,
    FMProviderTypeSearch = 3,
    
} FMProviderType;

typedef enum
{
    FMSortedListItemsBySelection = 0,
    FMSortedListItemsByName = 1,
    FMSortedListItemsBySize = 2,
    FMSortedListItemsByDate = 3,
    FMSortedListItemsByAttributes = 4,
    
} FMSortedListItemsBy;

typedef BOOL (^OnTestFileItem)(FMFileItem *fileItem);

@interface FMPanelListProvider : NSObject

@property NSMutableArray *sourceFileItems;

@property (copy) NSString *providerTitle;

@property (copy) NSString *providerName;

@property (copy) NSString *basePath;
@property (copy) NSString *previousPath;
@property (copy) NSString *currentPath;
@property (copy) NSString *nameToSelect;

@property (readonly) NSString *currentPathToResource;

@property (readonly) FMOperationCommandSupport *commandSupport;

@property NSNumber *maximumSupportedFileSize;

@property (readonly) BOOL currentPathContentChanged;

@property (readonly) BOOL isUseTrash;

- (id)init;

- (void)resetPathContentChanged;

- (void)reset;
- (void)initBasePath:(NSString *)path;

- (BOOL)isPathValid:(NSString *)path;
- (void)reload;
- (void)reload:(NSString *)path;
- (BOOL)isLoadingData;

- (NSMutableArray *)getListItems;
- (NSMutableArray *)getListItemsForOperation;

- (NSString *)getNameToSelect;
- (NSString *)getInitNameToSelect;
- (NSString *)getParentDirectory;

- (NSString *)getVolumeNameForPath:(NSString *)path;
- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)path;
- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)path;

- (NSString *)getPathToResource:(NSString *)path;
- (NSString *)getPathInResource:(NSString *)path;

- (BOOL)supportedOperationCommand:(FMCommandId)commandId withMode:(FMPanelMode)panelMode;

- (BOOL)isSelection;

- (void)addFileItemsTo:(NSMutableArray *)fileItems fromDirectoryItem:(FMPanelListItem *)listItem forOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem;
- (NSMutableArray *)createFileItemsForOperation:(FMFileOperation *)fileOperation withDeepIteration:(BOOL)isDeepIteration;
- (NSMutableArray *)createFileItemsForOperation:(FMFileOperation *)fileOperation withDeepIteration:(BOOL)isDeepIteration andTestBlock:(OnTestFileItem)onTestFileItem;
- (NSMutableArray *)createFileItemsForPanelListItem:(FMPanelListItem *)listItem withOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem;
- (void)validateFileItems:(NSMutableArray *)fileItems forOperation:(FMFileOperation *)fileOperation;
- (int)filesCountForPath:(NSString *)directoryPath;

- (void)sortedPanelListFromUrlItems:(NSArray *)urltems parentDirectory:(NSString *)parentDirectory;
- (void)sortedPanelListFromPanelListItems:(NSMutableArray *)listItems parentDirectory:(FMPanelListItem *)parentDirectory;

- (NSInputStream *)getInputStream:(NSString *)filePath;
- (NSOutputStream *)getOutputStream:(NSString *)filePath;

- (NSString *)getTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath;
- (NSString *)getRelativeTargetFileName:(FMFileItem *)fileItem withTargetPath:(NSString *)targetPath;

- (FMFileItem *)fileNameToFileItem:(NSString *)filePath;

- (BOOL)removeFile:(NSString *)filePath;
- (BOOL)fileExists:(NSString *)filePath;
- (BOOL)directoryExists:(NSString *)directoryPath;
- (BOOL)removeDirectory:(NSString *)filePath;
- (BOOL)createDirectory:(NSString *)filePath;
- (BOOL)renameFile:(NSString *)oldFilePath to:(NSString *)newFilePath;
- (BOOL)moveFile:(NSString *)oldFilePath to:(NSString *)newFilePath error:(NSError **)error;

- (NSUInteger)posixPermissionsForPath:(NSString *)filePath;
- (BOOL)setPosixPermissions:(NSUInteger)permissions forPath:(NSString *)filePath;

- (BOOL)supportsContextMenu:(FMPanelListItem *)item;

@end
