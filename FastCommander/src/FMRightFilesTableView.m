//
//  FMRightFilesTableView.m
//  FastCommander
//
//  Created by Piotr Zagawa on 18.04.2013.
//  Copyright (c) 2013 Piotr Zagawa. All rights reserved.
//

#import "FMRightFilesTableView.h"
#import "FMSettings.h"

@implementation FMRightFilesTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.panelSide = FMPanelSideR;
    }
    
    return self;
}

@end
