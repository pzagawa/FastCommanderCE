//
//  FMSummaryInformation.m
//  FastCommander
//
//  Created by Piotr Zagawa on 10.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMSummaryInformation.h"
#import "FMPanelListItem.h"

@implementation FMSummaryInformation

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.count = [NSNumber numberWithLongLong:0];
        self.size = [NSNumber numberWithLongLong:0];
    }
    
    return self;
}

+ (FMSummaryInformation *)getSummaryInformation:(FMPanelListProvider *)listProvider
{
    FMSummaryInformation *information = [FMSummaryInformation new];
    
    NSInteger count = 0;
    NSInteger size = 0;
    
    NSMutableArray *items = [listProvider getListItems];
    
    if (items)
    {
        for (int index = 0; index < items.count; index++)
        {
            FMPanelListItem *listItem = [items objectAtIndex:index];
            
            if (listItem.itemType == FMPanelListItemTypeDefault)
            {
                count++;
                size += listItem.fileSize.longLongValue;
            }
        }
    }
    
    information.count = [NSNumber numberWithLongLong:count];
    information.size = [NSNumber numberWithLongLong:size];
    
    return information;
}

+ (FMSummaryInformation *)getSelectionInformation:(FMPanelListProvider *)listProvider
{
    FMSummaryInformation *information = [FMSummaryInformation new];
    
    NSInteger count = 0;
    NSInteger size = 0;
    
    NSMutableArray *items = [listProvider getListItems];
    
    if (items)
    {
        for (int index = 0; index < items.count; index++)
        {
            FMPanelListItem *listItem = [items objectAtIndex:index];
            
            if (listItem.isSelected)
            {
                count++;
                size += listItem.fileSize.longLongValue;
            }
        }
    }
    
    information.count = [NSNumber numberWithLongLong:count];
    information.size = [NSNumber numberWithLongLong:size];
    
    return information;
}

+ (NSString *)getInformationText:(FMSummaryInformation *)information emptyText:(NSString *)emptyText
{
    NSString *text = @"...";
    
    NSString *textItems = (information.count.longLongValue == 1) ? @"item" : @"items";

    if (information.count.longLongValue == 0)
    {
        text = emptyText;
    }
    else
    {
        if (information.size.longLongValue == 0)
        {
            text = [NSString stringWithFormat:@"%ld %@", information.count.integerValue, textItems];
        }
        else
        {
            NSString *sizeText = [NSByteCountFormatter stringFromByteCount:information.size.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
            
            text = [NSString stringWithFormat:@"%ld %@ • %@", information.count.integerValue, textItems, sizeText];
        }
    }
    
    return text;
}

@end
