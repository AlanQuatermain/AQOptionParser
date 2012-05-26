//
//  AQOptionRequirementGroup_Internal.h
//  AQOptionParser
//
//  Created by Jim Dovey on 2012-05-26.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQOptionRequirementGroup.h"

@class AQOption;

extern NSString * const AQOptionExclusiveRequirementMultipleMatchException;

@interface AQOptionRequirementGroup (Internal)
- (void) optionWasMatched: (AQOption *) option;
@end
