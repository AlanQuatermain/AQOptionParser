//
//  AQOptionRequirementGroup.m
//  AQOptionParser
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQOptionRequirementGroup.h"
#import "AQOption_Internal.h"
#import "AQOptionRequirementGroup_Internal.h"

NSString * const AQOptionExclusiveRequirementMultipleMatchException = @"AQOptionExclusiveRequirementMultipleMatchException";

@implementation AQOptionRequirementGroup
{
    NSOrderedSet *          _options;
    AQOptionRequirementType _type;
    AQOption * __weak       _firstMatched;
}

@synthesize options=_options, type=_type;

- (id) initWithOptions: (NSArray *) options type: (AQOptionRequirementType) type
{
    self = [super init];
    if ( self == nil )
        return ( nil );
    
    _type = type;
    _options = [NSOrderedSet orderedSetWithArray: options];
    for ( AQOption * option in _options )
    {
        [option addedToRequirementGroup: self];
    }
    
    return ( self );
}

- (BOOL) containsOption: (AQOption *) option
{
    return ( [_options containsObject: option] );
}

- (BOOL) isMatched
{
    return ( _firstMatched != nil );
}

- (NSString *) description
{
    return ( [NSString stringWithFormat: @"%@: %s, options=%@", [super description], (_type == AQOptionRequirementAtLeastOne ? "any" : "exclusive"), _options] );
}

- (NSUInteger) hash
{
    return ( [_options hash] );
}

@end

@implementation AQOptionRequirementGroup (Internal)

- (void) optionWasMatched: (AQOption *) option
{
    if ( _type == AQOptionRequirementExclusive && _firstMatched != option )
    {
        // already matched something else, so the exclusive requirement fails
        [NSException raise: AQOptionExclusiveRequirementMultipleMatchException format: @"Matched mutually exclusive options %@ and %@", _firstMatched, option];
        return;
    }
    
    _firstMatched = option;
}

@end
