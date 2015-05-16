//
//  FMAdvancedComboEvents.h
//  FastCommander
//
//  Created by Piotr Zagawa on 28.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMAdvancedCombo;

@protocol FMAdvancedComboEvents <NSObject>

- (void)onAdvancedComboListWillOpen:(FMAdvancedCombo *)combo;
- (void)onAdvancedComboListDidOpen:(FMAdvancedCombo *)combo;
- (void)onAdvancedComboListDidClose:(FMAdvancedCombo *)combo;
- (void)onAdvancedComboListItemSelected:(FMAdvancedCombo *)combo item:(NSString *)itemText;
- (void)onAdvancedComboTextAccepted:(FMAdvancedCombo *)combo item:(NSString *)itemText;

@end
