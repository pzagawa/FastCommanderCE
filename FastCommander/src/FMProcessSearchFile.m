//
//  FMProcessSearchFile.m
//  FastCommander
//
//  Created by Piotr Zagawa on 22.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMProcessSearchFile.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMFileSearchOperation.h"
#import "FMBufferFinder.h"

@implementation FMProcessSearchFile
{
    int _dataBufferSize;
    uint8_t *_fileDataBuffer;
    
    FMBufferFinder *_bufferFinder;
}

- (id)initWithFileOperation:(FMFileSearchOperation *)fileOperation andText:(NSString *)text
{
    self = [super init];
    
    if (self)
    {
        self.fileOperation = fileOperation;
        
        self->_dataBufferSize = 1024 * 128;
        self->_fileDataBuffer = malloc(_dataBufferSize);

        self->_bufferFinder = [[FMBufferFinder alloc] initWithText:text];

        [self reset];
    }
    
    return self;
}

-(void)dealloc
{
    free(self->_fileDataBuffer);
}

- (void)reset
{
    self.matchFound = NO;
    self.matchPosition = -1;
    
    [_bufferFinder reset];
}

- (void)searchTextInFileItem:(FMFileItem *)fileItem
{
    [self reset];
    
    NSInputStream *inputStream = nil;
    
    @try
    {
        //get read stream
        inputStream = [self.fileOperation.sourceProvider getInputStream:fileItem.filePath];
        
        if (inputStream == nil)
        {
            //can't get read stream
            [fileItem setStatus:FMFileItemStatus_INPUT_OPEN_ERROR];
            return;
        }
        
        //open streams
        [inputStream open];
        
        //process input stream
        [self searchTextInFileItem:fileItem inSource:inputStream];
    }
    @catch (NSException *exception)
    {
        //set item error status
        [fileItem setStatus:FMFileItemStatus_ERROR withException:exception];
    }
    @finally
    {
        //close streams
        if (inputStream != nil)
        {
            [inputStream close];
        }
    }
}

- (void)searchTextInFileItem:(FMFileItem *)fileItem inSource:(NSInputStream *)input
{
    while (YES)
    {
        if ([input hasBytesAvailable])
        {
            NSInteger readResult = [input read:_fileDataBuffer maxLength:_dataBufferSize];
            
            //end of buffer
            if (readResult == 0)
            {
                break;
            }
            
            //read error
            if (readResult < 0)
            {
                [fileItem setStatus:FMFileItemStatus_READ_ERROR withError:input.streamError];
                break;
            }
            
            //process read chunk
            if (readResult > 0)
            {
                NSInteger chunkSize = readResult;
                
                if ([_bufferFinder process:_fileDataBuffer withSize:chunkSize] == NO)
                {
                    [fileItem setStatus:FMFileItemStatus_ERROR];
                    break;
                }
                
                if (_bufferFinder.isPatternMatch)
                {
                    self.matchFound = YES;
                    self.matchPosition = _bufferFinder.matchPosition;
                    break;
                }
            }
        }
        else
        {
            //no bytes to read
            break;
        }
        
        //check if operation paused
        if (self.fileOperation.isPaused)
        {
            [self.fileOperation waitOnResume];
        }
        
        //check if operation canceled
        if (self.fileOperation.isCanceled)
        {
            //set item status
            fileItem.status = FMFileItemStatus_CANCELED;
            break;
        }
    }
    
    //set TODO item as done
    [fileItem setAsFinished];
}

@end
