//
//  FMThemeManager.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMThemeManager.h"
#import "FMThemeMac.h"
#import "FMThemeNorton.h"
#import "FMThemeMatrix.h"
#import "FMThemeChocolate.h"
#import "FMThemeChocolate1.h"
#import "FMThemeSublime.h"
#import "FMThemeSolarizedLight.h"
#import "FMThemeSolarizedLightColor1.h"
#import "FMThemeSolarizedDark.h"
#import "FMThemeSolarizedDarkColor1.h"
#import "FMThemeCustom1.h"
#import "FMThemeCustom2.h"
#import "FMSettings.h"

@implementation FMThemeManager
{
    NSMutableArray *_themesList;
}

+ (FMThemeManager *)instance
{
    static FMThemeManager *singleton = nil;
    
    @synchronized(self)
    {
        if (!singleton)
        {
            singleton = [[FMThemeManager alloc] init];
        }
        
        return singleton;
    }
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_themesList = [[NSMutableArray alloc] init];
        
        [self->_themesList addObject:[FMThemeCustom1 new]];
        [self->_themesList addObject:[FMThemeCustom2 new]];
        [self->_themesList addObject:[FMThemeMac new]];
        [self->_themesList addObject:[FMThemeNorton new]];
        [self->_themesList addObject:[FMThemeSolarizedLight new]];
        [self->_themesList addObject:[FMThemeSolarizedLightColor1 new]];
        [self->_themesList addObject:[FMThemeSolarizedDark new]];
        [self->_themesList addObject:[FMThemeSolarizedDarkColor1 new]];
        [self->_themesList addObject:[FMThemeMatrix new]];
        [self->_themesList addObject:[FMThemeChocolate new]];
        [self->_themesList addObject:[FMThemeChocolate1 new]];
        [self->_themesList addObject:[FMThemeSublime new]];
        
        [self selectThemeByName:[[FMSettings instance] selectedThemeName]];
    }
    
    return self;
}

- (NSUInteger)themesCount
{
    return self->_themesList.count;
}

- (FMTheme *)themeByIndex:(NSUInteger)index
{
    return [self->_themesList objectAtIndex:index];
}

- (FMTheme *)themeByName:(NSString *)name
{
    for (int index = 0; index < self->_themesList.count; index++)
    {
        FMTheme *themeItem = [self->_themesList objectAtIndex:index];
        
        if ([themeItem.themeName isEqualToString:name])
        {
            return themeItem;
        }
    }

    return nil;
}

- (NSUInteger)themeIndexByName:(NSString *)name
{
    for (int index = 0; index < self->_themesList.count; index++)
    {
        FMTheme *themeItem = [self->_themesList objectAtIndex:index];
        
        if ([themeItem.themeName isEqualToString:name])
        {
            return index;
        }
    }
    
    return -1;
}

- (void)selectThemeByName:(NSString *)name
{
    FMTheme *foundTheme = [self themeByName:name];
    
    if (foundTheme == nil)
    {
        //select default
        self.theme = [self->_themesList objectAtIndex:0];
    }
    else
    {
        if ([foundTheme.themeName isEqualToString:self.theme.themeName])
        {
            return;
        }

        //save selection
        FMSettings.instance.selectedThemeName = name;
        
        //set selection
        self.theme = foundTheme;
    }
}

@end
