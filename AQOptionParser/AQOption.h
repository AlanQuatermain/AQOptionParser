
//  AQOption.h  AQOptionParser  Created by Jim Dovey on 2012-05-23.  Copyright (c) 2012 Jim Dovey. All rights reserved.

@import Foundation;

#ifndef NS_DESIGNATED_INITIALIZER
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#endif

/** Parameter requirement specifiers for the AQOption class. */
typedef NS_ENUM(NSUInteger, AQOptionParameterType)
{
    AQOptionParameterTypeNone,      /// No parameter is expected (option is a boolean toggle).
    AQOptionParameterTypeOptional,  /// A parameter may be specified, but is optional.
    AQOptionParameterTypeRequired   /// This option requires a parameter, and will fail if none is provided.
};

//@interface AZOption : NSObject
//typedef void (^OptHandler)(AZOption *option);
//@property (copy) OptHandler handler;
//@property (readonly) BOOL matched, optional;
//@property (readonly) NSString *name, *value;
//+ (instancetype) longOpt:(NSString*)l short:(unichar)s options:(AQOptionParameterType)t handler:(OptHandler)h;
//@end

/** @abstract The AQOption class specifies and represents a single command-line option. */
@interface AQOption : NSObject

typedef void (^OptionHandler)(AQOption *option);

@property (readonly) NSString * longName;
@property (readonly) unichar   shortName;


/** Initializes a new AQOption with the given long and short form names corresponding to the command-line options `--[longName]` and `-[shortName]`.

 @param lName The long-form option name, specified on the command-line as `--[longName]=[value]`.
 @param sName The single-character option specifier, used on the command-line as
 `-[shortName] [value]`.
 @param pType A value from the AQOptionParameterType enumeration.
 @param opt Whether this option is
 @param hndlr A block which will be executed when the option is matched. May be `nil`.
 @result A new AQOption instance describing the named option.
 */
- initWithLongName:(NSString*)lName shortName:(unichar)sName requiresParameter:(AQOptionParameterType)pType
          optional:(BOOL)opt          handler:(OptionHandler)hndlr NS_DESIGNATED_INITIALIZER;

+ (instancetype) optionWithLName:(NSString*)l sName:(unichar)s requires:(AQOptionParameterType)t opt:(BOOL)o handler:(OptionHandler)h;

/** A new AQOption instance describing the named option.
 @abstract Initializes a new AQOption with the given long and short form names corresponding to the command-line options `--[longName]` and `-[shortName]`.
 
  @discussion This form is useful when you wish to run through the option parser and then check the status of each option manually, rather than via callback as each is matched.
  @param lName       The long-form option name, specified on the command-line as \c --[longName]=[value]
  @param sName      The single-character option specifier, used on the command-line as \c -[shortName] [value]
  @param pType  A value from the AQOptionParameterType enumeration.
  @param opt Whether this option is
*/
- initWithLongName:(NSString*)lName            shortName:(unichar)sName
 requiresParameter:(AQOptionParameterType)pType optional:(BOOL)opt;

+ (instancetype) optionWithLName:(NSString*)l sName:(unichar)s requires:(AQOptionParameterType)t opt:(BOOL)o;

/// When the option has been matched, this property will be set to the provided parameter, if any.
@property (readonly) NSString * value;

@property (readonly) BOOL matched,  /// `YES` when the option has been successfully matched on the command-line, `NO` otherwise.
                          optional; /// Whether this option is required or optional.

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

/** A localized string suitable for command-line output on a terminal of the specified number of columns.
    @discussion Returns a localized string describing the usage of this option, using values from localizedUsageInformation where available. The option example is separated from the description by a newline character, and the description uses indentation of four spaces at the start of each line. Description lines will be wrapped at the specified line width (number of characters, including the lead indent) as appropriate, possibly using hyphenation (if this is available for the current locale).
    @param padding    The padding to be placed to the left of the option example.
    @param lineWidth  The expected line width of the output terminal. If zero, no wrapping will be performed.
 */
- (NSString*) localizedUsageForOutputLineWidth:(NSUInteger) lineWidth;

@end

#ifndef $nil
  #define $nil [NSNull null]
#endif

@interface AQOption (AQOptionListCreationHelper)

/** An array of AQOption instances.
    @abstract A convenience method to enable creation of a list of options using nested ObjC array literals.
    @discussion Each element in the provided array is expected to be an array containing the same arguments passed to initWithLongName:shortName:requiresParameter:optional:handler: (object-ized where appropriate), in the same order, followed by usage information and a value name. Any items for which no value is to be provided should be represented using NSNull; a macro, `$nil`, is provided to assist in this. Hopefully the compiler folks will add an `@nil` literal or similar soon.
 
    @code

     @[ @"output-dir", @"o", @(AQOptionParameterTypeRequired), @NO, myHandler, NSLocalizedString(@"Sets the output folder path.",@""), NSLocalizedString(@"path",@"") ]
 
    @param arrayDefinitions An array containing array-based parameter lists used to create AQOption instances.
    @throw NSRangeException if the provided arrays or their contents do not conform to the prescribed format.
*/
+ (NSArray*) optionsWithArrayDefinitions:(NSArray*) arrayDefinitions;

@end

/** @name Localized Usage Information Dictionary Keys */ extern NSString

/** Used to specify a name for the 'value' item in usage strings of the form `--option=value`.
    @note It is recommended that the value for this key be a single word.
    @see  [AQOption localizedUsageInformation]
 */ * const AQOptionUsageLocalizedValueName,

/** Used to specify a custom description for an option.
    @see  [AQOption localizedUsageInformation]
 */ * const AQOptionUsageLocalizedDescription;
