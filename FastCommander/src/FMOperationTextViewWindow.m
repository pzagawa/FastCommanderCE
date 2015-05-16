//
//  FMOperationTextViewWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 20.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationTextViewWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMFileItem.h"
#import "FMTheme.h"
#import "FMThemeManager.h"
#import "NSString+Utils.h"

@implementation FMOperationTextViewWindow
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

- (void)actionEncodingChanged:(id)sender
{
    NSString *encodingName = [self.popupEncoding titleOfSelectedItem];
 
    NSStringEncoding encoding = [NSString encodingFromName:encodingName];
    
    if (encoding != 0)
    {        
        [self setTextViewWithEncoding:encoding];
    }
    
    return;
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
    
    self.currentEncoding = 0;
    
    self.textTitle.stringValue = @"VIEWING FILE";
    
    //setup controls
    [self initializeEncodingPopup];
    
    //set view theme
    self->_theme = FMThemeManager.instance.theme;

    self.textView.backgroundColor = _theme.listBackground;
    self.textView.textColor = _theme.rowDirectoryText;
    
    //reset view
    self.textStatus.stringValue = @"";
    self.textView.string = @"";
}

- (void)initializeEncodingPopup
{
    NSArray *encodingNames = [NSString getStringEncodingNamesArray];
    
    [self.popupEncoding removeAllItems];

    [self.popupEncoding addItemWithTitle:@""];

    for (NSString *encodingName in encodingNames)
    {
        [self.popupEncoding addItemWithTitle:[encodingName copy]];
    }

    [self.popupEncoding selectItem:nil];
    [self.popupEncoding setTitle:@""];
    [self.popupEncoding synchronizeTitleAndSelectedItem];

    [self.popupEncoding setEnabled:NO];
}

- (NSString *)acceptTitle
{
    return @"Close";
}

- (void)beforeStart
{
    [super beforeStart];
    
    [self makeFirstResponder:self.textView];
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
            [self.scrollTextView setHidden:NO];
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
            [self.scrollTextView setHidden:YES];
        }
    }
}

- (NSString *)parseFromFileData:(NSData *)fileData
{
    NSArray *encodingItems = [NSString getStringEncodingArray];
    
    int index = 0;
    
    while (index < encodingItems.count)
    {
        NSStringEncoding encoding = [encodingItems[index] integerValue];

        NSString *text = [self stringFromFileData:fileData withEncoding:encoding];

        if (text != nil)
        {
            return text;
        }
        
        index++;
    }
    
    return nil;
}

- (NSString *)stringFromFileData:(NSData *)fileData withEncoding:(NSStringEncoding)encoding
{
    NSString *text = nil;

    @try
    {
        text = [[NSString alloc] initWithData:self.fileData encoding:encoding];
        
        if (text != nil)
        {
            self.currentEncoding = encoding;

            return text;
        }
    }
    @catch (NSException *exception)
    {
    }
    @finally
    {
    }
    
    return text;
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

    //enable encoding selector
    [self.popupEncoding setEnabled:YES];
    
    //show data, try detect encoding
    [self setTextViewWithEncoding:0];
}

- (void)setTextViewWithEncoding:(NSStringEncoding)encoding
{
    NSString *text = nil;

    //get text
    if (encoding == 0)
    {
        text = [self parseFromFileData:self.fileData];
    }
    else
    {
        text = [self stringFromFileData:self.fileData withEncoding:encoding];
    }

    //set text view
    if (text == nil)
    {
        NSString *encodingName = [NSString nameFromEncoding:encoding];
        
        NSString *statusMessage = [NSString stringWithFormat:@"Error decoding file with encoding: %@.", encodingName];
        
        [self setStatusText:statusMessage];
    }
    else
    {
        //show string in view
        [self setStatusText:nil];

        //set view font
        NSFont *font = [NSFont fontWithName: @"Menlo" size:12];
        
        if (font == nil)
        {
            font = [NSFont systemFontOfSize:12];
        }
        
        self.textView.font = font;
        self.textView.textContainerInset = NSMakeSize(0, 2);
        
        //show text
        self.textView.string = text;

        //update popup
        NSString *encodingName = [NSString nameFromEncoding:self.currentEncoding];

        [self.popupEncoding selectItemWithTitle:encodingName];
        [self.popupEncoding setTitle:encodingName];
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
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationTextView;
    
    [window initKeyEventsMonitor];
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationTextView;
    
    [window closeKeyEventsMonitor];
    
    [window closeSheet];
}

@end
