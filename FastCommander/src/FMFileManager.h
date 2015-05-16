//
//  FileManager.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.03.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMWorkDirectory.h"

@interface FMFileManager : NSObject

@property FMWorkDirectory *directory;
@property NSArray *urlItems;
@property BOOL isLoadingData;

- (id)init;
- (void)reset;
- (void)reload;
- (void)reload:(NSString *)value;

- (NSString *)getVolumeNameForPath:(NSString *)value;
- (NSNumber *)getVolumeTotalSizeForPath:(NSString *)value;
- (NSNumber *)getVolumeAvailableSizeForPath:(NSString *)value;

@end
