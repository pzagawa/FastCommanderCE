//
//  FMFileViewOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 18.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileViewOperation : FMFileOperation

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

+ (void)executeOn:(FMPanelListProvider *)provider;

@end
