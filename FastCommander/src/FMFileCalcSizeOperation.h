//
//  FMFileCalcSizeOperation.h
//  FastCommander
//
//  Created by Piotr Zagawa on 03.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMFileOperation.h"

@interface FMFileCalcSizeOperation : FMFileOperation

+ (void)executeOn:(FMPanelListProvider *)provider andFinishWithBlock:(OnOperationFinish)onFinish;

@end
