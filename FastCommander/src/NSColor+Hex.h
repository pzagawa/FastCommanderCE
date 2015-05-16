//
//  NSColor.h
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSColor (Hex)

+ (NSColor *)colorWithHexRGB:(unsigned int)value;

- (NSString *)hexValue;

@end
