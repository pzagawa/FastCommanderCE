//
//  FMFileSearchOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 19.08.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileSearchOperation : FMFileOperation

@property BOOL cancelAndShow;

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

+ (void)executeOn:(FMPanelListProvider *)provider;

@end
