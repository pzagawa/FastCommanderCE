//
//  FMFileEditOperation.m
//  FastCommander
//
//  Created by Piotr on 21.04.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "FMFileEditOperation.h"
#import "FMPanelListProvider.h"
#import "FMFileCalcSizeOperation.h"
#import "FMFileItem.h"

@implementation FMFileEditOperation

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target
{
    self = [super initWithProvider:source andTarget:target];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)run:(OnOperationFinish)onFinish
{
    //TODO: open file in editor
    //NSLog(@"running edit operation.. %@", self.filesTotalCount);
    
    [super run:onFinish];
}

- (void)runOnNewThread
{

}

- (void)finishOnUiThread
{
}

+ (void)executeOn:(FMPanelListProvider *)provider
{
    //analyze source operation
    FMFileCalcSizeOperation *calcSizeOperation = [[FMFileCalcSizeOperation alloc] initWithProvider:provider andTarget:nil];
    
    //process directories calc size if selected
    if (calcSizeOperation.inputFileItemsCount == 1)
    {
        //get selected file
        NSMutableArray *fileItems = [calcSizeOperation.sourceProvider createFileItemsForOperation:calcSizeOperation withDeepIteration:NO];
        
        if (fileItems.count == 1)
        {
            FMFileItem *fileItem = [fileItems lastObject];

            FMFileViewType fileViewType = fileItem.fileViewType;
            
            if (fileViewType == FMFileViewType_TEXT)
            {
                //Edit operation
                FMFileEditOperation *editOperation = [[FMFileEditOperation alloc] initWithProvider:provider andTarget:nil];
                
                //block after finishing
                OnOperationFinish onEditFinish = ^(FMFileOperation *operation)
                {
                };
                
                //start operation
                [editOperation run:onEditFinish];
            }
        }
    }
}

@end
