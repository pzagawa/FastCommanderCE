//
//  FMFileItem.h
//  FastCommander
//
//  Created by Piotr Zagawa on 03.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"
#import "FMOperationUserAction.h"

@class FMPanelListItem;
@class FMProviderFileItem;
@class FMPanelListProvider;

@interface FMFileItem : NSObject

typedef enum
{
    FMFileViewType_NONE = 0,
    FMFileViewType_TEXT = 1,
    FMFileViewType_IMAGE = 2,
    
} FMFileViewType;

@property (readonly) NSString *filePath;
@property (readonly) long long fileSize;
@property (readonly) NSString *fileSizeText;
@property (readonly) NSDate *modificationDate;

@property (readonly) NSString *fileName;

@property (readonly) BOOL isDirectory;
@property (readonly) BOOL isSymbolicLink;
@property (readonly) BOOL isHidden;

@property (readonly) id volumeId;

@property (readonly) FMFileItemStatus status;
@property (readonly) NSString *statusText;

@property FMOperationUserActionType userActionType;

@property (readonly) BOOL isError;
@property (readonly) BOOL isCanceled;
@property (readonly) BOOL isDone;
@property (readonly) BOOL isTargetExists;

@property (readonly) FMFileViewType fileViewType;

@property NSString *targetFilePath;

@property FMFileItem *referenceFileItem;

- (BOOL)isTheSameVolume:(FMFileItem *)fileItem;

+ (FMFileItem *)fromListItem:(FMPanelListItem *)listItem;
+ (FMFileItem *)fromUrl:(NSURL *)url;
+ (FMFileItem *)fromProviderFileItem:(FMProviderFileItem *)providerFileItem;
+ (FMFileItem *)fromFilePath:(NSString *)filePath;

- (void)updatePath:(NSString *)path;

- (void)setAsFinished;
- (void)setStatus:(FMFileItemStatus)status;
- (void)setStatus:(FMFileItemStatus)status withError:(NSError *)error;
- (void)setStatus:(FMFileItemStatus)status withException:(NSException *)exception;

@end
