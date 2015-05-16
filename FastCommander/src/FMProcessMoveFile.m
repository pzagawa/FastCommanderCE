//
//  FMProcessMoveFile.m
//  FastCommander
//
//  Created by Piotr Zagawa on 30.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMProcessMoveFile.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMCommand.h"

@implementation FMProcessMoveFile

- (id)initWithFileOperation:(FMFileCopyOperation *)fileOperation
{
    self = [super init];
    
    if (self)
    {
        self.fileOperation = fileOperation;
    }
    
    return self;
}

- (void)moveFileItem:(FMFileItem *)fileItem toPath:(NSString *)targetFilePath
{
    @try
    {
        //process file item
        NSError *error = nil;
        
        if ([self.fileOperation.sourceProvider moveFile:fileItem.filePath to:targetFilePath error:&error] == YES)
        {
            //set TODO item as done
            [fileItem setAsFinished];
        }
        else
        {
            //set item error status
            [fileItem setStatus:FMFileItemStatus_SOURCE_MOVE_ERROR withError:error];
        }
    }
    @catch (NSException *exception)
    {
        //set item error status
        [fileItem setStatus:FMFileItemStatus_ERROR withException:exception];
    }
    @finally
    {
        //remove unfinished file
        [self.fileOperation removeIncompleteFile:fileItem inPath:targetFilePath];
    }
}

@end
