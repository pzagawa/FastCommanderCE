//
//  FMOperationTextViewWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 20.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMOperationWindow.h"

@interface FMOperationTextViewWindow : FMOperationWindow

@property (weak) IBOutlet NSTextField *textStatus;

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSScrollView *scrollTextView;

@property (weak) IBOutlet NSPopUpButton *popupEncoding;

@property (weak) NSData *fileData;
@property NSStringEncoding currentEncoding;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionAccept:(id)sender;
- (IBAction)actionEncodingChanged:(id)sender;

+ (void)showSheet:(FMFileOperation *)fileOperation;
+ (void)close;

@end
