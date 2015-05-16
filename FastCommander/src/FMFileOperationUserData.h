//
//  FMFileOperationUserData.h
//  FastCommander
//
//  Created by Piotr Zagawa on 22.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMFileOperationUserData : NSObject

@property BOOL isProcessSubdirectories;
@property NSUInteger aggregatedPermissionsToSet;
@property NSUInteger aggregatedPermissionsToClear;

@property NSString *archiveFileName;

@property NSArray *globFilePatterns;
@property (readonly) NSString *globFilePatternsText;

@property NSString *searchText;

@end
