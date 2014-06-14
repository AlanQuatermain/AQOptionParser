
//  AQOptionParser.m   AQOptionParser  Created by Jim Dovey on 2012-05-23.  Copyright (c) 2012 Jim Dovey. All rights reserved.

#import "AQOptionParser.h"
#import "AQOptionRequirementGroup.h"
#import "AQOption_Internal.h"
#import <sys/ioctl.h>

NSString * const AQOptionErrorDomain = @"AQOptionErrorDomain";

@implementation AQOptionParser
{
  NSMutableOrderedSet * _options,
                      * _optionGroups;
  NSMutableSet        * _allOptions;
}

- (NSArray*) allOptions { return [_allOptions allObjects]; }

- (id) init
{
  if (!(self = super.init)) return nil;
  _options      = NSMutableOrderedSet.new;
  _optionGroups = NSMutableOrderedSet.new;
  _allOptions   = NSMutableSet.new;

  return self;
}
/*
  NSArray *args = @[
    @[@"help",        @(no_argument),        @NO, @"h"],  @[@"telnet",     @(no_argument),        @NO, @"t"],
    @[@"no-clear",    @(no_argument),        @NO, @"e"],	@[@"frames",     @(required_argument),  @NO, @"f"],
    @[@"min-rows",    @(required_argument),  @NO, @"r"],	@[@"max-rows",   @(required_argument),  @NO, @"R"]];

*/

- (void) addLongOpts:(const struct option[])long_opts count:(int)ct {

  for (int i = 0; i < ct; i++) {
      struct option opt = long_opts[i];
      AQOption *o = [AQOption optionWithLName:[NSString stringWithUTF8String:opt.name]
                                        sName:(unichar)opt.flag
                                        //[[NSString stringWithFormat:@"%c",(unichar)opt.flag] characterAtIndex:0]
                                    requires:opt.has_arg opt:YES];
      if(o) { [self addOption:o]; }
      else printf("Problem adding opt %s\n", opt.name);
   }
}

- (NSArray*) addLongOptsArray:(NSArray*)long_opts {

  NSMutableArray *opts = @[].mutableCopy;

  for (NSArray *longOpt in long_opts) {


      NSString * lName      = longOpt[0];
//      NSUInteger sNameIndex = [longOpt[2] isKindOfClass:NSNumber.class] ? 3 : 2;
//      BOOL optional         = sNameIndex == 2 ? NO : [longOpt[3] boolValue];
      NSString *sString     = longOpt[2];//sNameIndex];
      unichar sName         = sString.length ? [sString characterAtIndex:0] : 0;

      AQOption *o = [AQOption optionWithLName:lName sName:sName
                                    requires:[longOpt[1] integerValue] opt:YES
                                     handler:longOpt.count == 4 ? longOpt[3] : NULL];
                                     
      if (!o) { NSLog(@"problem adding %@", longOpt.firstObject); continue; }
      [self addOption:o]; [opts addObject:o];
  }
  return opts;
}
- (AQOption*) addOption: (AQOption*) option
{
  [_options addObject: option];
  [_allOptions addObject: option];
  return option;
}

- (NSArray*) addOptions:(NSArray*) options
{
  [_options addObjectsFromArray: options];
  [_allOptions addObjectsFromArray: options];
  return options;
}

- (AQOptionRequirementGroup*) addOptionGroup: (AQOptionRequirementGroup*) group
{
  [_optionGroups addObject: group];
  [_allOptions unionSet: [group.options set]];
  [_options minusOrderedSet: group.options];
  return group;
}

- (NSString*) localizedUsageInformationWithColumnWidth:(NSUInteger) columnWidth
{
  NSString * oneOf = NSLocalizedString(@"One of:", @"Exclusive group usage info header"),
           * anyOf = NSLocalizedString(@"At least one of:", @"Permissive group usage info header");

  NSMutableString * builder = @"".mutableCopy;
  for (AQOptionRequirementGroup * group in _optionGroups) {

    [builder appendFormat: @"  %@\n", (group.type == AQOptionRequirementAtLeastOne ? anyOf : oneOf)];
    for ( AQOption * option in group.options )
      [builder appendFormat: @"    %@\n", [option localizedUsageForOutputLineWidth: (columnWidth == 0 ? 0: columnWidth-4)]];
  }

  for (AQOption * option in _options)
    [builder appendFormat: @"  %@\n", [option localizedUsageForOutputLineWidth: (columnWidth == 0 ? 0 : columnWidth-2)]];

  return [builder copy];
}

- (void) writeLocalizedUsageInformationToFile:(NSFileHandle*) fileHandle
{
  struct winsize ws = {0};
  if ( isatty([fileHandle fileDescriptor]) == 0 || ioctl([fileHandle fileDescriptor], TIOCGWINSZ, &ws) != 0 )
  {
    [fileHandle writeData: [[self localizedUsageInformationWithColumnWidth: 0] dataUsingEncoding: NSUTF8StringEncoding]];
    return;
  }

  [fileHandle writeData: [[self localizedUsageInformationWithColumnWidth: ws.ws_col] dataUsingEncoding: NSUTF8StringEncoding]];
}

- (BOOL) parseCommandLineArguments: (char *const []) argv count: (int) argc nextArgumentIndex: (int*) nextIndex error:(NSError *__autoreleasing*) error
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
    NSMapInsert(lookup, (const void *)(intptr_t)option.shortName, (__bridge void *)option);
    shortOptions[c++] = (char)option.shortName;
    if (!option.optional) shortOptions[c++] = ':';
  }

  options[i] = nilOption;
  shortOptions[c] = '\0';

  // parse and handle
  @try
  {
    intptr_t ch = 0;
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
      if (!option) continue;        // er...?

      NSString * parameter = nil;
      if (optarg)
        parameter = [NSString stringWithUTF8String: optarg];
      [option matchedWithParameter: parameter];   // may throw for exclusive group members
    }
  }
  @catch (NSException * e)
  {
    if (error) // craft an NSError from the exception
      *error = [NSError errorWithDomain: AQOptionErrorDomain code: 1 userInfo: @{ @"Exception" : e }];
    return NO;
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
    if (!option.optional && !option.matched)
    {
      if (error)
        *error = [NSError errorWithDomain: AQOptionErrorDomain code: 2 userInfo: @{
               NSLocalizedDescriptionKey : NSLocalizedString(@"Required option not specified", @"Missing Required Option error description"),
                               @"Option" : option }];
      return NO;
    }
  }

  for ( AQOptionRequirementGroup * group in _optionGroups )
  {
    if ( group.matched == NO )
    {
      if (error)
        *error = [NSError errorWithDomain: AQOptionErrorDomain code: 2 userInfo:@{
               NSLocalizedDescriptionKey : NSLocalizedString(@"Member of required option group not specified", @"Missing Required Option From Group error description"),
                          @"OptionGroup" : group}];
    }
  }
  return YES;
}

@end
