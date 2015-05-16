//
//  NSColor.m
//  FastCommander
//
//  Created by Piotr Zagawa on 15.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "NSColor+Hex.h"

@implementation NSColor (Hex)

+ (NSColor *)colorWithHexRGB:(unsigned int)value
{
	unsigned int byteR = (value & 0x00ff0000) >> 16;
	unsigned int byteG = (value & 0x0000ff00) >> 8;
	unsigned int byteB = (value & 0x000000ff);
    
    float valueR = (float)byteR / (float)255;
    float valueG = (float)byteG / (float)255;
    float valueB = (float)byteB / (float)255;
    
    return [NSColor colorWithDeviceRed:valueR green:valueG blue:valueB alpha:1.0];
}

- (NSString *)hexValue
{
    NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if (rgbColor == nil)
    {
        return nil;
    }

    double floatR;
    double floatG;
    double floatB;

    [rgbColor getRed:&floatR green:&floatG blue:&floatB alpha:NULL];

    int intR;
    int intG;
    int intB;

    intR = floatR*255.99999f;
    intG = floatG*255.99999f;
    intB = floatB*255.99999f;

    NSString *hexR;
    NSString *hexG;
    NSString *hexB;
    
    hexR = [NSString stringWithFormat:@"%02x", intR];
    hexG = [NSString stringWithFormat:@"%02x", intG];
    hexB = [NSString stringWithFormat:@"%02x", intB];
    
    return [NSString stringWithFormat:@"#%@%@%@", hexR, hexG, hexB];
}

@end
