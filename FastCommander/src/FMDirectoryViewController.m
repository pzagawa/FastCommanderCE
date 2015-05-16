//
//  FMDirectoryViewController.m
//  FastCommander
//
//  Created by Piotr Zagawa on 08.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMDirectoryViewController.h"
#import "FMDirectoryViewControllerContent.h"
#import "FMSummaryInformation.h"
#import "FMResources.h"
#import "FMSelectionViewController.h"
#import "FMCommand.h"
#import "FMCommandManager.h"
#import "AppDelegate.h"
#import "FMWorkDirectory.h"
#import "FMPanelListProvider.h"
#import "FMSearchPanelListProvider.h"
#import "FMBookmarksManager.h"
#import "FMThemeManager.h"

@implementation FMDirectoryViewController
{
    NSOperationQueue *_queue;
    NSObject *_reloadLock;

    FMPanelMode _panelMode;
    
    FMPanelListProvider *_listProvider;
    
    FMFilesTableView *_tableView;
    FMDirectoryViewControllerContent *_content;
    
    NSString *_directoryText;
}

@synthesize panelSide;
@synthesize panelMode = _panelMode;

@synthesize tableView;

@synthesize operationProgress;
@synthesize editDirectory;
@synthesize textSummary;
@synthesize textVolumeName;
@synthesize btnSelection;

@synthesize selectionPopover;
@synthesize viewBottomBar;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self->_queue = [[NSOperationQueue alloc] init];
        self->_reloadLock = [[NSObject alloc] init];
        self->_content = [[FMDirectoryViewControllerContent alloc] init];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == FMThemeManager.instance)
    {
        if ([keyPath isEqualToString:@"theme"])
        {
            [self updateTheme];
            
            [self.scrollIndicator setNeedsDisplay:YES];
        }
    }
}

- (void)updateTheme
{
    FMTheme *theme = FMThemeManager.instance.theme;

    self.scrollIndicator.backgroundColor = theme.listBackground;

    self.scrollIndicator.barColor = theme.listHighlightedRow;
}

//NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
    return [_content numberOfRowsInTableView:view];
}

//NSTableViewDataSource
- (id)tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [_content tableView:view objectValueForTableColumn:tableColumn row:row];
}

- (void)initBeforeShow
{
    [self setProgressVisible:NO];
    
    self.editDirectory.eventsDelegate = self;

    self.editDirectory.parentWindow = AppDelegate.this.mainViewController.window;
    
    [self.scrollIndicator registerScrollEventsFor:self.tableClipView];
    
    //observe theme change
    [FMThemeManager.instance addObserver:self forKeyPath:@"theme" options:0 context:nil];

    [self updateTheme];
}

//WARNING: this can be called ONLY from FMPanelListProviderManager
- (void)setPanelListProvider:(FMPanelListProvider *)listProvider
{
    _listProvider = listProvider;
    
    _content.listProvider = _listProvider;
    _content.tableView = tableView;

    tableView.listProvider = _listProvider;
}

- (void)setProgressVisible:(BOOL)visible
{
    if (visible)
    {
        [operationProgress startAnimation:self];
        [operationProgress displayIfNeeded];
    }
    else
    {
        [operationProgress stopAnimation:self];
    }
}

- (void)reloadPanelWithHomeDirectoryAndParentOperation:(NSOperation *)parentOperation
{
    NSString *home = NSHomeDirectory();
    
    [self reloadPanelWithPath:home parentOperation:parentOperation andBlockAfterOperation:nil];
}

- (void)reloadPanelWithDirectoryOfController:(FMDirectoryViewController *)controller andParentOperation:(NSOperation *)parentOperation
{
    NSString *path = controller->_listProvider.currentPath;
    
    [self reloadPanelWithPath:path parentOperation:parentOperation andBlockAfterOperation:nil];
}

- (void)reloadPanelWithPath:(NSString *)path parentOperation:(NSOperation *)parentOperation andBlockAfterOperation:(OnReloadBlock)onOperationFinish;
{
    BOOL isReloadForOperation = (onOperationFinish == nil) ? NO : YES;

    __block NSString *errorMessage = nil;
    
    [self setProgressVisible:YES];
        
    [self setDirectoryText:path];
    
    if (isReloadForOperation == YES)
    {
        [tableView saveListHighlightState];
    }
    
    [self resetSummaryText];
    [self resetSelectionText];

    //then run threaded reload
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        @synchronized(_reloadLock)
        {
            @try
            {
                if (path == nil)
                {
                    [_listProvider reload];
                }
                else
                {
                    [_listProvider reload:path];
                }
            }
            @catch (NSException *exception)
            {
                errorMessage = [exception.description copy];

                [_listProvider reset];
            }
        }
    }];
    
    [operation setCompletionBlock:^
    {
        //finish task on UI thread
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [tableView reloadData];
            
            [tableView initializeSorting];
            
            [self restoreSortMode];
            
            [self setProgressVisible:NO];
            
            [self.scrollIndicator updateWith:self.tableClipView];

            [self updateSummaryText];
            [self updateSelectionText];

            //update bottom path information text
            [tableView updateBottomStatusTextWithCurrentlySelectedListItem];
            
            //restore list item highlight
            if (isReloadForOperation == YES)
            {
                //highlight item from operation
                FMReloadData *data = [[FMReloadData alloc] init];
                onOperationFinish(data);
                [tableView restoreListHighlightState:data];
            }
            else
            {
                //highlight item from provider
                [tableView selectListItemByName:[_listProvider getNameToSelect]];

                //make list first responder
                [tableView.window makeFirstResponder:tableView];
            }
            
            //process reload error
            if (errorMessage != nil)
            {
                FMMainViewController *viewController = AppDelegate.this.mainViewController;

                [viewController showAlert:errorMessage title:@"PANEL RELOAD ERROR"];
            }
        });
    }];
    
    if (parentOperation == nil)
    {
        [self updateVolumeInfo];
    }
    else
    {
        [parentOperation addDependency:operation];
    }

    [_queue addOperation:operation];
}

- (void)onAfterPanelReload
{
    //update bottom path information text
    [tableView updateBottomStatusTextWithCurrentlySelectedListItem];

    //make list first responder
    [tableView.window makeFirstResponder:tableView];
}

- (void)updateVolumeInfo
{
    //process other tasks
    [self updateVolumeName:_directoryText];
    [self updateVolumeInfo:_directoryText];
}

- (void)commandProcessFile:(FMPanelListItem *)listItem forPanelSide:(FMPanelSide)side
{
    if ([AppDelegate.this.fileProcessingResolver onFileItemSelected:listItem forPanelSide:side])
    {
        //reload panel with new provider
        NSString *path = [listItem.unifiedFilePath copy];

        [self reloadPanelWithPath:path parentOperation:nil andBlockAfterOperation:nil];
    }
}

- (void)commandDirectorySet:(FMPanelListItem *)listItem forPanelSide:(FMPanelSide)side
{
    if ([AppDelegate.this.fileProcessingResolver onFileItemSelected:listItem forPanelSide:side])
    {
        //reload panel with new provider
        NSString *path = [listItem.unifiedFilePath copy];
        
        [self reloadPanelWithPath:path parentOperation:nil andBlockAfterOperation:nil];
    }
}

- (void)commandDirectoryUp
{
    if (_listProvider.isLoadingData)
    {
        return;
    }
    
    NSString *path = [_listProvider getParentDirectory];
    
    if ([AppDelegate.this.fileProcessingResolver onPathSet:path forPanelSide:panelSide])
    {
        //reload directory
        [self reloadPanelWithPath:path parentOperation:nil andBlockAfterOperation:nil];
    }
}

- (void)commandSelectItem:(NSString *)value
{
    [self updateSelectionText];
}

- (void)commandSelectItems
{
    [self updateSelectionText];
}

- (void)commandUpdateSummary
{
    [self updateSummaryText];
}

- (void)commandShowDirectories
{
    [self.editDirectory showList];
}

- (void)resetSummaryText
{
    [textSummary setStringValue:@""];
}

NSString *DEFAULT_SELECTION_BUTTON_TEXT = @"no items selected";

- (void)resetSelectionText
{
    [self setBtnSelectionText:DEFAULT_SELECTION_BUTTON_TEXT];
}

- (void)updateSummaryText
{
    FMSummaryInformation *information = [FMSummaryInformation getSummaryInformation:_listProvider];

    NSString *text = [FMSummaryInformation getInformationText:information emptyText:@"no items"];
    
    [textSummary setStringValue:text];
}

- (void)updateSelectionText
{
    FMSummaryInformation *information = [FMSummaryInformation getSelectionInformation:_listProvider];
    
    NSString *text = [FMSummaryInformation getInformationText:information emptyText:DEFAULT_SELECTION_BUTTON_TEXT];
    
    if ([btnSelection.title isEqualToString:text] == NO)
    {
        [self setBtnSelectionText:text];
    }
}

- (void)setBtnSelectionText:(NSString *)value
{
    [btnSelection setTitle:value];
    [btnSelection sizeToFit];

    //reposition button to container's right edge
    int margin = 9;
    
    int leftPosition = viewBottomBar.frame.size.width - (btnSelection.frame.size.width + margin);
    
    NSPoint point = { leftPosition, btnSelection.frame.origin.y };
    
    [btnSelection setFrameOrigin:point];
}

- (void)updateVolumeName:(NSString *)path
{
    NSString* __block volumeName = nil;
    
    //run thread block
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        volumeName = [_listProvider getVolumeNameForPath:path];
    }];
    
    [operation setCompletionBlock:^
    {
        //finish task on UI thread
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (volumeName == nil)
            {
                volumeName = @"";
            }
            else
            {
                volumeName = volumeName.uppercaseString;
            }

            if ([textVolumeName.stringValue isEqualToString:volumeName] == NO)
            {
                [textVolumeName setStringValue:volumeName];
            }
        });
     }];
    
    [_queue addOperation:operation];
}

- (void)updateVolumeInfo:(NSString *)path
{
    NSNumber __block *totalSize = nil;
    NSNumber __block *availSize = nil;
    NSNumber __block *occupSize = nil;

    NSString __block *totalSizeText = nil;
    NSString __block *availSizeText = nil;
    NSString __block *occupSizeText = nil;

    //run thread block
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        totalSize = [_listProvider getVolumeTotalSizeForPath:path];
        availSize = [_listProvider getVolumeAvailableSizeForPath:path];
        
        if (totalSize && availSize)
        {
            occupSize = [NSNumber numberWithLongLong:(totalSize.longLongValue - availSize.longLongValue)];

            totalSizeText = [NSByteCountFormatter stringFromByteCount:totalSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
            availSizeText = [NSByteCountFormatter stringFromByteCount:availSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
            occupSizeText = [NSByteCountFormatter stringFromByteCount:occupSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
        }
    }];
    
    [operation setCompletionBlock:^
    {
        //finish task on UI thread
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSString *volumeInfo = @"";
            
            if (totalSize && availSize)
            {
                volumeInfo = [NSString stringWithFormat:@"%@ / %@", occupSizeText, totalSizeText];
                
                self.volumeInfoBar.progressMin = 0;
                self.volumeInfoBar.progressMax = totalSize.doubleValue;
                self.volumeInfoBar.progressValue = occupSize.doubleValue;
            }
            else
            {
                self.volumeInfoBar.progressMin = 0;
                self.volumeInfoBar.progressMax = 10;
                self.volumeInfoBar.progressValue = 0;
            }
            
            self.volumeInfoBar.progressText = volumeInfo;
        });
     }];
    
    [_queue addOperation:operation];
}

- (FMPanelListItem *)getHighlightedListItem
{
    return [self.tableView getSelectedPanelListItem];
}

- (void)setPanelMode:(FMPanelMode)mode
{
    self->_panelMode = mode;
    self.tableView.panelMode = mode;

    if (mode == FMPanelModeSource)
    {
        self.modeIndicator.isSource = YES;
    }

    if (mode == FMPanelModeTarget)
    {
        self.modeIndicator.isSource = NO;
    }
    
    [self.tableView setNeedsDisplay];
}

- (FMPanelMode)panelMode
{
    return _panelMode;
}

//FMAdvancedCombo delegates
- (void)onAdvancedComboListWillOpen:(FMAdvancedCombo *)combo
{
    self.editDirectory.listItems = [FMBookmarksManager bookmarksStringsForPanel:self.panelSide];
}

- (void)onAdvancedComboListDidOpen:(FMAdvancedCombo *)combo
{
    [self.btnOpenList setImage:[NSImage imageNamed:@"icon_combo_close"]];
}

- (void)onAdvancedComboListDidClose:(FMAdvancedCombo *)combo
{
    [self.btnOpenList setImage:[NSImage imageNamed:@"icon_combo_open"]];
    
    [self.tableView focusView];
}

- (void)onAdvancedComboListItemSelected:(FMAdvancedCombo *)combo item:(NSString *)itemText
{
    if (itemText != nil)
    {
        [self onDirectoryTextChange:itemText];
    }
}

- (void)onAdvancedComboTextAccepted:(FMAdvancedCombo *)combo item:(NSString *)itemText
{
    if (itemText != nil)
    {
        [self onDirectoryTextChange:itemText];
    }
}

- (void)onDirectoryTextChange:(NSString *)path
{
    if ([AppDelegate.this.fileProcessingResolver onPathSet:path forPanelSide:panelSide])
    {
        //reload directory
        [self reloadPanelWithPath:path parentOperation:nil andBlockAfterOperation:nil];
    }
    else
    {
        //restore old path
        [self setDirectoryText:_directoryText];
    }
}

- (void)setDirectoryText:(NSString *)path
{
    if (path == nil)
    {
        return;
    }
    
    self.editDirectory.stringValue = path;
    
    _directoryText = path;
}

- (void)actionOpenDirectoryList:(id)sender
{
    if (self.editDirectory.isListVisible)
    {
        [self.editDirectory closeList];
    }
    else
    {
        [self.editDirectory showList];
    }
}

//NSTableViewDelegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (notification != nil)
    {
        [self.tableView updateBottomStatusTextWithCurrentlySelectedListItem];
    }
}

- (void)commandShowSelectionPanel:(FMSelectionMode)mode withPattern:(NSString *)pattern;
{
    //first, focus panel/set as SOURCE
    [tableView focusView];

    //close alread opene popover without animation
    if (self.selectionPopover.shown)
    {
        self.selectionPopover.animates = NO;
        [self.selectionPopover close];
        self.selectionPopover.animates = YES;
    }

    FMSelectionViewController *selectionViewController = (FMSelectionViewController *)self.selectionPopover.contentViewController;

    [selectionViewController showPopover:self.selectionPopover sender:btnSelection panelSide:panelSide selectionMode:mode pattern:pattern];
}

- (void)commandUpdateItemsSelection:(FMSelectionMode)mode withPattern:(NSString *)pattern
{
    //select/unselect items by pattern
    [self.tableView processItemsSelectionCommand:mode withPattern:pattern];
    
    //update command after selection change
    [self commandSelectItems];
}

//NSTableViewDelegate
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{

}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.sortIndicator redraw];

    NSArray *descriptors = [tableView sortDescriptors];

    if (descriptors.count != 0)
    {
        NSSortDescriptor *descriptor = [descriptors objectAtIndex:0];

        self.sortIndicator.sortKey = descriptor.key;
        self.sortIndicator.isDirectionASC = descriptor.ascending;
        self.sortIndicator.isSortMode = YES;

        FMSortedListItemsBy sortBy = [self->_content sortModeFromSortDescriptor:descriptor];

        [self->_content sortPanelListItemsByColumn:sortBy directionASC:descriptor.ascending];
        
        [self.tableView reloadData];
    }
}

- (void)clearAllItemsSelection
{
    [self.tableView processAllItemsUnselectCommand];
}
    
- (void)restoreSortMode
{
    if (self.sortIndicator.isSortMode == YES)
    {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:self.sortIndicator.sortKey ascending:self.sortIndicator.isDirectionASC];

        NSArray *sortDescriptors = @[descriptor];

        [self.tableView setSortDescriptors:sortDescriptors];
    }
    else
    {
        [self.tableView setSortDescriptors:nil];
    }
}
    
- (void)resetSortMode
{
    if (self.sortIndicator.isSortMode)
    {
        self.sortIndicator.isSortMode = NO;
        
        [self.tableView setSortDescriptors:nil];
        
        if (self.panelSide == FMPanelSideL)
        {
            [AppDelegate.this.leftViewController reloadPanelWithPath:nil parentOperation:nil andBlockAfterOperation:^(FMReloadData *data){}];
        }
        
        if (self.panelSide == FMPanelSideR)
        {
            [AppDelegate.this.rightViewController reloadPanelWithPath:nil parentOperation:nil andBlockAfterOperation:^(FMReloadData *data){}];
        }
    }
}

@end
