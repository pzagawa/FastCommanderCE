//
//  FMOSTools.h
//  FastCommander
//
//  Created by Piotr Zagawa on 20.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMOSTools : NSObject

+ (void)openConsole:(NSString *)path;
+ (void)openFinder:(NSString *)path;
+ (void)openFinderDirectly:(NSString *)path;

+ (NSURL *)defaultApplicationURlForFileURL:(NSURL *)fileUrl;
+ (NSArray *)applicationsURLsForFileURL:(NSURL *)fileUrl;

+ (void) newAppInstance;

@end
