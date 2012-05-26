//
//  AQOption.h
//  AQOptionParser
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Parameter requirement specifiers for the AQOption class.
 */
typedef NS_ENUM(NSUInteger, AQOptionParameterType) {
    AQOptionParameterTypeNone,          /// No parameter is expected (option is a boolean toggle).
    AQOptionParameterTypeOptional,      /// A parameter may be specified, but is optional.
    AQOptionParameterTypeRequired       /// This option requires a parameter, and will fail if none is provided.
};

/**
 The AQOption class specifies and represents a single command-line option.
 */
@interface AQOption : NSObject

/**
 Initializes a new AQOption with the given long and short form names corresponding to
 the command-line options `--[longName]` and `-[shortName]`.
 
 This is the designated initializer for AQOption.
 @param longName The long-form option name, specified on the command-line as `--[longName]=[value]`.
 @param shortName The single-character option specifier, used on the command-line as
 `-[shortName] [value]`.
 @param parameterType A value from the AQOptionParameterType enumeration.
 @param optional Whether this option is 
 @param handler A block which will be executed when the option is matched. May be `nil`.
 @result A new AQOption instance describing the named option.
 */
- (id) initWithLongName: (NSString *) longName shortName: (unichar) shortName requiresParameter: (AQOptionParameterType) parameterType optional: (BOOL) optional handler: (void (^)(NSString * longName, NSString * parameter)) handler;

/**
 Initializes a new AQOption with the given long and short form names corresponding to
 the command-line options `--[longName]` and `-[shortName]`.
 
 This form is useful when you wish to run through the option parser and then check
 the status of each option manually, rather than via callback as each is matched.
 @param longName The long-form option name, specified on the command-line as `--[longName]=[value]`.
 @param shortName The single-character option specifier, used on the command-line as
 `-[shortName] [value]`.
 @param parameterType A value from the AQOptionParameterType enumeration.
 @result A new AQOption instance describing the named option.
 */
- (id) initWithLongName: (NSString *) longName shortName: (unichar) shortName requiresParameter: (AQOptionParameterType) parameterType optional: (BOOL) optional;

/// `YES` when the option has been successfully matched on the command-line, `NO` otherwise.
@property (readonly, getter=hasBeenMatched, NS_NONATOMIC_IOSONLY) BOOL matched;

/// When the option has been matched, this property will be set to the provided parameter, if any.
@property (readonly, NS_NONATOMIC_IOSONLY) NSString * parameter;

/// Whether this option is required or optional.
@property (readonly, getter=isOptional, NS_NONATOMIC_IOSONLY) BOOL optional;

/**
 Localized help strings to be output as usage information for this option. If not specified,
 a default help string will be created of the format:
     
     --{longName}[=value] | -{shortName}[ value]:
         {Required|Optional}.
 
 If specified, the contents of the provided dictionary will be integrated with this string in
 the following manner:
     
     --{longName}[={AQOptionUsageLocalizedValueName}] | -{shortName}[ {AQOptionUsageLocalizedValueName}]:
         {AQOptionUsageLocalizedDescription}. {Required|Optional}.
 */
@property (copy, nonatomic) NSDictionary * localizedUsageInformation;

/**
 Returns a localized string describing the usage of this option, using values from
 localizedUsageInformation where available.
 
 The option example is separated from the description by a newline character, and the description
 uses indentation of four spaces at the start of each line. Description lines will be wrapped at the
 specified line width (number of characters, including the lead indent) as appropriate, possibly
 using hyphenation (if this is available for the current locale).
 @param padding The padding to be placed to the left of the option example.
 @param lineWidth The expected line width of the output terminal. If zero, no wrapping will
 be performed.
 @result A localized string suitable for command-line output on a terminal of the specified
 number of columns.
 */
- (NSString *) localizedUsageForOutputLineWidth: (NSUInteger) lineWidth;

@end

#ifndef $nil
# define $nil [NSNull null]
#endif

@interface AQOption (AQOptionListCreationHelper)

/**
 A convenience method to enable creation of a list of options using nested ObjC array literals.
 
 Each element in the provided array is expected to be an array containing the same arguments
 passed to initWithLongName:shortName:requiresParameter:optional:handler: (object-ized where
 appropriate), in the same order, followed by usage information and a value name. Any items for 
 which no value is to be provided should be represented using NSNull; a macro, `$nil`, is provided
 to assist in this. Hopefully the compiler folks will add an `@nil` literal or similar soon.
 
 Example:
 
     `@[ @"output-dir", @"o", @(AQOptionParameterTypeRequired), @NO, myHandler, NSLocalizedString(@"Sets the output folder path.",@""), NSLocalizedString(@"path",@"") ]`
 
 @param arrayDefinitions An array containing array-based parameter lists used to create AQOption
 instances.
 @result An array of AQOption instances.
 @throw NSRangeException if the provided arrays or their contents do not conform to the prescribed format.
 */
+ (NSArray *) optionsWithArrayDefinitions: (NSArray *) arrayDefinitions;

@end

/**
 @name Localized Usage Information Dictionary Keys
 */

/**
 Used to specify a name for the 'value' item in usage strings of the form `--option=value`.
 It is recommended that the value for this key be a single word.
 @see [AQOption localizedUsageInformation]
 */
extern NSString * const AQOptionUsageLocalizedValueName;

/**
 Used to specify a custom description for an option.
 @see [AQOption localizedUsageInformation]
 */
extern NSString * const AQOptionUsageLocalizedDescription;
