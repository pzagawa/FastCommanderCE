//
//  FMFileEditOperation.h
//  FastCommander
//
//  Created by Piotr on 21.04.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileEditOperation : FMFileOperation

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

+ (void)executeOn:(FMPanelListProvider *)provider;

@end
