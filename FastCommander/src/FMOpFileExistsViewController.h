//
//  FMOpFileExistsViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 05.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FMFileItem;
@class FMFileCopyOperation;

@interface FMOpFileExistsViewController : NSViewController

@property (weak) IBOutlet NSTextField *textFileLabel;
@property (weak) IBOutlet NSTextField *textFileName;

@property (weak) IBOutlet NSTextField *textMessage;
@property (weak) IBOutlet NSTextField *textMessageDetails;

@property (weak) IBOutlet NSTextField *textNewSize;
@property (weak) IBOutlet NSTextField *textNewDate;

@property (weak) IBOutlet NSTextField *textExistingSize;
@property (weak) IBOutlet NSTextField *textExistingDate;

- (void)beforeStart;
- (void)itemError:(FMFileItem *)fileItem;

@end
