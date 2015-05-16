//
//  FMOperationImageViewWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 23.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationImageViewWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMFileItem.h"
#import "FMTheme.h"
#import "FMThemeManager.h"
#import "NSString+Utils.h"

@implementation FMOperationImageViewWindow
{
    FMTheme *_theme;
}

- (void)actionCancel:(id)sender
{
    [super actionCancel:sender];
}

- (void)actionAccept:(id)sender
{
    [super actionCancel:sender];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if (theEvent.keyCode == FMKeyCode_ESCAPE)
    {
        [super actionCancel:self];
        
        return;
    }

    [super keyDown:theEvent];
}

- (void)reset
{
    [super reset];
    
    [self setStatusText:nil];
    
    self.textTitle.stringValue = @"VIEWING FILE";
    
    //set view theme
    self->_theme = FMThemeManager.instance.theme;
    
    //reset view
    self.textStatus.stringValue = @"";
    self.imageMain.image = nil;
    self.textImageProperties.stringValue = @"";
}

- (NSString *)acceptTitle
{
    return @"Close";
}

- (void)beforeStart
{
    [super beforeStart];
    
    [self makeFirstResponder:self.imageMain];
}

- (void)itemStart:(FMFileItem *)fileItem
{
}

- (void)setStatusText:(NSString *)status
{
    if (status == nil)
    {
        self.textStatus.stringValue = @"";
        
        if (self.textStatus.isHidden == NO)
        {
            [self.textStatus setHidden:YES];
        }
        
        if (self.textStatus.isHidden == YES)
        {
            [self.imageMain setHidden:NO];
        }        
    }
    else
    {
        self.textStatus.stringValue = status;

        if (self.textStatus.isHidden == YES)
        {
            [self.textStatus setHidden:NO];
        }
        
        if (self.textStatus.isHidden == NO)
        {
            [self.imageMain setHidden:YES];
        }
    }
    
    self.textImageProperties.stringValue = @"";
}

- (void)itemStart:(FMFileItem *)fileItem withData:(NSData *)fileData
{
    self.fileData = fileData;

    //validate input data
    if (fileData == nil || (fileItem.isDone == NO))
    {
        NSMutableString *statusMessage = [[NSMutableString alloc] init];

        [statusMessage appendString:@"Error opening file."];
        [statusMessage appendString:@" "];
        [statusMessage appendString:fileItem.statusText];
        
        [self setStatusText:statusMessage];

        return;
    }

    //show data
    [self setImageView:fileItem];
}

- (void)setImageView:(FMFileItem *)fileItem
{
    NSImage *image = [[NSImage alloc] initWithData:self.fileData];
   
    if (image == nil)
    {
        [self setStatusText:@"Error decoding image."];        
        return;
    }
    else
    {
        [self setStatusText:nil];
    
        NSString *fileName = [fileItem.filePath lastPathComponent];
        
        NSString *imageInfo = [NSString stringWithFormat:@"%d x %d, %@, %@", (int)image.size.width, (int)image.size.height, fileItem.fileSizeText, fileName];
        
        self.textImageProperties.stringValue = imageInfo;

        self.imageMain.image = image;
    }
}

- (void)afterFinish
{
}

- (void)onOperationPause:(BOOL)pauseState
{
    
}

- (void)closeSheet
{
    [super closeSheet];
}

+ (void)showSheet:(FMFileOperation *)fileOperation
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationImageView;
    
    [window initKeyEventsMonitor];

    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationImageView;

    [window closeKeyEventsMonitor];

    [window closeSheet];
}

@end
