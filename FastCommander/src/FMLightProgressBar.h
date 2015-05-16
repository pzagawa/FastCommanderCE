//
//  FMLightProgressBar.h
//  TestCustomTopHeader
//
//  Created by Piotr Zagawa on 13.09.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMLightProgressBar : NSView

@property long long progressValue;
@property long long progressMin;
@property long long progressMax;

@property NSString *progressText;

@end
