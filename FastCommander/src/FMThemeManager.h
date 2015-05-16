//
//  FMThemeManager.h
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMTheme.h"

@interface FMThemeManager : NSObject

@property FMTheme *theme;
@property (readonly) NSUInteger themesCount;

+ (FMThemeManager *)instance;

- (id)init;

- (FMTheme *)themeByIndex:(NSUInteger)index;
- (FMTheme *)themeByName:(NSString *)name;
- (NSUInteger)themeIndexByName:(NSString *)name;

- (void)selectThemeByName:(NSString *)name;

@end
