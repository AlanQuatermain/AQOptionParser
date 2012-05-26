//
//  AQOption_Internal.h
//  AQOptionParser
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQOption.h"
#import <getopt.h>

@class AQOptionRequirementGroup;

@interface AQOption ()
@property (nonatomic, readonly) NSString * longName;
@property (nonatomic, readonly) unichar shortName;
@end

@interface AQOption (Internal)
- (void) addedToRequirementGroup: (AQOptionRequirementGroup *) requirementGroup;
- (void) matchedWithParameter: (NSString *) parameter;
- (void) setGetoptParameters: (struct option *) option;
@end
