//
//  FMOpCopyProgressViewController.m
//  FastCommander
//
//  Created by Piotr Zagawa on 05.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOpCopyProgressViewController.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"

@implementation FMOpCopyProgressViewController
{
    int _prevItemProgressPercent;
    int _prevTotalProgressPercent;
}

- (void)reset
{
    _prevItemProgressPercent = 0;
    _prevTotalProgressPercent = 0;
    
    self.textSourceFile.stringValue = @"FILE";
    self.textSourceFileName.stringValue = @"";
    self.textTargetLabel.stringValue = @"TO";
    self.textTargetPath.stringValue = @"";
    self.editTargetPath.stringValue = @"";
    self.textSourceFileStatus.stringValue = @"";
    
    self.textTotalFiles.stringValue = @"TOTAL FILES";
    self.textTotalFilesStatus.stringValue = @"";
    
    self.progressSourceFile.minValue = 0;
    self.progressSourceFile.maxValue = 100;
    self.progressSourceFile.doubleValue = 0;
    
    self.progressTotalFiles.minValue = 0;
    self.progressTotalFiles.maxValue = 100;
    self.progressTotalFiles.doubleValue = 0;
    
    [self setTargetPathEditMode:NO];
}

- (void)setTargetPathEditMode:(BOOL)isEdit
{
    if (isEdit)
    {
        [self.editTargetPath setEnabled:YES];
        [self.editTargetPath setEditable:YES];

        [self.editTargetPath setHidden:NO];
        [self.textTargetPath setHidden:YES];
        
        self.textTargetLabel.stringValue = @"TO FILENAME";
    }
    else
    {
        [self.editTargetPath setEnabled:NO];
        [self.editTargetPath setEditable:NO];
        
        [self.editTargetPath setHidden:YES];
        [self.textTargetPath setHidden:NO];
        
        self.textTargetLabel.stringValue = @"TO";
    }
}

- (void)beforeStart
{
    _prevItemProgressPercent = 0;
    _prevTotalProgressPercent = 0;
    
    self.textTotalFiles.stringValue = [NSString stringWithFormat:@"TOTAL FILES: %lu", self.fileOperation.filesTotalCount.integerValue];
    
    self.textTotalFilesStatus.stringValue = [NSString stringWithFormat:@"0%% of %@", self.fileOperation.filesTotalSizeText];
    
    long long filesTotalSize = self.fileOperation.filesTotalSize.longLongValue;
    
    if (filesTotalSize == 0)
    {
        self.progressTotalFiles.maxValue = 1;
        self.progressTotalFiles.doubleValue = 0;
    }
    else
    {
        self.progressTotalFiles.maxValue = 100;
    }
    
    self.textTargetPath.stringValue = self.fileOperation.targetProvider.currentPath;
    
    if (self.fileOperation.filesTotalCountIsOne)
    {
        [self setTargetPathEditMode:YES];
    }
}

- (NSString *)targetPath
{
    return [self.editTargetPath.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)itemStart:(FMFileItem *)fileItem
{
    _prevItemProgressPercent = 0;
    
    self.textSourceFile.stringValue = [NSString stringWithFormat:@"FILE: %lu", self.fileOperation.fileIndex];
    
    if (fileItem.isDirectory == NO)
    {
        self.textSourceFileName.stringValue = fileItem.filePath;
        self.textSourceFileStatus.stringValue = [NSString stringWithFormat:@"0%% of %@", fileItem.fileSizeText];
        
        self.progressSourceFile.doubleValue = 0;
        self.progressSourceFile.maxValue = 100;
    }
    
    if (self.fileOperation.filesTotalCountIsOne)
    {
        self.editTargetPath.stringValue = [fileItem.targetFilePath copy];
    }    
}

- (void)updateFileItemBeforeStart:(FMFileItem *)fileItem
{
    if (self.fileOperation.filesTotalCountIsOne)
    {
        //disable edit just before processing
        [self.editTargetPath setEditable:NO];
    }
}

- (void)itemProgress:(FMFileItem *)fileItem
{
    if (fileItem.isDirectory == NO)
    {
        int progressPercent = self.fileOperation.fileProgressPercentBySize;
        
        if (_prevItemProgressPercent != progressPercent)
        {
            _prevItemProgressPercent = progressPercent;
        
            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.textSourceFileStatus.stringValue = [NSString stringWithFormat:@"%d%% of %@", self.fileOperation.fileProgressPercentBySize, fileItem.fileSizeText];
                
                self.progressSourceFile.doubleValue = progressPercent;
            });
        }
    }
}

- (void)itemFinish:(FMFileItem *)fileItem
{
    if (fileItem.isDirectory == NO)
    {
        int totalProgressPercent = self.fileOperation.totalProgressPercentBySize;
        
        if (_prevTotalProgressPercent != totalProgressPercent)
        {
            _prevTotalProgressPercent = totalProgressPercent;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.textTotalFilesStatus.stringValue = [NSString stringWithFormat:@"%d%% of %@", self.fileOperation.totalProgressPercentBySize, self.fileOperation.filesTotalSizeText];
                
                self.progressTotalFiles.doubleValue = totalProgressPercent;
            });
        }
    }
}

@end
