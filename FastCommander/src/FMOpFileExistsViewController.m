//
//  FMOpFileExistsViewController.m
//  FastCommander
//
//  Created by Piotr Zagawa on 05.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOpFileExistsViewController.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"

@implementation FMOpFileExistsViewController
{
    NSDateFormatter *_dateFormatter;
}

- (void)beforeStart
{
}

- (void)textSizeFieldsDefaultColor
{
    NSColor *color = [NSColor colorWithCalibratedRed:0.0 green:0.2 blue:0.4 alpha:1.0];
    
    self.textNewSize.textColor = color;
    self.textExistingSize.textColor = color;

    self.textNewDate.textColor = color;
    self.textExistingDate.textColor = color;
}

- (void)textSizeFieldsWarningColor
{
    NSColor *color = [NSColor colorWithCalibratedRed:0.8 green:0 blue:0 alpha:1.0];

    self.textNewSize.textColor = color;
    self.textExistingSize.textColor = color;
}

- (void)textDateFieldsWarningColor
{
    NSColor *color = [NSColor colorWithCalibratedRed:0.8 green:0 blue:0 alpha:1.0];
    
    self.textNewDate.textColor = color;
    self.textExistingDate.textColor = color;
}

- (void)itemError:(FMFileItem *)fileItem
{
    [self textSizeFieldsDefaultColor];
    
    if (_dateFormatter == nil)
    {
        self->_dateFormatter = [[NSDateFormatter alloc] init];
        self->_dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    }
    
    self.textFileName.stringValue = fileItem.filePath;
    
    self.textMessage.stringValue = @"FILE COLLISION";
    
    self.textMessageDetails.stringValue = fileItem.statusText;
    
    FMFileItem *existingFileItem = fileItem.referenceFileItem;
    
    if (existingFileItem != nil)
    {
        //show files size
        self.textNewSize.stringValue = fileItem.fileSizeText;
        self.textExistingSize.stringValue = existingFileItem.fileSizeText;

        //show files dates
        NSString *newDateText = [self->_dateFormatter stringFromDate: fileItem.modificationDate];
        NSString *existingDateText = [self->_dateFormatter stringFromDate: existingFileItem.modificationDate];

        self.textNewDate.stringValue = newDateText;
        self.textExistingDate.stringValue = existingDateText;
    
        //highlight file size differences
        if (fileItem.fileSize != existingFileItem.fileSize)
        {
            [self textSizeFieldsWarningColor];
        }

        //highlight file date differences
        if ([newDateText isEqualToString:existingDateText] == NO)
        {
            [self textDateFieldsWarningColor];
        }
    }
}

@end
