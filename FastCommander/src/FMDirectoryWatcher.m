//
//  FMDirectoryWatcher.m
//  FastCommander
//
//  Created by Piotr Zagawa on 04.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMDirectoryWatcher.h"
#import "NSString+Utils.h"

@implementation FMDirectoryWatcher
{
    FSEventStreamRef _stream;
    NSString *_path;
    CFStringRef _cPath;
    CFArrayRef _pathsToWatch;
    FSEventStreamContext _context;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self)
    {
        //create paths
        self->_path = [path copy];
        self->_cPath = (__bridge CFStringRef)(self->_path);
        self->_pathsToWatch = CFArrayCreate(NULL, (const void **)&self->_cPath, 1, NULL);
        
        //setup context
        void *userData = (__bridge void *)self;
        
        self->_context.version = 0;
        self->_context.info = userData;
        self->_context.retain = nil;
        self->_context.release = nil;
        self->_context.copyDescription = nil;
        
        [self start];
    }
    
    return self;
}

-(void)dealloc
{
    [self stop];
    
    if (self->_pathsToWatch != nil)
    {
        CFRelease(self->_pathsToWatch);
    }
}

- (void)start
{
    CFAbsoluteTime latencySeconds = 0.5;
    
    FSEventStreamCreateFlags flags = kFSEventStreamCreateFlagIgnoreSelf;
    
    _stream = FSEventStreamCreate(NULL, &watcherEvent, &_context, _pathsToWatch, kFSEventStreamEventIdSinceNow, latencySeconds, flags);

    if (_stream != nil)
    {
        FSEventStreamScheduleWithRunLoop(_stream, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        
        FSEventStreamStart(_stream);
    }    
}

static void watcherEvent(ConstFSEventStreamRef streamRef, void *userData, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    FMDirectoryWatcher *watcher = (__bridge FMDirectoryWatcher *)(userData);
    
    //standarize watcher path
    NSString *path = [[watcher->_path stringByStandardizingPath] stringByAppendingSlashSuffix];
    
    char **paths = eventPaths;

    for (int index = 0; index < numEvents; index++)
    {
        //standarize event path
        NSString *eventPath = [[[NSString alloc] initWithUTF8String:paths[index]] stringByAppendingSlashSuffix];

        //check only paths in level equal to watched
        if ([path isEqualToString:eventPath])
        {
            watcher.directoryContentChanged = YES;
            break;
        }
    }
}

- (void)stop
{
    if (_stream != nil)
    {
        FSEventStreamStop(_stream);
        FSEventStreamInvalidate(_stream);
        FSEventStreamRelease(_stream);

        _stream = nil;
    }
}

@end
