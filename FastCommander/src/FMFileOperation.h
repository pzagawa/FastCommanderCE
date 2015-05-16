//
//  FMFileOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 31.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMFileOperationProgress.h"
#import "FMOperationUserAction.h"
#import "FMReloadData.h"
#import "FMCustomTypes.h"

@class FMFileItem;
@class FMDockInfoView;
@class FMPanelListProvider;
@class FMFileOperationUserData;

@interface FMFileOperation : NSObject

typedef void (^OnOperationFinish)(FMFileOperation *operation);

@property BOOL isDataChanged;

@property NSMutableArray *inputListItems;
@property NSMutableArray *fileItems;

@property (readonly) int inputDirectoryItemsCount;
@property (readonly) int inputFileItemsCount;
@property (readonly) NSString *inputListItemsSummaryText;

@property (readonly) NSNumber *filesTotalCount;
@property (readonly) NSNumber *filesTotalSize;
@property (readonly) NSString *filesTotalSizeText;

@property (readonly) BOOL filesTotalCountIsOne;

@property (readonly) NSNumber *directoriesTotalCount;

@property (weak) FMPanelListProvider *sourceProvider;
@property (weak) FMPanelListProvider *targetProvider;

@property (readonly) BOOL isCanceled;
@property (readonly) BOOL isInProgress;
@property (readonly) BOOL isPaused;

@property (readonly) BOOL isSkipRequest;
@property (readonly) BOOL isRetryRequest;
@property (readonly) BOOL isOverwriteRequest;

@property (readonly) FMOperationUserAction *userAction;
@property (readonly) FMFileOperationUserData *userData;

@property (weak) id <FMFileOperationProgress> progressDelegate;

@property (readonly) FMDockInfoView *dockInfoView;

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

- (void)run:(OnOperationFinish)onFinish;
- (void)runOnNewThread;

- (void)requestCancel;
- (void)requestPause;
- (void)requestResume;
- (void)waitOnResume;

- (void)requestSkip;
- (void)requestRetry;
- (void)requestOverwrite;

- (void)resetUserActionRequests;

- (long)secsFromKernelTime:(uint64_t)time;
- (long)milisFromKernelTime:(uint64_t)time;

- (void)reloadSourcePanel:(OnReloadBlock)onReloadFinish;
- (void)reloadTargetPanel:(OnReloadBlock)onReloadFinish;
- (void)reloadBothPanels;

@end
