//
//  FMBookmarksManager.h
//  FastCommander
//
//  Created by Piotr Zagawa on 07.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMCustomTypes.h"

//ITEM
@interface FMBookmarkItem : NSObject

typedef enum
{
    FMBookmarkItemTypeVolume = 1,
    FMBookmarkItemTypeUserPath = 2,
    FMBookmarkItemTypeSearchProvider = 3,
    FMBookmarkItemTypeCustom = 4,
    
} FMBookmarkItemType;

@property (readonly) NSString *path;
@property (readonly) FMBookmarkItemType type;

@property BOOL isVisible;

+ (FMBookmarkItem *)searchBookmarkForPanel:(FMPanelSide)panelSide;

+ (FMBookmarkItem *)fromPath:(NSString *)path visible:(BOOL)isVisible itemType:(FMBookmarkItemType)type;
+ (FMBookmarkItem *)fromURL:(NSURL *)url visible:(BOOL)isVisible itemType:(FMBookmarkItemType)type;

- (BOOL)isBookmarkAvailable;
- (BOOL)isBookmarkAvailableForPanel:(FMPanelSide)panelSide;

- (NSString *)pathForPanel:(FMPanelSide)panelSide;

- (NSString *)toString;

@end

//MANAGER
@interface FMBookmarksManager : NSObject

- (NSArray *)loadBookmarks;
- (void)saveBookmarks:(NSArray *)bookmarks;

- (void)update;
- (void)updateInBackground;

- (BOOL)addBookmark:(NSString *)directory;
- (BOOL)removeBookmark:(FMBookmarkItem *)bookmark;

+ (NSArray *)bookmarksStringsForPanel:(FMPanelSide)panelSide;

@end
