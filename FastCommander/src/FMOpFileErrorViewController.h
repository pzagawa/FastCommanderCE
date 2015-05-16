//
//  FMOpFileErrorViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 06.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FMFileItem;
@class FMFileCopyOperation;

@interface FMOpFileErrorViewController : NSViewController

@property (weak) IBOutlet NSTextField *textFileLabel;
@property (weak) IBOutlet NSTextField *textFileName;

@property (weak) IBOutlet NSTextField *textMessage;
@property (weak) IBOutlet NSTextField *textMessageDetails;

- (void)beforeStart;
- (void)itemError:(FMFileItem *)fileItem;

@end
