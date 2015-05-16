//
//  FMConsts.m
//  FastCommander
//
//  Created by Piotr Zagawa on 17.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMConsts.h"

@implementation FMConsts

+ (FMConsts *)instance
{
    static FMConsts *singleton = nil;
    
    @synchronized(self)
    {
        if (!singleton)
        {
            singleton = [[FMConsts alloc] init];
        }
        
        return singleton;
    }
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (NSString *)applicationTitle
{
    return @"FastCommander";
}

- (NSString *)applicationAuthor
{
    return @"PIOTR ZAGAWA";
}

- (NSString *)applicationHomepage
{
    return @"http://www.fastcommander.com";
}

- (NSURL *)applicationHelpPageUrl
{
    return [NSURL URLWithString:self.applicationHelpPage];
}

- (NSString *)applicationFullTitle
{
    NSMutableString *text = [[NSMutableString alloc] init];
    
    [text appendString:self.applicationTitle];
    [text appendString:@" "];
    [text appendString:@"©"];
    [text appendString:@" "];
    [text appendString:self.applicationAuthor];

    return text;
}

- (NSString *)applicationTitleWithVersion
{
    NSMutableString *text = [[NSMutableString alloc] init];
    
    [text appendString:self.applicationTitle];
    [text appendString:@" "];
    
    NSBundle *bundle = [NSBundle mainBundle];
    
    if (bundle != nil)
    {
        NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
        [text appendString:version];
    }
    
    return text;
}

- (NSURL *)applicationHomepageUrl
{
    return [NSURL URLWithString:self.applicationHomepage];
}

- (NSString *)copyrightText
{
    NSMutableString *text = [[NSMutableString alloc] init];
    
    [text appendString:@"COPYRIGHT ©"];
    [text appendString:@" "];
    [text appendString:@"2013 – 2015"];
    [text appendString:@" "];
    [text appendString:self.applicationAuthor];
    
    return text;
}

@end

