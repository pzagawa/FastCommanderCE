//
//  FMFilePermissionsOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 21.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFilePermissionsOperation : FMFileOperation

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

+ (void)executeOn:(FMPanelListProvider *)provider;

@end
