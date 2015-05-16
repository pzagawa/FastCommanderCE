//
//  FMOperationImageViewWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 23.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationImageViewWindow : FMOperationWindow

@property (weak) IBOutlet NSTextField *textStatus;
@property (weak) IBOutlet NSImageView *imageMain;
@property (weak) IBOutlet NSTextField *textImageProperties;

@property (weak) NSData *fileData;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
