//
//  AQOptionParserTests.m
//  AQOptionParserTests
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQOptionParserTests.h"
#import <AQOptionParser/AQOptionParser.h>
#import <getopt.h>

@implementation AQOptionParserTests

- (void) tearDown
{
    optreset = 1;
    optind = 1;
    [super tearDown];
}

- (void) testShortOptionSpacedMatching
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    int argc = 3;
    char * argv[] = { "testerApp", "-t", "value", NULL };
    
    NSError * error = nil;
    XCTAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: &error], @"Expected parser to succeed");
    XCTAssertTrue(option.matched, @"Expected option to match with short option specified");
    XCTAssertEqualObjects(option.parameter, @"value", @"Expected matched value to be 'value', but got %@", option.parameter);
}

- (void) testShortOptionNonSpacedMatching
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    int argc = 2;
    char * argv[] = { "testerApp", "-tvalue", NULL };
    
    NSError * error = nil;
    XCTAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: &error], @"Expected parser to succeed");
    XCTAssertTrue(option.matched, @"Expected option to match with short option specified");
    XCTAssertEqualObjects(option.parameter, @"value", @"Expected matched value to be 'value', but got %@", option.parameter);
}

- (void) testLongOptionEqualsMatching
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    int argc = 2;
    char * argv[] = { "testerApp", "--test-attr=the value", NULL };
    NSError * error = nil;
    XCTAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: &error], @"Expected parser to succeed");
    XCTAssertTrue(option.matched, @"Expected option to match with long option specified");
    XCTAssertEqualObjects(option.parameter, @"the value", @"Expected matched value to be 'the value', but got %@", option.parameter);
}

- (void) testLongOptionSpacedMatching
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    int argc = 3;
    char * argv[] = { "testerApp", "--test-attr", "the value", NULL };
    NSError * error = nil;
    XCTAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: &error], @"Expected parser to succeed");
    XCTAssertTrue(option.matched, @"Expected option to match with long option specified");
    XCTAssertEqualObjects(option.parameter, @"the value", @"Expected matched value to be 'the value', but got %@", option.parameter);
}

- (void) testSingleOptionLocalizedDescription
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    option.localizedUsageInformation = @{ AQOptionUsageLocalizedDescription : NSLocalizedString(@"A very nice option with which to test this library", @""), AQOptionUsageLocalizedValueName : @"{test}" };
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    NSString * usageInfo = [parser localizedUsageInformationWithColumnWidth: 0];
    NSString * wrappedUsageInfo = [parser localizedUsageInformationWithColumnWidth: 40];
    
    NSString * expectedPlain = @"  --test-attr={test} | t {test}:\n    A very nice option with which to test this library.\n";
    NSString * expectedWrapped = @"  --test-attr={test} | t {test}:\n    A very nice option with which to \n    test this library.\n";
    
    XCTAssertEqualObjects(usageInfo, expectedPlain, @"Expected '%@' but got '%@'", expectedPlain, usageInfo);
    XCTAssertEqualObjects(wrappedUsageInfo, expectedWrapped, @"Expected '%@' but got '%@'", expectedWrapped, wrappedUsageInfo);
}

- (void) testHyphenationOfLocalizedDescription
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    option.localizedUsageInformation = @{ AQOptionUsageLocalizedDescription : NSLocalizedString(@"A localized descriptive dedication of eloquently assembled linguistics in sequence.", @""), AQOptionUsageLocalizedValueName : @"{test}" };
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    NSString * usage = [parser localizedUsageInformationWithColumnWidth: 40];
    NSString * expected = @"  --test-attr={test} | t {test}:\n    A localized descriptive dedication\n    of eloquently assembled linguis-\n    tics in sequence.\n";
    XCTAssertEqualObjects(usage, expected, @"Expected '%@' but got '%@'", expected, usage);
}

@end
