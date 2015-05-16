//
//  FMResources.h
//  FastCommander
//
//  Created by Piotr Zagawa on 21.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMResources : NSObject

@property NSImage *imageItemSelected;
@property NSImage *imageItemSelectedInverted;

@property NSImage *imageModeSource;
@property NSImage *imageModeTarget;

@property NSImage *imageOperationCopy;
@property NSImage *imageOperationMove;

@property NSShadow *shadowBtnDown;
@property NSShadow *shadowBtnUp;

+ (FMResources *)instance;

- (id)init;

@end
