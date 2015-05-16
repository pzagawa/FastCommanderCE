//
//  FMMainViewController.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMConsts.h"
#import "FMCustomTypes.h"
#import "FMOperationWindow.h"
#import "FMPanelListProvider.h"
#import "FMOperationAnalyzingWindow.h"
#import "FMOperationCopyWindow.h"
#import "FMOperationDeleteWindow.h"
#import "FMOperationTextViewWindow.h"
#import "FMOperationImageViewWindow.h"
#import "FMOperationRenameWindow.h"
#import "FMOperationFolderWindow.h"
#import "FMOperationPermissionsWindow.h"
#import "FMOperationCompressWindow.h"
#import "FMOperationSearchWindow.h"
#import "FMPreferencesWindow.h"

@interface FMMainViewController : NSViewController <NSWindowDelegate>

//main window
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSToolbar *toolbar;

@property (weak) IBOutlet NSTextField *textBottomStatus;
@property (weak) IBOutlet NSTextField *textBottomInfo;

//sheet operation windows
@property (weak) IBOutlet FMOperationAnalyzingWindow *sheetOperationAnalyzing;
@property (weak) IBOutlet FMOperationCopyWindow *sheetOperationCopy;
@property (weak) IBOutlet FMOperationDeleteWindow *sheetOperationDelete;
@property (weak) IBOutlet FMOperationTextViewWindow *sheetOperationTextView;
@property (weak) IBOutlet FMOperationImageViewWindow *sheetOperationImageView;
@property (weak) IBOutlet FMOperationRenameWindow *sheetOperationRename;
@property (weak) IBOutlet FMOperationFolderWindow *sheetOperationFolder;
@property (weak) IBOutlet FMOperationPermissionsWindow *sheetOperationPermissions;
@property (weak) IBOutlet FMOperationCompressWindow *sheetOperationCompress;
@property (weak) IBOutlet FMOperationSearchWindow *sheetOperationSearch;

@property (weak) FMOperationWindow *activeOperationSheet;
@property (weak) FMFileOperation *activeFileOperation;

//sheet default windows
@property (weak) IBOutlet FMPreferencesWindow *sheetPreferences;

@property (weak) FMDefaultWindow *activeDefaultSheet;

//methods
- (void)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)notification;

- (void)updateTitle;
- (void)updateBottomStatus:(NSString *)text;
- (void)updateBottomInfo;

- (BOOL)isAnyPanelFirstResponder;

- (void)showAlert:(NSString *)message title:(NSString*)text;
- (void)showPreferences;

//menu and toolbar validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
- (BOOL)validateMenuItem:(NSMenuItem *)item;

//menu and toolbar actions
- (IBAction)actionOpenPreferences:(id)sender;

- (IBAction)actionFileView:(id)sender;
- (IBAction)actionFileEdit:(id)sender;
- (IBAction)actionFileCopy:(id)sender;
- (IBAction)actionFileMove:(id)sender;
- (IBAction)actionFileDelete:(id)sender;
- (IBAction)actionFileRename:(id)sender;
- (IBAction)actionFileFolder:(id)sender;

- (IBAction)actionCompress:(id)sender;
- (IBAction)actionPermissions:(id)sender;

- (IBAction)actionSearch:(id)sender;

- (IBAction)actionOpenConsole:(id)sender;
- (IBAction)actionOpenFinder:(id)sender;

- (IBAction)actionBookmarks:(id)sender;

- (IBAction)actionShowHiddenItems:(id)sender;

//License Window
@property (unsafe_unretained) IBOutlet NSPanel *licenseWindow;
@property (weak) IBOutlet NSTabView *licenseWindowTabView;

- (IBAction)actionCloseLicenseWindow:(id)sender;

- (IBAction)actionShowHelp:(id)sender;

- (IBAction)actionNewWindow:(id)sender;

@end
