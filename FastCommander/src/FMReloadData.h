//
//  FMReloadData.h
//  FastCommander
//
//  Created by Piotr Zagawa on 25.06.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMReloadData : NSObject

typedef void (^OnReloadBlock)(FMReloadData *data);

@property (copy) NSString *nameToSelectOnList;

@end
