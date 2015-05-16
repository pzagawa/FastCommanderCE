//
//  FMProcessGetFile.m
//  FastCommander
//
//  Created by Piotr Zagawa on 20.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMProcessGetFile.h"
#import "FMPanelListProvider.h"
#import "FMFileItem.h"
#import "FMFileOperation.h"
#import "FMCommand.h"

@implementation FMProcessGetFile
{
    int _dataBufferSize;
    uint8_t *_fileDataBuffer;
}

- (id)initWithFileOperation:(FMFileOperation *)fileOperation
{
    self = [super init];
    
    if (self)
    {
        self.fileOperation = fileOperation;
        
        self->_dataBufferSize = 1024 * 128;
        self->_fileDataBuffer = malloc(_dataBufferSize);
    }
    
    return self;
}

-(void)dealloc
{
    free(self->_fileDataBuffer);
}

- (NSData *)fileItemAsData:(FMFileItem *)fileItem
{
    NSMutableData *data = nil;
    
    if (fileItem.isDirectory == NO)
    {
        NSInputStream *inputStream = nil;
        
        @try
        {
            //get read stream
            inputStream = [self.fileOperation.sourceProvider getInputStream:fileItem.filePath];
            
            if (inputStream == nil)
            {
                //can't get read stream
                [fileItem setStatus:FMFileItemStatus_INPUT_OPEN_ERROR];
                return nil;
            }
            
            //data buffer
            data = [[NSMutableData alloc] initWithCapacity:fileItem.fileSize];

            //open streams
            [inputStream open];

            //process stream
            while (YES)
            {
                if ([inputStream hasBytesAvailable])
                {
                    NSInteger readResult = [inputStream read:_fileDataBuffer maxLength:_dataBufferSize];
                    
                    //end of buffer
                    if (readResult == 0)
                    {
                        break;
                    }
                    
                    //read error
                    if (readResult < 0)
                    {
                        [fileItem setStatus:FMFileItemStatus_READ_ERROR withError:inputStream.streamError];
                        break;
                    }
                    
                    //process read chunk
                    if (readResult > 0)
                    {
                        NSInteger chunkSize = readResult;
                        
                        [data appendBytes:_fileDataBuffer length:chunkSize];
                        
                        //SYNC start file operation dispatch to avoid bugs
                        dispatch_sync(dispatch_get_main_queue(), ^
                        {
                            [self.fileOperation.progressDelegate itemProgress:fileItem];
                        });
                    }
                }
                else
                {
                    //no bytes to read
                    break;
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

    return data;
}

@end
