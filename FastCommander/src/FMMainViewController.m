//
//  FMainViewController.m
//  FastCommander
//
//  Created by Piotr Zagawa on 24.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMMainViewController.h"
#import "FMWorkDirectory.h"
#import "FMSettings.h"
#import "AppDelegate.h"
#import "FMCommand.h"
#import "FMCommandManager.h"
#import "FMOSTools.h"
#import "FMFileItem.h"
#import "FMConsts.h"
#import "FMPanelListProvider.h"
#import "FMSearchPanelListProvider.h"

@implementation FMMainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
    }
    
    return self;
}

- (void)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.window setIsVisible:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window setAllowsConcurrentViewDrawing:NO];
    
    //don't release window on close
    [self.window setReleasedWhenClosed:NO];
    
    //validate toolbar buttons
    [self validateToolbarItems];
    
    //show license window
    if (FMSettings.instance.isStartMessageForNewAppVersion)
    {
        [self.licenseWindowTabView selectFirstTabViewItem:self];
        
        [self.licenseWindow setIsVisible:YES];
        
        [FMSettings.instance saveNewAppVersionForStartMessage];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
}

- (void)updateTitle
{
    NSString *title = FMConsts.instance.applicationTitle;
    
    [self.window setTitle:title];
}

- (void)updateBottomStatus:(NSString *)text
{
    if (text == nil)
    {
        self.textBottomStatus.stringValue = @"";
    }
    else
    {
        self.textBottomStatus.stringValue = text;
    }
    
    [self updateBottomLayout];
}

- (void)updateBottomInfo
{
    self.textBottomInfo.textColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:1.0];

    self.textBottomInfo.stringValue = @"COMMUNITY EDITION";
    
    [self updateBottomLayout];
}

- (void)updateBottomLayout
{
    int margin = 6;

    //reposition right textBottomInfo to container's right edge
    {
        [self.textBottomInfo sizeToFit];

        int leftPosition = self.window.frame.size.width - (self.textBottomInfo.frame.size.width + margin);
        
        NSPoint point = { leftPosition, self.textBottomInfo.frame.origin.y };
        
        [self.textBottomInfo setFrameOrigin:point];
    }

    //reposition left textBottomStatus to container's left edge
    {
        NSPoint point = { margin, self.textBottomStatus.frame.origin.y };
        
        [self.textBottomStatus setFrameOrigin:point];

        int width = self.window.frame.size.width - self.textBottomInfo.frame.size.width - (margin * 3);

        NSSize size = { width, self.textBottomStatus.frame.size.height };

        [self.textBottomStatus setFrameSize:size];
    }
    
    [self.textBottomStatus setNeedsDisplay:YES];
    [self.textBottomInfo setNeedsDisplay:YES];
}

- (BOOL)isAnyPanelFirstResponder
{
    if (self.window.firstResponder == AppDelegate.this.leftViewController.tableView)
        return YES;
    
    if (self.window.firstResponder == AppDelegate.this.rightViewController.tableView)
        return YES;
    
    return NO;
}

- (void)showAlert:(NSString *)message title:(NSString*)text
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:text];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

//TOOLBAR
-(void)validateToolbarItems
{
    for (NSToolbarItem *item in self.toolbar.items)
    {
        [self validateToolbarItem:item];
    }
}

- (NSButton *)toolbarItemButton:(NSToolbarItem *)theItem ofIdentifier:(NSString *)identifier
{
    if ([theItem.itemIdentifier isEqualToString:identifier])
    {
        if ([theItem.view isKindOfClass:NSButton.class])
        {
            return (NSButton *)theItem.view;
        }
    }

    return nil;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    //get app state
    FMSettings *settings = [FMSettings instance];

    //get buttons
    NSButton *btnHidden = [self toolbarItemButton:theItem ofIdentifier:@"FMActionHiddenFiles"];
    
    //validate buttons
    if (btnHidden != nil)
    {
        btnHidden.state = settings.isHiddenFilesVisible ? NSOnState : NSOffState;
    }
    
    return NO;
}

//MENU and toolbar actions
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    //lock menu is sheet visible
    if (self.activeOperationSheet != nil)
    {
        return NO;
    }

    if (self.activeDefaultSheet != nil)
    {
        return NO;
    }
    
    FMSettings *settings = [FMSettings instance];

    SEL action = item.action;

    //actionOpenPreferences
    if (action == @selector(actionOpenPreferences:))
    {
        return YES;
    }
    
    //actionBookmarks
    if (action == @selector(actionBookmarks:))
    {
        return YES;
    }
    
    //actionLicenseInformation
    if (action == @selector(actionLicenseInformation:))
    {
        return YES;
    }

    //actionShowHelp
    if (action == @selector(actionShowHelp:))
    {
        return YES;
    }

    //actionNewWindow
    if (action == @selector(actionNewWindow:))
    {
        return YES;
    }

    //file actions
    if ([self isAnyPanelFirstResponder])
    {
        //actionFileView
        if (action == @selector(actionFileView:))
        {
            return YES;
        }

        //actionFileEdit
        if (action == @selector(actionFileEdit:))
        {
            return YES;
        }

        //actionFileCopy
        if (action == @selector(actionFileCopy:))
        {
            return YES;
        }

        //actionFileMove
        if (action == @selector(actionFileMove:))
        {
            return YES;
        }

        //actionFileDelete
        if (action == @selector(actionFileDelete:))
        {
            return YES;
        }

        //actionFileRename
        if (action == @selector(actionFileRename:))
        {
            return YES;
        }

        //actionFileFolder
        if (action == @selector(actionFileFolder:))
        {
            return YES;
        }

        //actionCompress
        if (action == @selector(actionCompress:))
        {
            return YES;
        }

        //actionPermissions
        if (action == @selector(actionPermissions:))
        {
            return YES;
        }

        //actionOpenConsole
        if (action == @selector(actionOpenConsole:))
        {
            return YES;
        }
        
        //actionOpenFinder
        if (action == @selector(actionOpenFinder:))
        {
            return YES;
        }
        
        //actionSearch
        if (action == @selector(actionSearch:))
        {
            return YES;
        }
    }
    
    //actionShowHiddenItems
    if (action == @selector(actionShowHiddenItems:))
    {
        item.state = settings.isHiddenFilesVisible ? NSOnState : NSOffState;
        return YES;
    }
    
    return NO;
}

- (void)actionOpenPreferences:(id)sender
{
    FMCommand *command = [FMCommand showPreferences];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionFileView:(id)sender
{
    FMCommand *command = [FMCommand fileOperationView];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionFileEdit:(id)sender
{
    FMCommand *command = [FMCommand fileOperationEdit];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionFileCopy:(id)sender
{
    FMCommand *command = [FMCommand fileOperationCopy];

    if (command != nil)
    {
        command.sourceObject = self;

        [command execute];
    }
}

- (void)actionFileMove:(id)sender
{
    FMCommand *command = [FMCommand fileOperationMove];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionFileDelete:(id)sender
{
    FMCommand *command = [FMCommand fileOperationDelete];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionFileRename:(id)sender
{
    FMCommand *command = [FMCommand fileOperationRename];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionFileFolder:(id)sender
{
    FMCommand *command = [FMCommand fileOperationFolder];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionCompress:(id)sender
{
    FMCommand *command = [FMCommand fileOperationCompress];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionPermissions:(id)sender
{
    FMCommand *command = [FMCommand fileOperationPermissions];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionSearch:(id)sender
{
    FMCommand *command = [FMCommand fileOperationSearch];
    
    if (command != nil)
    {
        command.sourceObject = self;
        
        [command execute];
    }
}

- (void)actionOpenConsole:(id)sender
{
    FMPanelListProvider *provider = AppDelegate.this.sourcePanelListProvider;

    NSString *path = provider.currentPathToResource;

    FMFileItem *fileItem = [provider fileNameToFileItem:provider.currentPathToResource];
    
    if (fileItem == nil)
    {
        path = [provider.currentPathToResource stringByDeletingLastPathComponent];
    }
    else
    {
        path = provider.currentPathToResource;
    }
    
    [FMOSTools openConsole:path];
}

- (void)actionOpenFinder:(id)sender
{
    FMPanelListProvider *provider = AppDelegate.this.sourcePanelListProvider;
    
    NSString *path = provider.currentPathToResource;
    
    FMFileItem *fileItem = [provider fileNameToFileItem:provider.currentPathToResource];
    
    if (fileItem == nil)
    {
        path = [provider.currentPathToResource stringByDeletingLastPathComponent];
    }
    else
    {
        path = provider.currentPathToResource;
    }
    
    [FMOSTools openFinderDirectly:path];
}

- (void)actionBookmarks:(id)sender
{
    [FMPreferencesWindow showSheet:FMShowPreferencesTabBookmarks];
}

- (void)actionShowHiddenItems:(id)sender
{
    FMSettings *settings = [FMSettings instance];
    
    settings.isHiddenFilesVisible = !settings.isHiddenFilesVisible;
    
    //validate toolbar buttons
    [self validateToolbarItems];
    
    //reload panels
    [AppDelegate.this reloadBothPanels];
}

- (void)showPreferences
{
    [FMPreferencesWindow showSheet:FMShowPreferencesTabDefault];
}

- (void)actionCloseLicenseWindow:(id)sender
{
    [self.licenseWindow close];
}

- (void)actionShowHelp:(id)sender
{
    [NSWorkspace.sharedWorkspace openURL:FMConsts.instance.applicationHelpPageUrl];
}

- (IBAction)actionNewWindow:(id)sender
{
    [FMOSTools newAppInstance];
}

@end
