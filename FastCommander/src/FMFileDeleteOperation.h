//
//  FMFileDeleteOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 17.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileDeleteOperation : FMFileOperation

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target;

@end
