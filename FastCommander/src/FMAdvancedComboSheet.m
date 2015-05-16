//
//  FMAdvancedComboSheet.m
//  FastCommander
//
//  Created by Piotr Zagawa on 28.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMAdvancedComboSheet.h"
#import "FMCustomTypes.h"
#import "FMAdvancedCombo.h"

@implementation FMAdvancedComboSheet

- (void)keyDown:(NSEvent *)theEvent
{
    if (theEvent.keyCode == FMKeyCode_ESCAPE)
    {
        //key handling forwarded to keyUp
        return;
    }
    
    if (theEvent.keyCode == FMKeyCode_ENTER)
    {
        if (self.linkedCombo.isSelection)
        {
            //key handling forwarded to keyUp
            return;
        }
    }
 
    [super keyDown:theEvent];
}

- (void)keyUp:(NSEvent *)theEvent
{
    if (theEvent.keyCode == FMKeyCode_ESCAPE)
    {
        [self closeList];
        return;
    }
    
    if (theEvent.keyCode == FMKeyCode_ENTER)
    {
        if (self.linkedCombo.isSelection)
        {
            [self.linkedCombo acceptSelectedItem];
            
            [self closeList];
            
            return;
        }
    }
    
    [super keyUp:theEvent];
}

- (void)closeList
{
    __weak FMAdvancedCombo *combo = self.linkedCombo;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^
    {
        [combo closeList];
    }];
    
    [NSOperationQueue.mainQueue addOperation:operation];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
