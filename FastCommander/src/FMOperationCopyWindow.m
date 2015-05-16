//
//  FMOperationCopyWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 02.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationCopyWindow.h"
#import "AppDelegate.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMFileItem.h"
#import "FMDockInfoView.h"
#import "FMResources.h"
#import "FMScrollAnimation.h"
#import "FMOperationStats.h"

@implementation FMOperationCopyWindow
{
    FMOperationCopyView _currentView;
    FMFileItemStatus _currentFileItemStatus;
    
    FMOperationStats *_operationStats;
}

- (void)actionCancel:(id)sender
{
    if (self.fileOperation.isInProgress)
    {
        [super actionCancel:sender];
    }
    else
    {
        [self closeSheet];
    }
}

- (void)actionAccept:(id)sender
{
    [super actionAccept:sender];
}

- (IBAction)actionSkip:(id)sender
{
    [self showSubView:FMOperationCopyViewProgress withBlockOnFinish:^()
    {
        [self setUserAction:FMOperationUserActionType_SKIP];
        
        [self.fileOperation requestSkip];
    }];
}

- (IBAction)actionOverwrite:(id)sender
{
    [self showSubView:FMOperationCopyViewProgress withBlockOnFinish:^()
    {
        [self setUserAction:FMOperationUserActionType_OVERWRITE];

        [self.fileOperation requestOverwrite];
    }];
}

- (IBAction)actionRetry:(id)sender
{
    [self showSubView:FMOperationCopyViewProgress withBlockOnFinish:^()
    {
        [self setUserAction:FMOperationUserActionType_RETRY];

        [self.fileOperation requestRetry];
    }];
}

- (IBAction)changeApplyToAllFiles:(id)sender
{
}

- (void)setUserAction:(FMOperationUserActionType)action
{
    BOOL isChecked = (self.checkApplyToAllFiles.state == NSOnState);
    
    [self.fileOperation.userAction setAction:action forStatus:_currentFileItemStatus];
    [self.fileOperation.userAction setApplyToAll:isChecked forStatus:_currentFileItemStatus];
}

//FMFileOperationProgress protocol
- (void)reset
{
    [super reset];

    [self resetView];

    self->_operationStats = [[FMOperationStats alloc] init];

    [self updateTitleWithInfo:@""];
    
    self.textStatusInfo.stringValue = @"";

    self.viewProgressController.fileOperation = (FMFileCopyOperation *)self.fileOperation;

    [self.viewProgressController reset];
    
    [self showSubView:FMOperationCopyViewProgress withBlockOnFinish:^()
    {
    }];
}

- (NSString *)titleWithInfo:(NSString *)info
{
    FMFileCopyOperation *fileCopyOperation = (FMFileCopyOperation *)self.fileOperation;
    
    NSString *text = @"FILES";
    
    if (fileCopyOperation.mode == FMFileCopyOperationMode_COPY)
    {
        if (info.length == 0)
        {
            text = @"COPYING FILES";
        }
        else
        {
            text = [NSString stringWithFormat:@"COPYING FILES: %@", info];
        }
    }
    
    if (fileCopyOperation.mode == FMFileCopyOperationMode_MOVE)
    {
        if (info.length == 0)
        {
            text = @"MOVING FILES";
        }
        else
        {
            text = [NSString stringWithFormat:@"MOVING FILES: %@", info];
        }
    }
    
    return text;
}

- (void)updateTitleWithInfo:(NSString *)info
{
    //title label
    self.textTitle.stringValue = [self titleWithInfo:@""];

    FMFileCopyOperation *fileCopyOperation = (FMFileCopyOperation *)self.fileOperation;

    //title icon
    if (fileCopyOperation.mode == FMFileCopyOperationMode_COPY)
    {
        self.iconTitle.image = [[FMResources instance] imageOperationCopy];
    }

    if (fileCopyOperation.mode == FMFileCopyOperationMode_MOVE)
    {
        self.iconTitle.image = [[FMResources instance] imageOperationMove];
    }
}

- (NSString *)acceptTitle
{
    FMFileCopyOperation *fileCopyOperation = (FMFileCopyOperation *)self.fileOperation;

    if (fileCopyOperation.mode == FMFileCopyOperationMode_COPY)
    {
        return @"Copy";
    }
    
    if (fileCopyOperation.mode == FMFileCopyOperationMode_MOVE)
    {
        return @"Move";
    }
    
    return @"Close";
}

- (void)beforeStart
{
    [super beforeStart];

    [self updateTitleWithInfo:@""];
    
    self.textStatusInfo.stringValue = @"";

    [_operationStats reset];

    [self.fileOperation.dockInfoView showDefault];
    
    [self.checkApplyToAllFiles setState:NSOffState];
    
    [self.viewProgressController beforeStart];
    [self.viewFileErrorController beforeStart];
    [self.viewFileExistsController beforeStart];

    if (self.fileOperation.filesTotalCountIsOne)
    {
        [self makeFirstResponder:self.viewProgressController.editTargetPath];
    }
}

- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem
{
    if (self.fileOperation.filesTotalCountIsOne)
    {
        fileItem.targetFilePath = self.viewProgressController.targetPath;
    }

    [self.viewProgressController updateFileItemBeforeStart:fileItem];
}

- (void)itemStart:(FMFileItem *)fileItem
{
    self.fileOperation.dockInfoView.isErrorColor = NO;
    
    @try
    {
        [self.viewProgressController itemStart:fileItem];
    }
    @catch (NSException *exception)
    {
    }
    @finally
    {
    }
    
    //update stats
    [_operationStats updateOnItemStart:(FMFileCopyOperation *)self.fileOperation];
}

- (void)itemProgress:(FMFileItem *)fileItem
{
    [self.viewProgressController itemProgress:fileItem];
    
    //when processing bigger files, update totals progress
    const int FILE_SIZE_1MB = 1024 * 1024;
    
    if (fileItem.fileSize > FILE_SIZE_1MB)
    {
        [self itemFinish:fileItem];
    }
    
    //update stats
    [_operationStats updateOnItemProgress:(FMFileCopyOperation *)self.fileOperation];

    //update speed info
    NSString *statsInfo = _operationStats.info;
    
    if ([self.textStatusInfo.stringValue isEqualToString:statsInfo] == NO)
    {
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            self.textStatusInfo.stringValue = statsInfo;
        });
    }
}

- (void)itemFinish:(FMFileItem *)fileItem
{
    self.fileOperation.dockInfoView.isErrorColor = NO;

    [self.viewProgressController itemFinish:fileItem];

    if (fileItem.isDirectory == NO)
    {
        FMFileCopyOperation *fileCopyOperation = (FMFileCopyOperation *)self.fileOperation;
        
        self.fileOperation.dockInfoView.progressValue = fileCopyOperation.totalProgressPercentBySize;
    }
    
    //update stats
    [_operationStats updateOnItemFinish:(FMFileCopyOperation *)self.fileOperation];
}

- (void)itemError:(FMFileItem *)fileItem
{
    [super itemError:fileItem];
    
    self->_currentFileItemStatus = fileItem.status;

    FMOperationCopyView operationView = [self parseStatusToView:fileItem];
    
    if (operationView != FMOperationCopyViewNone)
    {
        if (operationView == FMOperationCopyViewFileError)
        {
            [self.viewFileErrorController itemError:fileItem];

            self.fileOperation.dockInfoView.isErrorColor = YES;
        }
        
        if (operationView == FMOperationCopyViewSourceTargetEqual)
        {
            [self.viewFileErrorController itemError:fileItem];

            self.fileOperation.dockInfoView.isErrorColor = YES;
        }

        if (operationView == FMOperationCopyViewFileExists)
        {
            [self.viewFileExistsController itemError:fileItem];
            
            self.fileOperation.dockInfoView.isErrorColor = YES;
        }
        
        [self showSubView:operationView withBlockOnFinish:^()
        {
            //none action
        }];        
    }
}

- (FMOperationCopyView)parseStatusToView:(FMFileItem *)fileItem
{
    if (fileItem.isError)
    {
        if (fileItem.status == FMFileItemStatus_TARGET_EXISTS_ERROR)
        {
            return FMOperationCopyViewFileExists;
        }
        
        if (fileItem.status == FMFileItemStatus_SOURCE_TARGET_EQUAL_ERROR)
        {
            return FMOperationCopyViewSourceTargetEqual;
        }

        return FMOperationCopyViewFileError;
    }

    return FMOperationCopyViewNone;
}

- (void)showSubView:(FMOperationCopyView)mode withBlockOnFinish:(OnScrollAnimFinishBlock)onFinish
{
    if (mode == self->_currentView)
    {
        onFinish();
        return;
    }

    self->_currentView = mode;

    [self updateControlButtons:mode];

    if (mode == FMOperationCopyViewProgress)
    {
        [self showMainSubViewWithBlockOnFinish:onFinish];
        return;
    }
    
    if (mode == FMOperationCopyViewFileExists)
    {
        [self updateApplyToAllFilesCheckbox];
        
        [self showSecondarySubView:self.viewFileExistsController.view withBlockOnFinish:onFinish];
        return;
    }
    
    if (mode == FMOperationCopyViewFileError)
    {
        [self updateApplyToAllFilesCheckbox];
        
        [self showSecondarySubView:self.viewFileErrorController.view withBlockOnFinish:onFinish];
        return;
    }

    if (mode == FMOperationCopyViewSourceTargetEqual)
    {
        [self updateApplyToAllFilesCheckbox];
        
        [self showSecondarySubView:self.viewFileErrorController.view withBlockOnFinish:onFinish];
        return;
    }

    onFinish();
    return;
}

- (void)showMainSubViewWithBlockOnFinish:(OnScrollAnimFinishBlock)onFinish
{
    NSView *mainView = self.viewProgressController.view;

    float initHeight = mainView.frame.size.height * 2;
    
    [self updateContentSizeHeight:initHeight];
    
    [self setContentScrollPos:mainView.frame.size.height];
    
    [self setView:mainView positionInContainer:0];
    
    [mainView setHidden:NO];

    //scroll into view with animation
    NSPoint point = NSMakePoint(0,0);

    [FMScrollAnimation scroll:self.viewScrollContent toPoint:point withBlockOnFinish:^
    {
        [self hideSecondarySubviews];

        [self updateContentSizeHeight:mainView.frame.size.height];

        [self setView:mainView positionInContainer:0];
                
        onFinish();
    }];
}

- (void)updateApplyToAllFilesCheckbox
{
    BOOL isCheckedApplyToAllFiles = [self.fileOperation.userAction applyToAllValueForStatus:_currentFileItemStatus];

    if (isCheckedApplyToAllFiles == YES)
    {
        [self.checkApplyToAllFiles setState:NSOnState];
    }
    else
    {
        [self.checkApplyToAllFiles setState:NSOffState];
    }
}

- (void)showSecondarySubView:(NSView *)view withBlockOnFinish:(OnScrollAnimFinishBlock)onFinish
{
    float initHeight = self.viewProgressController.view.frame.size.height + view.frame.size.height;
    
    [self updateContentSizeHeight:initHeight];

    [self setContentScrollPos:0];

    [self setView:view positionInContainer:view.frame.size.height];

    [view setHidden:NO];
    
    //scroll into view with animation
    NSPoint point = NSMakePoint(0,view.frame.size.height);

    [FMScrollAnimation scroll:self.viewScrollContent toPoint:point withBlockOnFinish:^
    {
        [self hideMainSubview];

        [self updateContentSizeHeight:view.frame.size.height];

        [self setView:view positionInContainer:0];

        onFinish();
    }];
}

- (void)hideMainSubview
{
    NSView *view = self.viewProgressController.view;
    
    [view setHidden:YES];
}

- (void)hideSecondarySubviews
{
    [self.viewFileExistsController.view setHidden:YES];
    [self.viewFileErrorController.view setHidden:YES];
}

- (void)updateControlButtons:(FMOperationCopyView)mode
{
    [self.checkApplyToAllFiles setHidden:YES];
    
    [self.textStatusInfo setHidden:YES];
    
    [self.btnCancel setHidden:YES];
    [self.btnAccept setHidden:YES];
    [self.btnSkip setHidden:YES];
    [self.btnOverwrite setHidden:YES];
    [self.btnRetry setHidden:YES];
     
    if (mode == FMOperationCopyViewProgress)
    {
        [self showButtons:[NSArray arrayWithObjects:self.btnAccept, self.btnCancel, nil]];
        [self.textStatusInfo setHidden:NO];
        return;
    }
    
    if (mode == FMOperationCopyViewFileExists)
    {
        [self showButtons:[NSArray arrayWithObjects:self.btnOverwrite, self.btnSkip, self.btnCancel, nil]];
        [self showApplyToAllFilesCheckbox];
        [self.textStatusInfo setHidden:YES];
        return;
    }
    
    if (mode == FMOperationCopyViewFileError)
    {
        [self showButtons:[NSArray arrayWithObjects:self.btnRetry, self.btnSkip, self.btnCancel, nil]];
        [self showApplyToAllFilesCheckbox];
        [self.textStatusInfo setHidden:YES];
        return;
    }
    
    if (mode == FMOperationCopyViewSourceTargetEqual)
    {
        [self showButtons:[NSArray arrayWithObjects:self.btnSkip, self.btnCancel, nil]];
        [self showApplyToAllFilesCheckbox];
        [self.textStatusInfo setHidden:YES];
        return;
    }
}

- (void)showButtons:(NSArray *)buttons
{
    NSPoint btnOrigin = self.buttonOrigin;

    for (NSButton *button in buttons)
    {
        [button setFrameOrigin:btnOrigin];

        btnOrigin.x -= self.buttonSpacing;

        [button setHidden:NO];
    }
}

- (void)showApplyToAllFilesCheckbox
{
    if (self.fileOperation.filesTotalCountIsOne == NO)
    {
        [self.checkApplyToAllFiles setHidden:NO];
    }
}

- (void)resetView
{
    self->_currentView = FMOperationCopyViewNone;

    float initHeight = self.viewProgressController.view.frame.size.height;
    
    [self setContentScrollPos:0];
    
    [self updateContentSizeHeight:initHeight];

    [self addSubView:self.viewProgressController.view];
    [self addSubView:self.viewFileExistsController.view];
    [self addSubView:self.viewFileErrorController.view];

    [self.viewContent setNeedsDisplay:YES];
    [self.viewContent setNeedsDisplay:YES];
}

- (void)addSubView:(NSView *)view
{
    [view setHidden:YES];
    [view removeFromSuperview];
    [self.viewContent addSubview:view];
    [self setView:view positionInContainer:-1000];
}

- (void)setContentScrollPos:(float)y
{
    NSPoint point = NSMakePoint(0,y);
    [self.viewScrollContent.documentView scrollPoint:point];
    
    [self.viewContent setNeedsDisplay:YES];
}

- (void)setView:(NSView *)view positionInContainer:(float)y
{
    NSPoint point = NSMakePoint(0,y);
    [view setFrameOrigin:point];

    [self.viewContent setNeedsDisplay:YES];
}

- (void)updateContentSizeHeight:(float)height
{
    NSView *mainView = self.viewProgressController.view;
    
    NSSize sizeContent = NSMakeSize(mainView.frame.size.width, height);
        
    [self.viewContent setFrameSize:sizeContent];
    
    [self.viewContent setNeedsLayout:YES];
}

- (void)afterFinish
{
}

- (void)onOperationPause:(BOOL)pauseState
{
}

- (void)closeSheet
{
    @try
    {
        [self resetView];
    }
    @finally
    {
        [super closeSheet];
    }

    [self.fileOperation.dockInfoView hide];
}

+ (void)showSheet:(FMFileOperation *)fileOperation
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationCopy;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationCopy;
    
    [window closeSheet];
}

@end
