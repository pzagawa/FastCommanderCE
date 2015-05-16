//
//  FMSettings.m
//  FastCommander
//
//  Created by Piotr Zagawa on 18.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMSettings.h"
#import "NSString+Utils.h"

@implementation FMSettings

static NSString *const KEY_isHiddenFilesVisible = @"isHiddenFilesVisible";
static NSString *const KEY_selectedThemeName = @"selectedThemeName";
static NSString *const KEY_startMessageForVersion = @"startMessageForVersion";
static NSString *const KEY_bookmarks = @"bookmarks";
static NSString *const KEY_isUseTrash = @"useTrash";

+ (FMSettings *)instance
{
    static FMSettings *singleton = nil;
    
    @synchronized(self)
    {
        if (singleton == nil)
        {
            singleton = [[FMSettings alloc] init];
        }
        
        return singleton;
    }
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSDictionary *defaults = @
        {
            KEY_isHiddenFilesVisible: @NO,
            KEY_selectedThemeName: @"Black Mesa Low",
            KEY_startMessageForVersion: @"",
            KEY_bookmarks: @[],
        };
        
        //register defaults
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];    
    }
    
    return self;
}

//property isHiddenFilesVisible
- (BOOL)isHiddenFilesVisible
{
    @synchronized(KEY_isHiddenFilesVisible)
    {
        return ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_isHiddenFilesVisible]);
    }
}

- (void)setIsHiddenFilesVisible:(BOOL)value
{
    @synchronized(KEY_isHiddenFilesVisible)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:value forKey:KEY_isHiddenFilesVisible];
    }
}

//property selectedThemeName
- (NSString *)selectedThemeName
{
    @synchronized(KEY_selectedThemeName)
    {
        return ([[NSUserDefaults standardUserDefaults] stringForKey:KEY_selectedThemeName]);
    }
}

- (void)setSelectedThemeName:(NSString *)value
{
    @synchronized(KEY_selectedThemeName)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:value forKey:KEY_selectedThemeName];
    }
}

//property KEY_startMessageForVersion
- (NSString *)startMessageForVersion
{
    @synchronized(KEY_startMessageForVersion)
    {
        return ([[NSUserDefaults standardUserDefaults] stringForKey:KEY_startMessageForVersion]);
    }
}

- (void)setStartMessageForVersion:(NSString *)value
{
    @synchronized(KEY_startMessageForVersion)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:value forKey:KEY_startMessageForVersion];
    }
}

- (NSString *)appVersion
{
    NSBundle *bundle = NSBundle.mainBundle;

    if (bundle == nil)
    {
        return @"";
    }
    else
    {
        return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
}

- (BOOL)isStartMessageForNewAppVersion
{
    NSString *version = self.appVersion;
    
    NSString *storedVersion = self.startMessageForVersion;

    if ([version isEqualToString:storedVersion])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)saveNewAppVersionForStartMessage
{
    NSString *version = self.appVersion;

    [self setStartMessageForVersion:version];
}

- (BOOL)isUseTrash
{
    @synchronized(KEY_isUseTrash)
    {
        return ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_isUseTrash]);
    }
}

- (void)setIsUseTrash:(BOOL)value
{
    @synchronized(KEY_isUseTrash)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:value forKey:KEY_isUseTrash];
    }
}

//property bookmarks - string array
- (NSArray *)bookmarks
{
    @synchronized(KEY_bookmarks)
    {
        return ([NSUserDefaults.standardUserDefaults stringArrayForKey:KEY_bookmarks]);
    }
}

- (void)setBookmarks:(NSArray *)value
{
    @synchronized(KEY_bookmarks)
    {
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;

        [defaults setObject:value forKey:KEY_bookmarks];
    }
}

@end
