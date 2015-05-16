//
//  FMContextMenu.m
//  FastCommander
//
//  Created by Piotr Zagawa on 27.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMContextMenu.h"
#import "FMPanelListItem.h"
#import "FMPanelListProvider.h"
#import "AppDelegate.h"
#import "FMOSTools.h"

@implementation FMContextMenuAppItem
@end

@implementation FMContextMenu

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (NSMenu *)menuForItem:(FMPanelListItem *)listItem
{
    NSMenu *menu = nil;
    
    menu = [[NSMenu alloc] initWithTitle:@"Context menu"];
    
    [menu setAutoenablesItems:NO];

    //ITEM: CHECK SIZE
    NSMenuItem *itemCheckSize = [[NSMenuItem alloc] init];
    
    [itemCheckSize setTitle:@"Check Size"];
    [itemCheckSize setTarget:self];
    [itemCheckSize setAction:@selector(actionCheckSize:)];
    [itemCheckSize setEnabled:NO];
    
    [menu addItem:itemCheckSize];

    //ITEM: OPEN WITH
    NSMenuItem *itemOpenWith = [[NSMenuItem alloc] init];
    
    [itemOpenWith setTitle:@"Open With"];
    [itemOpenWith setTarget:self];
    [itemOpenWith setAction:@selector(actionOpenWith:)];
    
    NSMenu *appsMenu = [self applicationsMenuForFileURL:listItem.url];
    
    [itemOpenWith setSubmenu:appsMenu];
    
    [menu addItem:itemOpenWith];

    //check highlighted list item
    if (listItem.isDirectory)
    {
        [itemCheckSize setEnabled:YES];
    }
    
    return menu;
}

- (void)actionOpenWith:(id)sender
{
}

- (void)actionCheckSize:(id)sender
{
    [AppDelegate.this.mainViewController actionFileView:self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    return YES;
}

- (NSMenu *)applicationsMenuForFileURL:(NSURL *)fileUrl
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Applications"];
    
    //add default app
    [menu addItem:[self menuItemForDefaultApplicationForFileURL:fileUrl]];
    
    //add other apps
    NSArray *appsURLs = [FMOSTools applicationsURLsForFileURL:fileUrl];
    
    if (appsURLs.count > 0)
    {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    for (NSURL *appUrl in appsURLs)
    {
        if (appUrl.isFileURL)
        {
            NSString *appPath = appUrl.path;
            NSString *appName = appPath.lastPathComponent.stringByDeletingPathExtension;
            
            NSMenuItem *menuItem = [self menuItemForAppURL:appUrl withName:appName andFileUrl:fileUrl];

            [menu addItem:menuItem];
        }
    }

    return menu;
}

- (NSMenuItem *)menuItemForDefaultApplicationForFileURL:(NSURL *)fileUrl
{
    NSURL *appUrl = [FMOSTools defaultApplicationURlForFileURL:fileUrl];
    
    if (appUrl == nil)
    {
        NSMenuItem *noneItem = [[NSMenuItem alloc] init];
        
        [noneItem setTitle:@"(no default application)"];
        [noneItem setEnabled:NO];
        
        return noneItem;
    }
    else
    {
        NSString *appPath = appUrl.path;
        NSString *appName = appPath.lastPathComponent.stringByDeletingPathExtension;
        
        NSString *name = [NSString stringWithFormat:@"%@ (default)", appName];
        
        return [self menuItemForAppURL:appUrl withName:name andFileUrl:fileUrl];
    }
}

- (NSString *)versionForURL:(NSURL *)url
{
    NSBundle *bundle = [NSBundle bundleWithPath:url.path];
    
    if (bundle == nil)
    {
        return @"";
    }
    
    NSDictionary *dictionary = bundle.infoDictionary;
    
    if (dictionary == nil)
    {
        return @"";
    }

    NSString *version = [dictionary valueForKey:@"CFBundleVersion"];

    if (version == nil)
    {
        return @"";
    }
    
    return version;
}

- (NSMenuItem *)menuItemForAppURL:(NSURL *)appUrl withName:(NSString *)name andFileUrl:(NSURL *)fileUrl
{
    //create event object
    FMContextMenuAppItem *requestObject = [FMContextMenuAppItem new];
    
    requestObject.fileUrl = fileUrl;
    requestObject.appUrl = appUrl;

    //create menu item
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    
    [appMenuItem setTitle:name];
    [appMenuItem setTarget:self];
    [appMenuItem setAction:@selector(openWithApplicationSelected:)];
    
    [appMenuItem setRepresentedObject:requestObject];
    
    NSImage *icon = [NSWorkspace.sharedWorkspace iconForFile:appUrl.path];
    
    [icon setSize:NSMakeSize(24, 24)];
    
    [appMenuItem setImage:icon];
    
    return appMenuItem;
}

- (void)openWithApplicationSelected:(id)sender
{
    if (![sender isKindOfClass:[NSMenuItem class]])
    {
        return;
    }

    NSMenuItem *menuItem = (NSMenuItem *)sender;
    
    FMContextMenuAppItem *requestObject = [menuItem representedObject];
    
    NSString *appPath = requestObject.appUrl.path;
    
    NSString *filePath = requestObject.fileUrl.path;
    
    [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:appPath];
}

@end
