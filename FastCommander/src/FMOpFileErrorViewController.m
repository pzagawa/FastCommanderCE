//
//  FMOpFileErrorViewController.m
//  FastCommander
//
//  Created by Piotr Zagawa on 06.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOpFileErrorViewController.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"

@implementation FMOpFileErrorViewController

- (void)beforeStart
{
}

- (void)itemError:(FMFileItem *)fileItem
{
    self.textFileName.stringValue = fileItem.filePath;

    self.textMessage.stringValue = @"FILE ERROR";

    self.textMessageDetails.stringValue = fileItem.statusText;
}

@end
