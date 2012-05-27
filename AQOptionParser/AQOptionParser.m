//
//  AQOptionParser.m
//  AQOptionParser
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQOptionParser.h"
#import "AQOptionRequirementGroup.h"
#import "AQOption_Internal.h"
#import <sys/ioctl.h>

NSString * const AQOptionErrorDomain = @"AQOptionErrorDomain";

@implementation AQOptionParser
{
    NSMutableOrderedSet *   _options;
    NSMutableOrderedSet *   _optionGroups;
    NSMutableSet *          _allOptions;
}

- (id) init
{
    self = [super init];
    if ( self == nil )
        return ( self );
    
    _options = [NSMutableOrderedSet new];
    _optionGroups = [NSMutableOrderedSet new];
    _allOptions = [NSMutableSet new];
    
    return ( self );
}

- (void) addOption: (AQOption *) option
{
    [_options addObject: option];
    [_allOptions addObject: option];
}

- (void) addOptions: (NSArray *) options
{
    [_options addObjectsFromArray: options];
    [_allOptions addObjectsFromArray: options];
}

- (void) addOptionGroup: (AQOptionRequirementGroup *) group
{
    [_optionGroups addObject: group];
    [_allOptions unionSet: [group.options set]];
    [_options minusOrderedSet: group.options];
}

- (NSString *) localizedUsageInformationWithColumnWidth: (NSUInteger) columnWidth
{
    NSString * oneOf = NSLocalizedString(@"One of:", @"Exclusive group usage info header");
    NSString * anyOf = NSLocalizedString(@"At least one of:", @"Permissive group usage info header");
    
    NSMutableString * builder = [NSMutableString new];
    for ( AQOptionRequirementGroup * group in _optionGroups )
    {
        [builder appendFormat: @"  %@\n", (group.type == AQOptionRequirementAtLeastOne ? anyOf : oneOf)];
        for ( AQOption * option in group.options )
        {
            [builder appendFormat: @"    %@\n", [option localizedUsageForOutputLineWidth: (columnWidth == 0 ? 0: columnWidth-4)]];
        }
    }
    
    for ( AQOption * option in _options )
    {
        [builder appendFormat: @"  %@\n", [option localizedUsageForOutputLineWidth: (columnWidth == 0 ? 0 : columnWidth-2)]];
    }
    
    return ( [builder copy] );
}

- (void) writeLocalizedUsageInformationToFile: (NSFileHandle *) fileHandle
{
    struct winsize ws = {0};
    if ( isatty([fileHandle fileDescriptor]) == 0 || ioctl([fileHandle fileDescriptor], TIOCGWINSZ, &ws) != 0 )
    {
        [fileHandle writeData: [[self localizedUsageInformationWithColumnWidth: 0] dataUsingEncoding: NSUTF8StringEncoding]];
        return;
    }
    
    [fileHandle writeData: [[self localizedUsageInformationWithColumnWidth: ws.ws_col] dataUsingEncoding: NSUTF8StringEncoding]];
}

- (BOOL) parseCommandLineArguments: (char *const []) argv count: (int) argc nextArgumentIndex: (int *) nextIndex error: (NSError *__autoreleasing *) error
{
    struct option nilOption = {NULL, 0, NULL, 0};
    struct option * options = malloc(([_allOptions count]+1) * sizeof(struct option));
    char * shortOptions = malloc([_allOptions count]*2+1);
    
    NSMapTable * lookup = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, [_allOptions count]);
    
    int i = 0;
    int c = 0;
    for ( AQOption * option in _allOptions )
    {
        [option setGetoptParameters: &options[i++]];
        NSMapInsert(lookup, (const void *)option.shortName, (__bridge void *)option);
        shortOptions[c++] = (char)option.shortName;
        if ( option.optional == NO )
            shortOptions[c++] = ':';
    }
    
    options[i] = nilOption;
    shortOptions[c] = '\0';
    
    // parse and handle
    @try
    {
        int ch = 0;
        while ( (ch = getopt_long(argc, argv, shortOptions, options, NULL)) != -1 )
        {
            switch ( ch )
            {
                case '?':
                    [NSException raise: NSInvalidArgumentException format: @"Unknown option: %s", argv[optind]];
                    break;
                case ':':
                    [NSException raise: NSInvalidArgumentException format: @"Expected parameter to argument: %s", argv[optind]];
                    break;
                default:
                    break;
            }
            
            AQOption * option = (__bridge AQOption *)NSMapGet(lookup, (const void *)ch);
            if ( option == nil )
                continue;        // er...?
            
            NSString * parameter = nil;
            if ( optarg != nil )
                parameter = [NSString stringWithUTF8String: optarg];
            [option matchedWithParameter: parameter];   // may throw for exclusive group members
        }
    }
    @catch (NSException * e)
    {
        if ( error != NULL )
        {
            // craft an NSError from the exception
            NSError * err = [NSError errorWithDomain: AQOptionErrorDomain code: 1 userInfo: @{ @"Exception" : e }];
            *error = err;
        }
        
        return ( NO );
    }
    @finally
    {
        if ( nextIndex != NULL )
            *nextIndex = optind;
        free(options);
        free(shortOptions);
        NSFreeMapTable(lookup);
    }
    
    // see if we matched all requirements
    for ( AQOption * option in _options )
    {
        if ( option.optional == NO && option.matched == NO )
        {
            if ( error != NULL )
            {
                NSDictionary * info = @{
                    NSLocalizedDescriptionKey : NSLocalizedString(@"Required option not specified", @"Missing Required Option error description"),
                    @"Option" : option
                };
                *error = [NSError errorWithDomain: AQOptionErrorDomain code: 2 userInfo: info];
            }
            
            return ( NO );
        }
    }
    
    for ( AQOptionRequirementGroup * group in _optionGroups )
    {
        if ( group.matched == NO )
        {
            if ( error != NULL )
            {
                NSDictionary * info = @{
                    NSLocalizedDescriptionKey : NSLocalizedString(@"Member of required option group not specified", @"Missing Required Option From Group error description"),
                    @"OptionGroup" : group
                };
                *error = [NSError errorWithDomain: AQOptionErrorDomain code: 2 userInfo: info];
            }
        }
    }
    
    return ( YES );
}

@end
