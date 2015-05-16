//
//  FMProcessCopyFile.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMProcessCopyFile.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMFileCopyOperation.h"
#import "FMCommand.h"

@implementation FMProcessCopyFile
{
    int _dataBufferSize;
    uint8_t *_fileDataBuffer;
    NSMutableDictionary *_fileAttributes;
}

- (id)initWithFileOperation:(FMFileCopyOperation *)fileOperation
{
    self = [super init];
    
    if (self)
    {
        self.fileOperation = fileOperation;
        
        self->_dataBufferSize = 1024 * 4;
        self->_fileDataBuffer = malloc(_dataBufferSize);

        self->_fileAttributes = [[NSMutableDictionary alloc] init];
        [self->_fileAttributes setValue:[NSNull null] forKey:NSFileModificationDate];
    }
    
    return self;
}

-(void)dealloc
{
    free(self->_fileDataBuffer);
}

- (void)copyFileItem:(FMFileItem *)fileItem toPath:(NSString *)targetFilePath
{
    NSInputStream *inputStream = nil;
    NSOutputStream *outputStream = nil;
    
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

        //get write stream
        outputStream = [self.fileOperation.targetProvider getOutputStream:targetFilePath];
        
        if (outputStream == nil)
        {
            //can't get write stream
            [fileItem setStatus:FMFileItemStatus_OUTPUT_OPEN_ERROR];
            return;
        }
                    
        //open streams
        [inputStream open];
        [outputStream open];
        
        //process input stream
        [self copyFileItem:fileItem fromSource:inputStream toTarget:outputStream];
        
        //copy attributes to output file
        [self copyFileAttributesFrom:fileItem toPath:targetFilePath];
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
        if (outputStream != nil)
        {
            [outputStream close];
        }
        
        //remove unfinished file
        [self.fileOperation removeIncompleteFile:fileItem inPath:targetFilePath];
    }
}

- (void)copyFileItem:(FMFileItem *)fileItem fromSource:(NSInputStream *)input toTarget:(NSOutputStream *)output
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
                
                //update progress
                self.fileOperation.fileProgressSize += chunkSize;

                [self.fileOperation.progressDelegate itemProgress:fileItem];
                
                //write buffer
                if ([output hasSpaceAvailable])
                {
                    NSInteger writeResult = [output write:_fileDataBuffer maxLength:chunkSize];
                    
                    //write error
                    if (writeResult < 0)
                    {
                        [fileItem setStatus:FMFileItemStatus_WRITE_ERROR withError:output.streamError];
                        break;
                    }
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

- (void)copyFileAttributesFrom:(FMFileItem *)fileItem toPath:(NSString *)targetFilePath
{
    //modification date
    [self->_fileAttributes setValue:fileItem.modificationDate forKey:NSFileModificationDate];    

    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm setAttributes:_fileAttributes ofItemAtPath:targetFilePath error:nil];
    
    //other attrs
    NSURL *url = [NSURL fileURLWithPath:targetFilePath];
    
    NSError *error;
    
    NSNumber *isHidden = fileItem.isHidden ? @1 : @0;
    
    [url setResourceValue:isHidden forKey:NSURLIsHiddenKey error:&error];
}

@end
