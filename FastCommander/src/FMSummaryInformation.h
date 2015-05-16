//
//  FMSummaryInformation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 10.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPanelListProvider.h"

@interface FMSummaryInformation : NSObject

@property (copy) NSNumber *count;
@property (copy) NSNumber *size;

- (id)init;

+ (FMSummaryInformation *)getSummaryInformation:(FMPanelListProvider *)listProvider;
+ (FMSummaryInformation *)getSelectionInformation:(FMPanelListProvider *)listProvider;

+ (NSString *)getInformationText:(FMSummaryInformation *)information emptyText:(NSString *)emptyText;

@end
