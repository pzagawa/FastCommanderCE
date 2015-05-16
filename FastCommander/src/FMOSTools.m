//
//  FMOSTools.m
//  FastCommander
//
//  Created by Piotr Zagawa on 20.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOSTools.h"
#import "FMFileItem.h"

@implementation FMOSTools

+ (void)openConsole:(NSString *)path
{
    NSString *terminalCommand = [NSString stringWithFormat:@"cd '%@'", path];

    NSString *script = [NSString stringWithFormat:
        @"tell application \"System Events\"\n"
        @"  tell application \"Terminal\"\n"
        @"      activate\n"
        @"      activate front window\n"
        @"      do script \"%@\" in front window\n"
        @"  end tell\n"
        @"end tell\n",
        terminalCommand];
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:script];
    
    [as executeAndReturnError:nil];
}

+ (void)openFinder:(NSString *)path
{
    NSString *terminalCommand = [NSString stringWithFormat:@"open '%@'", path];
    
    NSString *script = [NSString stringWithFormat:
        @"tell application \"System Events\"\n"
        @"  tell application \"Finder\"\n"
        @"      activate\n"
        @"      do shell script \"%@\"\n"
        @"  end tell\n"
        @"end tell\n",
        terminalCommand];
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:script];
    
    [as executeAndReturnError:nil];
}

+ (void)openFinderDirectly:(NSString *)path
{
    NSURL *appPath = [self defaultApplicationURlForFileURL:[NSURL fileURLWithPath:path]];

    if (appPath != nil)
    {
        [[NSWorkspace sharedWorkspace] openFile:path withApplication:appPath.path];
    }
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:@"-c" , [NSString stringWithFormat:@"%@", commandToRun], nil];
    
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

+ (NSURL *)defaultApplicationURlForFileURL:(NSURL *)fileUrl
{
    NSURL *result = nil;
    
    CFURLRef app = nil;
    
    LSGetApplicationForURL((__bridge CFURLRef)fileUrl, kLSRolesAll, NULL, &app);
    
    if (app != nil)
    {
        NSURL *url = (__bridge NSURL *)app;
        
        result = [url copy];
        
        CFRelease(app);
    }
    
    return result;
}

+ (NSArray *)applicationsURLsForFileURL:(NSURL *)fileUrl
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    CFArrayRef array = LSCopyApplicationURLsForURL((__bridge CFURLRef)fileUrl, kLSRolesAll);
    
    if (array != nil)
    {
        CFIndex count = CFArrayGetCount(array);
        
        for (int index = 0; index < count; index++)
        {
            NSURL *url = (NSURL *)CFArrayGetValueAtIndex(array, index);
            
            [result addObject:[url copy]];
        }
        
        CFRelease(array);
    }
    
    return result;
}

+ (void) newAppInstance
{
    NSBundle *bundle = [NSBundle mainBundle];

    if (bundle.bundlePath != nil)
    {
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:bundle.bundleURL options:NSWorkspaceLaunchNewInstance configuration:nil error:nil];
    }
}

@end
