//
//  NSString+NSString.m
//  FastCommander
//
//  Created by Piotr Zagawa on 10.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)stringByDeletingSlashPrefix
{
    if ([self hasPrefix:@"/"])
    {
        return [self substringFromIndex:1];
    }
    
    return self;
}

- (NSString *)stringByDeletingSlashSuffix
{
    if ([self hasSuffix:@"/"])
    {
        return [self substringToIndex:(self.length - 1)];
    }

    return self;
}

- (NSString *)stringByAppendingSlashPrefix
{
    if ([self hasPrefix:@"/"])
    {
        return self;
    }
    
    return [@"/" stringByAppendingString:self];
}

- (NSString *)stringByAppendingSlashSuffix
{
    if ([self hasSuffix:@"/"])
    {
        return self;
    }
    
    return [self stringByAppendingString:@"/"];
}

- (NSString *)pathExtensionLowerCase
{
    NSString *ext = self.pathExtension;
    
    if (ext != nil)
    {
        if (ext.length > 0)
        {
            return ext.lowercaseString;
        }
    }

    return nil;
}

+ (NSArray *)getStringEncodingArray
{
    static NSStringEncoding encodingList[] =
    {
        NSUTF8StringEncoding,
        NSASCIIStringEncoding,
        NSNonLossyASCIIStringEncoding,
        NSWindowsCP1251StringEncoding,
        NSWindowsCP1252StringEncoding,
        NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding,
        NSWindowsCP1250StringEncoding,
        NSISOLatin1StringEncoding,
        NSISOLatin2StringEncoding,
    };

    int size = sizeof(encodingList)/sizeof(NSStringEncoding);
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:size];
    
    for (int index = 0; index < size; index++)
    {
        NSInteger encodingValue = encodingList[index];
        
        [list addObject:[NSNumber numberWithInteger:encodingValue]];
    }
    
    return list;
}

+ (NSArray *)getStringEncodingNamesArray
{
    NSArray *encodingList = @
    [
        @"UTF-8",
        @"Strict ASCII",
        @"Verbose ASCII",
        @"Windows-1251",
        @"Windows-1252",
        @"Windows-1253",
        @"Windows-1254",
        @"Windows-1250",
        @"ISO Latin 1",
        @"ISO Latin 2",
    ];
    
    return encodingList;
}

+ (NSStringEncoding)encodingFromName:(NSString *)name
{
    NSArray *encodingItems = [NSString getStringEncodingArray];
    NSArray *encodingNames = [NSString getStringEncodingNamesArray];
    
    for (int index = 0; index < encodingItems.count; index++)
    {
        NSStringEncoding encoding = [encodingItems[index] integerValue];
        
        NSString* encodingName = encodingNames[index];
        
        if ([encodingName isEqualToString:name])
        {
            return encoding;
        }
    }
    
    return 0;
}

+ (NSString *)nameFromEncoding:(NSStringEncoding)value
{
    NSArray *encodingItems = [NSString getStringEncodingArray];
    NSArray *encodingNames = [NSString getStringEncodingNamesArray];
    
    for (int index = 0; index < encodingItems.count; index++)
    {
        NSStringEncoding encoding = [encodingItems[index] integerValue];
        
        NSString* encodingName = encodingNames[index];
        
        if (encoding == value)
        {
            return encodingName;
        }
    }

    return 0;
}

- (BOOL)isValidEmail
{
    if (self == nil)
    {
        return NO;
    }
    
    NSRange range = [self rangeOfString:@"@"];
    
    if (range.location == NSNotFound)
    {
        return NO;
    }
    
    NSArray *items = [self componentsSeparatedByString:@"@"];
    
    if (items.count < 2)
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static NSString *DATE_TIME_FORMAT = @"yyyy-MM-dd HH:mm:ss";

+ (NSString *)textValueFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:DATE_TIME_FORMAT];
    
    return [formatter stringFromDate:date];
}

//returns nil if string bad format
- (NSDate *)dateFromTextValue
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:DATE_TIME_FORMAT];
    
    return [formatter dateFromString:self];
}

@end
