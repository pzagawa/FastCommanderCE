//
//  FMOperationPermissionsWindow.m
//  FastCommander
//
//  Created by Piotr Zagawa on 21.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMOperationPermissionsWindow.h"
#import "FMFileOperation.h"
#import "AppDelegate.h"
#import "FMPosixPermissions.h"
#import "FMFileOperationUserData.h"
#import "FMDockInfoView.h"

@implementation FMOperationPermissionsWindow

- (void)actionCancel:(id)sender
{
    if (self.fileOperation.isInProgress)
    {
        [super actionCancel:sender];
    }
    else
    {
        [self closeSheet];
    }
}

- (void)actionAccept:(id)sender
{
    [self enableProgress:YES];
    
    [super actionAccept:sender];
}

- (void)actionChangeBit:(id)sender
{
    NSUInteger bitsToSet = [self bitsToSetFromPermissionsState];
    
    self.textOctal.stringValue = [FMPosixPermissions octalTextFromBits:bitsToSet];
}

- (void)actionChangeOctalText:(id)sender
{
    NSUInteger bitsToSet = [FMPosixPermissions bitsFromOctalText:self.textOctal.stringValue];

    NSUInteger bitsToClear = POSIX_BITS_ALL_SET;
    
    [self updatePermissionsStateWithBitsToSet:bitsToSet andBitsToClear:bitsToClear];
}

- (void)enableProgress:(BOOL)enabled
{
    if (enabled)
    {
        [self.operationProgress startAnimation:self];
        [self.operationProgress displayIfNeeded];
    }
    else
    {
        [self.operationProgress stopAnimation:self];
    }
}

//FMFileOperationProgress protocol
- (void)reset
{
    [super reset];
    
    self.textTitle.stringValue = @"SETTING FILES PERMISSIONS";
    
    self.textTotalFilesInfo.stringValue = @"";
    self.textTotalDirectoriesInfo.stringValue = @"";
    
    self.checkUserR.state = NSMixedState;
    self.checkUserW.state = NSMixedState;
    self.checkUserX.state = NSMixedState;
        
    self.checkGroupR.state = NSMixedState;
    self.checkGroupW.state = NSMixedState;
    self.checkGroupX.state = NSMixedState;
        
    self.checkOtherR.state = NSMixedState;
    self.checkOtherW.state = NSMixedState;
    self.checkOtherX.state = NSMixedState;
    
    self.textOctal.stringValue = @"000";
    
    self.checkProcessSubdirectories.state = NSOffState;
    
    [self enableProgress:NO];
}

- (NSString *)acceptTitle
{
    return @"Set";
}

- (void)beforeStart
{
    [super beforeStart];
    
    self.textTotalFilesInfo.stringValue = [NSString stringWithFormat:@"%lu", self.fileOperation.filesTotalCount.integerValue];
    self.textTotalDirectoriesInfo.stringValue = [NSString stringWithFormat:@"%lu", self.fileOperation.directoriesTotalCount.integerValue];
}

- (void)itemStart:(FMFileItem *)fileItem
{
    [super itemStart:fileItem];
    
}

- (void)updateUserInterfaceStateWithUserData:(FMFileOperationUserData *)userData
{
    [super updateUserInterfaceStateWithUserData:userData];

    NSUInteger bitsToSet = userData.aggregatedPermissionsToSet;
    NSUInteger bitsToClear = userData.aggregatedPermissionsToClear;
    
    [self updatePermissionsStateWithBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    
    self.textOctal.stringValue = [FMPosixPermissions octalTextFromBits:bitsToSet];
}

- (void)updatePermissionsStateWithBitsToSet:(NSUInteger)bitsToSet andBitsToClear:(NSUInteger)bitsToClear
{
    self.checkUserR.state = [FMPosixPermissions state:POSIX_BIT_USER_R withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    self.checkUserW.state = [FMPosixPermissions state:POSIX_BIT_USER_W withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    self.checkUserX.state = [FMPosixPermissions state:POSIX_BIT_USER_X withBitsToSet:bitsToSet andBitsToClear:bitsToClear];

    self.checkGroupR.state = [FMPosixPermissions state:POSIX_BIT_GRUP_R withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    self.checkGroupW.state = [FMPosixPermissions state:POSIX_BIT_GRUP_W withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    self.checkGroupX.state = [FMPosixPermissions state:POSIX_BIT_GRUP_X withBitsToSet:bitsToSet andBitsToClear:bitsToClear];

    self.checkOtherR.state = [FMPosixPermissions state:POSIX_BIT_OTHR_R withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    self.checkOtherW.state = [FMPosixPermissions state:POSIX_BIT_OTHR_W withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
    self.checkOtherX.state = [FMPosixPermissions state:POSIX_BIT_OTHR_X withBitsToSet:bitsToSet andBitsToClear:bitsToClear];
}

- (NSCellStateValue)permissionsState:(NSUInteger)mask withBitsToSet:(NSUInteger)bitsToSet andBitsToClear:(NSUInteger)bitsToClear
{
    if ((bitsToSet & mask) > 0)
    {
        return NSOnState;
    }
    
    if ((bitsToClear & mask) > 0)
    {
        return NSOffState;
    }
    
    return NSMixedState;
}

- (NSUInteger)bitsFromPermissionsStateEqualTo:(NSCellStateValue)state
{
    NSUInteger value = 0;
    
    value |= (self.checkUserR.state == state) ? POSIX_BIT_USER_R : 0;
    value |= (self.checkUserW.state == state) ? POSIX_BIT_USER_W : 0;
    value |= (self.checkUserX.state == state) ? POSIX_BIT_USER_X : 0;
    
    value |= (self.checkGroupR.state == state) ? POSIX_BIT_GRUP_R : 0;
    value |= (self.checkGroupW.state == state) ? POSIX_BIT_GRUP_W : 0;
    value |= (self.checkGroupX.state == state) ? POSIX_BIT_GRUP_X : 0;
    
    value |= (self.checkOtherR.state == state) ? POSIX_BIT_OTHR_R : 0;
    value |= (self.checkOtherW.state == state) ? POSIX_BIT_OTHR_W : 0;
    value |= (self.checkOtherX.state == state) ? POSIX_BIT_OTHR_X : 0;
    
    return value;
}

- (NSUInteger)bitsToSetFromPermissionsState
{
    return [self bitsFromPermissionsStateEqualTo:NSOnState];
}

- (NSUInteger)bitsToClearFromPermissionsState
{
    return [self bitsFromPermissionsStateEqualTo:NSOffState];
}

- (void)updateUserDataWithUserInterfaceState:(FMFileOperationUserData *)userData
{
    [super updateUserDataWithUserInterfaceState:userData];

    //get process subdirs check state
    if (self.checkProcessSubdirectories.state == NSOnState)
    {
        userData.isProcessSubdirectories = YES;
    }
    
    userData.aggregatedPermissionsToSet = [self bitsToSetFromPermissionsState];
    userData.aggregatedPermissionsToClear = [self bitsToClearFromPermissionsState];
    
    [self.fileOperation.dockInfoView showIndeterminate];
}

- (void)afterFinish
{
}

- (void)onOperationPause:(BOOL)pauseState
{
    
}

- (void)closeSheet
{
    [super closeSheet];
    
    [self.fileOperation.dockInfoView hide];
}

+ (void)showSheet:(FMFileOperation *)fileOperation
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationPermissions;
    
    [super showSheetWith:window forOperation:fileOperation];
}

+ (void)close
{
    FMOperationWindow *window = AppDelegate.this.mainViewController.sheetOperationPermissions;
    
    [window closeSheet];
}

@end
