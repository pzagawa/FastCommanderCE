//
//  FMFileOperationValidator.m
//  FastCommander
//
//  Created by Piotr Zagawa on 01.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperationValidator.h"
#import "AppDelegate.h"
#import "FMCommand.h"

@implementation FMFileOperationValidator

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.sourceProvider = AppDelegate.this.sourcePanelListProvider;
        self.targetProvider = AppDelegate.this.targetPanelListProvider;
    }
    
    return self;
}

- (BOOL)sourceProviderSupportsCommand:(FMCommandId)commandId
{
    return ([self.sourceProvider supportedOperationCommand:commandId withMode:FMPanelModeSource]);
}

- (BOOL)targetProviderSupportsCommand:(FMCommandId)commandId
{
    return ([self.targetProvider supportedOperationCommand:commandId withMode:FMPanelModeTarget]);
}

- (NSString *)sourceNotSupportedMessage:(NSString *)commandName
{
    return [NSString stringWithFormat:@"Source %@ does not support %@ operation.", self.sourceProvider.providerName, commandName];
}

- (NSString *)targetNotSupportedMessage:(NSString *)commandName
{
    return [NSString stringWithFormat:@"Target %@ does not support %@ operation.", self.targetProvider.providerName, commandName];
}

- (NSString *)validateProviders:(FMCommand *)command
{
    NSMutableString *message = [[NSMutableString alloc] init];
        
    if (command.isSinglePanel)
    {
        //check for SINGLE PANEL operation
        if ([self sourceProviderSupportsCommand:command.commandId] == NO)
        {
            [message appendString:[self sourceNotSupportedMessage:command.commandName]];
        }
    }
    else
    {
        //checks for DUAL PANEL operation
        if ([self sourceProviderSupportsCommand:command.commandId] == NO)
        {
            [message appendString:[self sourceNotSupportedMessage:command.commandName]];
        }

        if ([self targetProviderSupportsCommand:command.commandId] == NO)
        {
            [message appendString:[self targetNotSupportedMessage:command.commandName]];
        }        
    }
    
    return message;
}

- (BOOL)isSourceSelection
{
    //check if any list item is selected
    if (self.sourceProvider.isSelection)
    {
        return YES;
    }
    
    //no list item is selected, get highlighted item
    FMDirectoryViewController *viewController = AppDelegate.this.sourceViewController;
    
    FMPanelListItem *listItem = [viewController.tableView getSelectedPanelListItem];

    //check if highlighted item is a default panel list item
    if (listItem != nil)
    {
        if (listItem.itemType == FMPanelListItemTypeDefault)
        {
            return YES;
        }
    }

    return NO;
}

//called BEFORE dispatching FMCommand object
- (BOOL)validate:(FMCommand *)command
{
    NSString *validationMessage = @"Operation command not found";
    
    //check file operation command object
    if (command != nil)
    {
        //check if user focused on any panel
        if ([AppDelegate.this.mainViewController isAnyPanelFirstResponder] == NO)
        {
            //silently skip operation, no alert message
            return NO;
        }
        
        //check source selection for command
        if (command.isSelectionRequired)
        {
            if ([self isSourceSelection] == NO)
            {
                //silently skip operation, no alert message
                return NO;
            }        
        }

        //validate panel list providers
        validationMessage = [self validateProviders:command];
        
        //no return message, validation passed
        if ([validationMessage length] == 0)
        {
            return YES;
        }
    }
    
    //show alert
    [self showAlert:validationMessage];
    
    return NO;
}

- (void)showAlert:(NSString *)message
{
    FMCommand* command = [FMCommand showAlert:message withTitle:@"Unsupported operation"];
    command.sourceObject = self;
    [command execute];    
}

@end
