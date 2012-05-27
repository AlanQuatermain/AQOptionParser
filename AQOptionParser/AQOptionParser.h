//
//  AQOptionParser.h
//  AQOptionParser
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQOption.h"
#import "AQOptionRequirementGroup.h"

/// The NSError domain for the option handling API.
extern NSString * const AQOptionErrorDomain;

/**
 AQOptionParser provides a simple interface for defining and parsing command-line
 arguments.
 
 Options are specified using the AQOption class, and groups of options can be specified
 using the AQOptionRequirementGroup class. Groups can require that only one member
 be matched or that at least one must match.
 */
@interface AQOptionParser : NSObject

/**
 Adds a single option to the receiver. If an option with the same long name is already
 present then it is replaced by the new value.
 @param option The new option.
 */
- (void) addOption: (AQOption *) option;

/**
 Adds a set of options to the receiver. If any options in the supplied list use the same
 long name as an existing option, that existing option is replaced.
 @param options The new options.
 */
- (void) addOptions: (NSArray *) options;

/**
 Adds a group of options to the receiver. The group specifies that either any of the
 group's members must be matched, or no more than one must match.
 
 The options within the group are added to the receiver in a manner similar to the 
 addOptions: method.
 */
- (void) addOptionGroup: (AQOptionRequirementGroup *) group;

/**
 This method runs the actual option processing core.
 
 As the argument names suggest, it is expected to be passed the `argc` and `argv` parameters
 directly sent to the `main()` function of the application. If some non-option arguments are
 expected, the `nextIndex` argument can be provided to receive the index of the first 
 non-option value in the argv array.
 @param argv The argument vector, as supplied to the `main()` function.
 @param argc The argument count, as supplied to the `main()` function.
 @param nextArgumentIndex If non-NULL, upon successful return this will contain the index of
 the first non-option entry in the `argv` array. May be NULL.
 
 This index may not be valid; it is up to the caller to range-check the supplied value before
 attempting to make use of it.
 @param error Should parsing of options fail, this parameter will be filled with an object
 describing the details of the error.
 @result Returns `YES` if the options were parsed successfully and all requirements met, `NO`
 otherwise.
 */
- (BOOL) parseCommandLineArguments: (char * const []) argv count: (int) argc nextArgumentIndex: (int *) nextIndex error: (NSError **) error;

/**
 Returns a string suitable for displaying as part of the usage information for the application.
 @param columnWidth The number of characters to display before wrapping.
 @result A string suitable for output to the user.
 */
- (NSString *) localizedUsageInformationWithColumnWidth: (NSUInteger) columnWidth;

/**
 Writes the usage information to the given file, determining an appropriate column width for terminals.
 @param fileHandle The file handle to which to write the usage information.
 */
- (void) writeLocalizedUsageInformationToFile: (NSFileHandle *) fileHandle;

@end
