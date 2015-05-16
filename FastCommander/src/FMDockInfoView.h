//
//  FMDockInfoView.h
//  FastCommander
//
//  Created by Piotr Zagawa on 08.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMDockInfoView : NSView

@property (nonatomic) long progressValue;
@property (nonatomic) BOOL isErrorColor;

+ (FMDockInfoView *)createDockInfoView;

- (void)showDefault;
- (void)showIndeterminate;

- (void)hide;

@end
