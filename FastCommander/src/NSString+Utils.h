//
//  NSString+NSString.h
//  FastCommander
//
//  Created by Piotr Zagawa on 10.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSString *)stringByDeletingSlashPrefix;
- (NSString *)stringByDeletingSlashSuffix;

- (NSString *)stringByAppendingSlashPrefix;
- (NSString *)stringByAppendingSlashSuffix;

- (NSString *)pathExtensionLowerCase;

+ (NSArray *)getStringEncodingArray;
+ (NSArray *)getStringEncodingNamesArray;
+ (NSStringEncoding)encodingFromName:(NSString *)name;
+ (NSString *)nameFromEncoding:(NSStringEncoding)value;

- (BOOL)isValidEmail;
- (NSString *)trim;

//custom date time format: "yyyy-MM-dd HH:mm:ss"
+ (NSString *)textValueFromDate:(NSDate *)date;
- (NSDate *)dateFromTextValue;

@end
