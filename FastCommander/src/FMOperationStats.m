//
//  FMOperationStats.m
//  FastCommander
//
//  Created by Piotr Zagawa on 05.10.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <mach/mach_time.h>
#import "FMOperationStats.h"
#import "FMFileCopyOperation.h"

@implementation FMOperationStats
{
    uint64_t _startTime;
    long long _startSize;
    
    NSMutableArray *_samplesBuffer;
    
    int _resultUpdateCounter;
}

- (void)reset
{
    _startTime = 0;
    _startSize = 0;

    _samplesBuffer = [[NSMutableArray alloc] init];
    
    _resultUpdateCounter = 0;

    _info = @"Calculating speed..";
}

- (void)updateOnItemStart:(FMFileCopyOperation *)fileCopyOperation
{
    if (_startTime == 0)
    {
        _startTime = mach_absolute_time();
        _startSize = fileCopyOperation.totalProgressSize;
    }
}

- (void)updateOnItemProgress:(FMFileCopyOperation *)fileCopyOperation
{
    if (_startTime == 0)
    {
        _startTime = mach_absolute_time();
        _startSize = fileCopyOperation.totalProgressSize;
    }

    long milisecondsFromStart = [fileCopyOperation milisFromKernelTime:(mach_absolute_time() - _startTime)];

    if (milisecondsFromStart >= 100)
    {
        long long sizeProcessed = fileCopyOperation.totalProgressSize - _startSize;
        
        if (sizeProcessed > 0)
        {
            long long bytesPerSecond = (long long)(((double)sizeProcessed / (double)milisecondsFromStart) * 1000);
        
            if (bytesPerSecond != 0)
            {
                [self collectSample:bytesPerSecond];
    
                if (_resultUpdateCounter >= 5)
                {
                    [self updateResult:fileCopyOperation];
            
                    _resultUpdateCounter = 0;
                }
                else
                {
                    _resultUpdateCounter++;
                }
            }
        }
        
        //reset
        _startTime = mach_absolute_time();
        _startSize = fileCopyOperation.totalProgressSize;
    }
}

- (NSString *)speedText:(long long)bytesPerSecond
{
    double ONE_KB = (double)(1024);
    double ONE_MB = (double)(1024 * 1024);
    
    //calc bytes average speed
    if (bytesPerSecond < ONE_KB)
    {
        return @"1KB/s";
    }

    //calc kbytes average speed
    if (bytesPerSecond < ONE_MB)
    {
        long kilobytesPerSecond = (double)bytesPerSecond / ONE_KB;
        
        return [NSString stringWithFormat:@"%ldKB/s", kilobytesPerSecond];
    }

    //calc mbytes average speed
    if (bytesPerSecond >= ONE_MB)
    {
        long megabytesPerSecond = (double)bytesPerSecond / ONE_MB;
        
        return [NSString stringWithFormat:@"%ldMB/s", megabytesPerSecond];
    }

    return @"(?)";
}

- (void)updateResult:(FMFileCopyOperation *)fileCopyOperation
{
    long long bytesPerSecond = self.averageBytesPerSecond;

    NSString *speed = [self speedText:bytesPerSecond];
    
    //calc time left
    long long bytesLeft = [self progressSizeLeft:fileCopyOperation];
    
    NSTimeInterval secondsLeft = 0;
    
    if (bytesPerSecond > 0)
    {
        secondsLeft = (int)((double)bytesLeft / (double)bytesPerSecond);
    }
    
    NSString *timeLeft = [self textFromSeconds:secondsLeft];
    
    //update info
    self->_info = [NSString stringWithFormat:@"%@. TIME LEFT: %@", speed, timeLeft];
}

- (void)collectSample:(long long)bytesPerSecond
{
    [_samplesBuffer addObject:[NSNumber numberWithLongLong:bytesPerSecond]];
    
    if (_samplesBuffer.count > 50)
    {
        [_samplesBuffer removeObjectAtIndex:0];
    }
}

- (long long)averageBytesPerSecond
{
    long long average = 0;
    
    for (NSNumber *value in _samplesBuffer)
    {
        average += value.longLongValue;
        
    }
    
    if (_samplesBuffer.count == 0)
    {
        return 0;
    }
    
    return average / _samplesBuffer.count;
}

- (void)updateOnItemFinish:(FMFileCopyOperation *)fileCopyOperation
{
}

- (long long)progressSizeLeft:(FMFileCopyOperation *)fileCopyOperation
{
    return fileCopyOperation.filesTotalSize.longLongValue - fileCopyOperation.totalProgressSize;
}

- (NSString *)textFromSeconds:(NSTimeInterval)secondsValue
{
    if (secondsValue < 60)
    {
        if (secondsValue < 15)
        {
            return @"a few seconds";
        }

        if (secondsValue < 30)
        {
            return @"half a minute";
        }

        return @"less than minute";
    }

    NSUInteger hours = secondsValue / 3600;
    NSUInteger minutes = secondsValue / 60 - hours * 60;
    
    if (hours < 1)
    {
        if (minutes == 1)
        {
            return @"one minute";
        }
        else
        {
            return [NSString stringWithFormat:@"%lu minutes", (unsigned long)minutes];
        }
    }
    
    if (hours == 1)
    {
        if (minutes == 1)
        {
            return [NSString stringWithFormat:@"one hour and one minute"];
        }
        else
        {
            return [NSString stringWithFormat:@"one hour and %lu minutes", (unsigned long)minutes];
        }
    }

    if (minutes == 1)
    {
        return [NSString stringWithFormat:@"%lu hours and one minute", hours];
    }
    else
    {
        return [NSString stringWithFormat:@"%lu hours and %lu minutes", hours, minutes];
    }
}

@end
