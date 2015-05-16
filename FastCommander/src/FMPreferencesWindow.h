//
//  FMPreferencesWindow.h
//  FastCommander
//
//  Created by Piotr Zagawa on 25.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMDefaultWindow.h"

@interface FMPreferencesWindow : FMDefaultWindow <NSTableViewDataSource, NSTableViewDelegate>

typedef enum
{
    FMShowPreferencesTabDefault = 1,
    FMShowPreferencesTabBookmarks = 2,
    
} FMShowPreferencesTab;

@property FMShowPreferencesTab selectTab;

@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSTableView *tableThemes;
@property (weak) IBOutlet NSTableView *tableBookmarks;

@property (weak) IBOutlet NSTextField *editBookmarkDirectory;
@property (weak) IBOutlet NSButton *btnAddBookmark;

@property (weak) IBOutlet NSButton *checkUseTrash;

- (IBAction)actionAccept:(id)sender;
- (IBAction)actionAddBookmark:(id)sender;
- (IBAction)actionDeleteBookmark:(id)sender;
- (IBAction)actionChangeUseTrash:(id)sender;

+ (void)showSheet:(FMShowPreferencesTab)tab;
+ (void)close;

@end
