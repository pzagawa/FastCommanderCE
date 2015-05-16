//
//  FMFileCompressOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 24.07.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileCompressOperation : FMFileOperation

@property (readonly) long fileIndex;
@property (readonly) long long totalProgressSize;
@property (readonly) int totalProgressPercentBySize;

- (id)initWithProvider:(FMPanelListProvider *)source andTarget:(FMPanelListProvider *)target;

+ (void)executeFrom:(FMPanelListProvider *)source to:(FMPanelListProvider *)target;

@end
