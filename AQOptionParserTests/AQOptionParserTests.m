
//  AQOptionParserTests.m  AQOptionParserTests  Created by Jim Dovey on 2012-05-23. Copyright (c) 2012 Jim Dovey. All rights reserved.

#import <SenTestingKit/SenTestingKit.h>
#import <AQOptionParser/AQOptionParser.h>
#import <getopt.h>

@interface      AQOptionParserTests : SenTestCase
{
  NSError *__autoreleasing *error; AQOption * option; AQOptionParser * parser; int argc;
}
@end
@implementation AQOptionParserTests

- (void) setUp    { [super    setUp];    parser = AQOptionParser.new; error = nil; }
- (void) tearDown { [super tearDown];  optreset = 1; optind = 1;      }

- (void) testShortOptionSpacedMatching
{
  option = [parser addOption:[AQOption optionWithLName: @"test-attr" sName: 't' requires: AQOptionParameterTypeRequired opt: NO]];

  argc = 3; char *argv[] = { "testerApp", "-t", "value", NULL };

          STAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error:error], @"Expected parser to succeed");
          STAssertTrue(option.matched, @"Expected option to match with short option specified");
  STAssertEqualObjects(option.parameter, @"value", @"Expected matched value to be 'value', but got %@", option.parameter);
}

- (void) testShortOptionNonSpacedMatching
{
  option = [parser addOption:[AQOption optionWithLName:@"test-attr" sName: 't' requires:AQOptionParameterTypeRequired opt: NO]];

  argc = 2; char * argv[] = { "testerApp", "-tvalue", NULL };

          STAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error:error], @"Expected parser to succeed");
          STAssertTrue(option.matched, @"Expected option to match with short option specified");
  STAssertEqualObjects(option.parameter, @"value", @"Expected matched value to be 'value', but got %@", option.parameter);
}

- (void) testLongOptionEqualsMatching
{
  option = [parser addOption:[AQOption optionWithLName:@"test-attr" sName: 't' requires: AQOptionParameterTypeRequired opt: NO]];

  argc = 2; char * argv[] = { "testerApp", "--test-attr=the value", NULL };

          STAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: error], @"Expected parser to succeed");
          STAssertTrue(option.matched, @"Expected option to match with long option specified");
  STAssertEqualObjects(option.parameter, @"the value", @"Expected matched value to be 'the value', but got %@", option.parameter);
}

- (void) testLongOptionSpacedMatching
{
  option = [parser addOption:[AQOption optionWithLName:@"test-attr" sName: 't' requires: AQOptionParameterTypeRequired opt: NO]];

  argc = 3; char * argv[] = { "testerApp", "--test-attr", "the value", NULL };

          STAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error:error], @"Expected parser to succeed");
          STAssertTrue(option.matched, @"Expected option to match with long option specified");
  STAssertEqualObjects(option.parameter, @"the value", @"Expected matched value to be 'the value', but got %@", option.parameter);
}

- (void) testSingleOptionLocalizedDescription
{
  option = [parser addOption: [AQOption optionWithLName:@"test-attr" sName: 't' requires: AQOptionParameterTypeRequired opt: NO]];
  option.localizedUsageInformation = @{ AQOptionUsageLocalizedDescription : NSLocalizedString(@"A very nice option with which to test this library", @""), AQOptionUsageLocalizedValueName : @"{test}" };

  NSString * usageInfo = [parser localizedUsageInformationWithColumnWidth: 0],
    * wrappedUsageInfo = [parser localizedUsageInformationWithColumnWidth: 40],
       * expectedPlain = @"  --test-attr={test} | t {test}:\n    A very nice option with which to test this library.\n",
     * expectedWrapped = @"  --test-attr={test} | t {test}:\n    A very nice option with which to \n    test this library.\n";

  STAssertEqualObjects(usageInfo,          expectedPlain, @"Expected '%@' but got '%@'", expectedPlain, usageInfo);
  STAssertEqualObjects(wrappedUsageInfo, expectedWrapped, @"Expected '%@' but got '%@'", expectedWrapped, wrappedUsageInfo);
}

- (void) testHyphenationOfLocalizedDescription
{
  option = [parser addOption:[AQOption optionWithLName:@"test-attr" sName: 't' requires: AQOptionParameterTypeRequired opt: NO]];
  option.localizedUsageInformation = @{ AQOptionUsageLocalizedDescription : NSLocalizedString(@"A localized descriptive dedication of eloquently assembled linguistics in sequence.", @""), AQOptionUsageLocalizedValueName : @"{test}" };

  NSString * usage = [parser localizedUsageInformationWithColumnWidth: 40],
        * expected = @"  --test-attr={test} | t {test}:\n    A localized descriptive dedication\n    of eloquently assembled linguis-\n    tics in sequence.\n";

  STAssertEqualObjects(usage, expected, @"Expected '%@' but got '%@'", expected, usage);
}

@end
