//
//  FMBookmarksManager.m
//  FastCommander
//
//  Created by Piotr Zagawa on 07.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMBookmarksManager.h"
#import "FMWorkDirectory.h"
#import "AppDelegate.h"
#import "FMSearchPanelListProvider.h"
#import "FMSettings.h"
#import "NSString+Utils.h"

@implementation FMBookmarkItem

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self)
    {
        self->_path = [path copy];
        
        self.isVisible = YES;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if (self)
    {
        self->_path = [url.path copy];
        
        self.isVisible = YES;
    }
    
    return self;
}

- (NSString *)pathForPanel:(FMPanelSide)panelSide
{
    if (self.type == FMBookmarkItemTypeSearchProvider)
    {
        if (panelSide != FMPanelSideUnspecified)
        {
            FMBookmarkItem *searchBookmark = [FMBookmarkItem searchBookmarkForPanel:panelSide];
            
            if (searchBookmark != nil)
            {
                return [searchBookmark.path copy];
            }
        }
    }

    return self.path;
}

- (BOOL)isBookmarkAvailable
{
    //test if bookmark currently accessible
    if (self.type == FMBookmarkItemTypeVolume || self.type == FMBookmarkItemTypeUserPath || self.type == FMBookmarkItemTypeCustom)
    {
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:self.path isDirectory:YES];
        
        NSError *err;
        
        if ([fileUrl checkResourceIsReachableAndReturnError:&err] == YES)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isBookmarkAvailableForPanel:(FMPanelSide)panelSide
{
    //test if bookmark currently accessible
    if (self.type == FMBookmarkItemTypeVolume || self.type == FMBookmarkItemTypeUserPath)
    {
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:self.path isDirectory:YES];
        
        NSError *err;
        
        if ([fileUrl checkResourceIsReachableAndReturnError:&err] == YES)
        {
            return YES;
        }
    }
    
    //test if bookmark currently accessible
    if (self.type == FMBookmarkItemTypeSearchProvider)
    {
        if (panelSide == FMPanelSideUnspecified)
        {
            return YES;
        }
        else
        {
            FMBookmarkItem *searchBookmark = [FMBookmarkItem searchBookmarkForPanel:panelSide];

            if (searchBookmark != nil)
            {
                return YES;
            }
        }
    }
    
    if (self.type == FMBookmarkItemTypeCustom)
    {
        return YES;
    }

    return NO;
}

- (BOOL)isEqualToBookmark:(FMBookmarkItem *)bookmark
{
    if ([bookmark.path isEqualToString:self.path])
    {
        return YES;
    }

    return NO;
}

- (NSString *)toString
{
    NSString *text_visible = self.isVisible ? @"V" : @"_";
    
    return [NSString stringWithFormat:@"%@|%d|%@", text_visible, self.type, self.path];
}

+ (FMBookmarkItem *)fromText:(NSString *)text
{
    //decode text bookmark data
    NSArray *parts = [text componentsSeparatedByString:@"|"];
    
    if (parts.count == 3)
    {
        BOOL isVisible = [[parts objectAtIndex:0] isEqualToString:@"V"];
        NSInteger type = [[parts objectAtIndex:1] integerValue];
        NSString *path = [parts objectAtIndex:2];

        //create object
        FMBookmarkItem *bookmark = [[FMBookmarkItem alloc] initWithPath:path];

        bookmark->_isVisible = isVisible;
        bookmark->_type = (FMBookmarkItemType)type;
        
        return bookmark;
    }
    
    return nil;
}

+ (FMBookmarkItem *)fromPath:(NSString *)path visible:(BOOL)isVisible itemType:(FMBookmarkItemType)type
{
    FMBookmarkItem *bookmark = [[FMBookmarkItem alloc] initWithPath:path];

    bookmark->_isVisible = isVisible;
    bookmark->_type = type;
    
    return bookmark;
}

+ (FMBookmarkItem *)fromURL:(NSURL *)url visible:(BOOL)isVisible itemType:(FMBookmarkItemType)type
{
    FMBookmarkItem *bookmark = [[FMBookmarkItem alloc] initWithURL:url];
    
    bookmark->_isVisible = isVisible;
    bookmark->_type = type;
    
    return bookmark;
}

+ (FMBookmarkItem *)searchBookmarkForPanel:(FMPanelSide)panelSide
{
    if (panelSide == FMPanelSideUnspecified)
    {
        return [FMBookmarkItem fromPath:@"SEARCH:" visible:YES itemType:FMBookmarkItemTypeSearchProvider];
    }
    
    FMPanelListProviderManager *providerManager = [AppDelegate.this panelListProviderManager:panelSide];
    
    FMSearchPanelListProvider *searchProvider = providerManager.searchProvider;
    
    if (searchProvider.sourceFileItems != nil)
    {
        if (searchProvider.sourceFileItems.count > 0)
        {
            return [FMBookmarkItem fromPath:searchProvider.providerTitle visible:YES itemType:FMBookmarkItemTypeSearchProvider];
        }
    }
    
    return nil;
}

@end

//MANAGER
@implementation FMBookmarksManager
{
    NSArray *_volumeBookmarks;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_volumeBookmarks = [self createVolumeBookmarks];
    }
    
    return self;
}

- (void)updateInBackground
{
    NSOperationQueue *_queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        [self update];
    }];
    
    [_queue addOperation:operation];
}

- (void)update
{
    NSMutableArray *bookmarks = [[NSMutableArray alloc] init];

    //load from settings
    [bookmarks addObjectsFromArray:[self loadBookmarks]];

    if (bookmarks.count == 0)
    {
        //create defaults if settings empty
        NSArray *defaults = [self createDefaultBookmarksListForPanel:FMPanelSideUnspecified];

        [bookmarks addObjectsFromArray:defaults];
    }

    //update list with new volume bookmarks
    for (FMBookmarkItem *bookmark in self->_volumeBookmarks)
    {
        if ([self isBookmark:bookmark onList:bookmarks] == NO)
        {
            [bookmarks insertObject:bookmark atIndex:0];
        }
    }

    [self saveBookmarks:bookmarks];
}

+ (NSArray *)bookmarksStringsForPanel:(FMPanelSide)panelSide
{
    FMBookmarksManager *manager = [[FMBookmarksManager alloc] init];

    [manager update];

    NSArray *bookmarks = [manager loadBookmarks];

    return [manager bookmarksStringsForPanel:panelSide fromBookmarks:bookmarks];
}

- (NSArray *)bookmarksStringsForPanel:(FMPanelSide)panelSide fromBookmarks:(NSArray *)bookmarks
{
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    
    for (FMBookmarkItem *bookmark in bookmarks)
    {
        if (bookmark.isVisible)
        {
            if ([bookmark isBookmarkAvailableForPanel:panelSide])
            {
                [strings addObject:[bookmark pathForPanel:panelSide]];
            }
        }
    }

    return strings;
}

- (NSArray *)createVolumeBookmarks
{
    NSMutableArray *bookmarks = [NSMutableArray new];
    
    NSArray *volumes = [FMWorkDirectory getMountedVolumes];
    
    if (volumes != nil)
    {
        for (NSURL *url in volumes)
        {
            if ([FMWorkDirectory isRootDirectory:url.path] == NO)
            {
                [bookmarks addObject:[FMBookmarkItem fromURL:url visible:YES itemType:FMBookmarkItemTypeVolume]];
            }
        }
    }
    
    return bookmarks;
}

- (NSArray *)createDefaultBookmarksListForPanel:(FMPanelSide)panelSide
{
    NSMutableArray *bookmarks = [NSMutableArray new];
    
    //get volumes
    [bookmarks addObjectsFromArray:self->_volumeBookmarks];

    //get user paths
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getUsersDirectory] visible:NO itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getUserDirectory] visible:YES itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getDesktopDirectory] visible:YES itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getDocumentsDirectory] visible:YES itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getDownloadsDirectory] visible:YES itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getMoviesDirectory] visible:NO itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getMusicDirectory] visible:NO itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getPicturesDirectory] visible:NO itemType:FMBookmarkItemTypeUserPath]];
    [bookmarks addObject:[FMBookmarkItem fromURL:[FMWorkDirectory getPublicDirectory] visible:YES itemType:FMBookmarkItemTypeUserPath]];

    //add fixed strings
    FMBookmarkItem *searchBookmark = [FMBookmarkItem searchBookmarkForPanel:panelSide];

    if (searchBookmark != nil)
    {
        [bookmarks addObject:searchBookmark];
    }

    return bookmarks;
}

- (void)saveBookmarks:(NSArray *)bookmarks
{
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    
    for (FMBookmarkItem *bookmark in bookmarks)
    {
        [strings addObject:bookmark.toString];
    }
    
    FMSettings.instance.bookmarks = strings;
}

- (BOOL)isBookmark:(FMBookmarkItem *)bookmark onList:(NSArray *)bookmarks
{
    for (FMBookmarkItem *item in bookmarks)
    {
        if ([item isEqualToBookmark:bookmark])
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)loadBookmarks
{
    //decode bookmarks from settings storage
    NSArray *encodedBookmarks = FMSettings.instance.bookmarks;

    NSMutableArray *bookmarks = [[NSMutableArray alloc] init];
    
    for (NSString *encodedBookmark in encodedBookmarks)
    {
        FMBookmarkItem *bookmark = [FMBookmarkItem fromText:encodedBookmark];
        
        if (bookmark != nil)
        {
            [bookmarks addObject:bookmark];
        }
    }

    return bookmarks;
}

- (BOOL)addBookmark:(NSString *)directory
{
    NSString *path = directory.trim;
    
    FMBookmarkItem *bookmark = [FMBookmarkItem fromPath:path visible:YES itemType:FMBookmarkItemTypeCustom];
    
    if (bookmark.isBookmarkAvailable)
    {
        NSMutableArray *bookmarks = [[NSMutableArray alloc] init];
        
        [bookmarks addObjectsFromArray:[self loadBookmarks]];

        if ([self isBookmark:bookmark onList:bookmarks] == NO)
        {
            [bookmarks addObject:bookmark];
            [self saveBookmarks:bookmarks];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)removeBookmark:(FMBookmarkItem *)bookmark
{
    NSMutableArray *bookmarks = [[NSMutableArray alloc] init];
    
    [bookmarks addObjectsFromArray:[self loadBookmarks]];

    for (int index = 0; index < bookmarks.count; index++)
    {
        FMBookmarkItem *item = [bookmarks objectAtIndex:index];
        
        if ([item isEqualToBookmark:bookmark])
        {
            [bookmarks removeObjectAtIndex:index];
            [self saveBookmarks:bookmarks];
            return YES;
        }
    }

    return NO;
}

@end
