//
//  FMOpCopyProgressViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 05.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FMFileItem;
@class FMFileCopyOperation;

@interface FMOpCopyProgressViewController : NSViewController

@property (weak) FMFileCopyOperation *fileOperation;

@property (weak) IBOutlet NSTextField *textSourceFile;
@property (weak) IBOutlet NSTextField *textSourceFileName;
@property (weak) IBOutlet NSTextField *textTargetPath;
@property (weak) IBOutlet NSProgressIndicator *progressSourceFile;
@property (weak) IBOutlet NSTextField *textSourceFileStatus;
@property (weak) IBOutlet NSTextField *editTargetPath;
@property (weak) IBOutlet NSTextField *textTargetLabel;

@property (weak) IBOutlet NSTextField *textTotalFiles;
@property (weak) IBOutlet NSProgressIndicator *progressTotalFiles;
@property (weak) IBOutlet NSTextField *textTotalFilesStatus;

@property (readonly) NSString *targetPath;

- (void)reset;
- (void)beforeStart;
- (void)itemStart:(FMFileItem *)fileItem;
- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem;
- (void)itemProgress:(FMFileItem *)fileItem;
- (void)itemFinish:(FMFileItem *)fileItem;

@end
