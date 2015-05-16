//
//  FMOperationCopyWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 02.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"
#import "FMOpCopyProgressViewController.h"
#import "FMOpFileExistsViewController.h"
#import "FMOpFileErrorViewController.h"

@interface FMOperationCopyWindow : FMOperationWindow

typedef enum
{
    FMOperationCopyViewNone = 0,
    FMOperationCopyViewProgress = 1,
    FMOperationCopyViewFileExists = 2,
    FMOperationCopyViewFileError = 3,
    FMOperationCopyViewSourceTargetEqual = 4,
    
} FMOperationCopyView;

@property (weak) IBOutlet NSImageView *iconTitle;

@property (weak) IBOutlet NSButton *btnSkip;
@property (weak) IBOutlet NSButton *btnOverwrite;
@property (weak) IBOutlet NSButton *btnRetry;

@property (weak) IBOutlet NSButton *checkApplyToAllFiles;
@property (weak) IBOutlet NSTextField *textStatusInfo;

@property (unsafe_unretained) IBOutlet FMOpCopyProgressViewController *viewProgressController;
@property (unsafe_unretained) IBOutlet FMOpFileExistsViewController *viewFileExistsController;
@property (unsafe_unretained) IBOutlet FMOpFileErrorViewController *viewFileErrorController;

@property (weak) IBOutlet NSScrollView *viewScrollContent;
@property (weak) IBOutlet NSView *viewContent;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;
- (IBAction)actionSkip:(id)sender;
- (IBAction)actionOverwrite:(id)sender;
- (IBAction)actionRetry:(id)sender;

- (IBAction)changeApplyToAllFiles:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
