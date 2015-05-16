//
//  FMLocalPanelListProvider.h
//  FastCommander
//
//  Created by Piotr Zagawa on 26.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMPanelListProvider.h"

@interface FMLocalPanelListProvider : FMPanelListProvider

- (id)init;

- (void)reset;

- (BOOL)isPathValid:(NSString *)path;
- (void)reload;
- (void)reload:(NSString *)path;
- (BOOL)isLoadingData;

- (NSString *)getNameToSelect;
- (NSString *)getInitNameToSelect;
- (NSString *)getParentDirectory;

- (NSString *)getVolumeNameForPath:(NSString *)path;
- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)path;
- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)path;

- (void)addFileItemsTo:(NSMutableArray *)fileItems fromDirectoryItem:(FMPanelListItem *)listItem forOperation:(FMFileOperation *)fileOperation andTestBlock:(OnTestFileItem)onTestFileItem;
- (void)validateFileItems:(NSMutableArray *)fileItems forOperation:(FMFileOperation *)fileOperation;
- (int)filesCountForPath:(NSString *)directoryPath;

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

@end
