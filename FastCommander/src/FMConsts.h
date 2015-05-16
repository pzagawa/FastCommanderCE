//
//  FMConsts.h
//  FastCommander
//
//  Created by Piotr Zagawa on 17.05.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMConsts : NSObject

@property (readonly) BOOL isCopyrightUnchanged;

@property (readonly) NSString *applicationTitle;
@property (readonly) NSString *applicationTitleWithVersion;
@property (readonly) NSString *applicationFullTitle;

@property (readonly) NSString *applicationAuthor;
@property (readonly) NSString *copyrightText;

@property (readonly) NSString *applicationHomepage;
@property (readonly) NSURL *applicationHomepageUrl;

@property (readonly) NSString *applicationHelpPage;
@property (readonly) NSURL *applicationHelpPageUrl;

+ (FMConsts *)instance;

- (id)init;

@end
