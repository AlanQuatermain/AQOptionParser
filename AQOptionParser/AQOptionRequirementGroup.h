
//  AQOptionRequirementGroup.h AQOptionParser  Created by Jim Dovey on 2012-05-23. Copyright (c) 2012 Jim Dovey. All rights reserved.

@import Foundation; @class AQOption;

typedef NS_ENUM(NSUInteger, AQOptionRequirementType)
{
    AQOptionRequirementAtLeastOne,      /// If any member is matched, then all requirements are met.
    AQOptionRequirementExclusive        /// Only one member may be matched. An exception will result when a second matches.
};

/** @abstract This class can be used to specify that only one of a group of required options is required. By placing all the required options into this group, when one is matched, the requirement for all is satisfied, meaning that the AQOptionParser will not report a parse failure.
 */
@interface AQOptionRequirementGroup : NSObject

/**
 Creates a new option requirement group instance with the provided options.
 @param options An array containing the AQOption instances which are members of the group.
 */
- (id) initWithOptions:(NSArray*) options type: (AQOptionRequirementType) type;

/**
 Returns \c YES if the specified option is a member of the receiver,  \c NO otherwise.
 @param option The option being tested.
 */
- (BOOL) containsOption: (AQOption*) option;

/// All options which are members of the receiver.
@property (readonly) NSOrderedSet * options;

/// The type of the receiver.
@property (readonly) AQOptionRequirementType type;

/// Whether the group has been successfully matched.
@property (readonly, getter=isMatched) BOOL matched;

@end
