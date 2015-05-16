//
//  FMFileOperationUserData.m
//  FastCommander
//
//  Created by Piotr Zagawa on 22.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperationUserData.h"
#import "NSString+Utils.h"

@implementation FMFileOperationUserData
{
    NSArray *_globFilePatterns;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.isProcessSubdirectories = NO;
        self.aggregatedPermissionsToSet = 0;
        self.aggregatedPermissionsToClear = 0;
        
        self.archiveFileName = @"";
        
        self.globFilePatterns = @[];
        self.searchText = @"";
    }
    
    return self;
}

- (NSArray *)globFilePatterns
{
    return _globFilePatterns;
}

- (void)setGlobFilePatterns:(NSArray *)globFilePatterns
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.globFilePatterns.count];

    for (NSString *item in globFilePatterns)
    {
        NSString *newItem = [item copy];
        
        if ([item hasPrefix:@"*"] == NO)
        {
            newItem = [NSString stringWithFormat:@"*%@", newItem];
        }

        if ([item hasSuffix:@"*"] == NO)
        {
            newItem = [NSString stringWithFormat:@"%@*", newItem];
        }
        
        [list addObject:newItem];
    }
    
    self->_globFilePatterns = [NSArray arrayWithArray:list];
}

- (NSString *)globFilePatternsText
{
    if (self.globFilePatterns == nil)
    {
        return @"";
    }

    NSMutableString *list = [[NSMutableString alloc] initWithCapacity:self.globFilePatterns.count];

    for (NSString *item in self.globFilePatterns)
    {
        [list appendString:item];
        [list appendString:@" "];
    }

    return list.trim;
}

@end
