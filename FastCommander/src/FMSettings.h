//
//  FMSettings.h
//  FastCommander
//
//  Created by Piotr Zagawa on 18.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMSettings : NSObject

@property (readonly) NSString *installUUID;

@property BOOL isHiddenFilesVisible;
@property NSString *selectedThemeName;

@property NSArray *bookmarks;

@property (readonly) BOOL isStartMessageForNewAppVersion;

@property BOOL isUseTrash;

+ (FMSettings *)instance;

- (void)saveNewAppVersionForStartMessage;

@end
