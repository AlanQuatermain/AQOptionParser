//
//  AQOptionParserTests.m
//  AQOptionParserTests
//
//  Created by Jim Dovey on 2012-05-23.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQOptionParserTests.h"
#import "AQOptionParser.h"
#import "AQOption.h"
#import "AQOptionRequirementGroup.h"
#import <getopt.h>

@implementation AQOptionParserTests

- (void) tearDown
{
    optreset = 1;
    [super tearDown];
}

- (BOOL) confirmGetoptLongWorks: (int) argc :(char **) argv :(struct option *)longOpts :(const char *)shortOpts
{
    //optreset = 1;
    
    int ch = 0;
    BOOL result = NO;
    while ( (ch = getopt_long(argc, argv, shortOpts, longOpts, NULL)) != -1 )
    {
        NSLog(@"Found option %c, arg %s", (char)ch, optarg == NULL ? "NULL" : optarg);
        result = YES;
    }
    
    optreset = 1;
    return ( result );
}

- (void) testShortOptionMatching
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    int argc = 3;
    char * argv[] = { "testerApp", "-t", "value", NULL };
    
    const char * shortOpts = "t:";
    struct option options[] = {
        { "test-attr", required_argument, NULL, 't' },
        { NULL, 0, NULL, 0 }
    };
    STAssertTrue([self confirmGetoptLongWorks: argc : argv : options : shortOpts], @"WTF?");
    
    NSError * error = nil;
    STAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: &error], @"Expected parser to succeed");
    STAssertTrue(option.matched, @"Expected option to match with short option specified");
    STAssertEqualObjects(option.parameter, @"value", @"Expected matched value to be 'value', but got %@", option.parameter);
}

- (void) testLongOptionMatching
{
    AQOption * option = [[AQOption alloc] initWithLongName: @"test-attr" shortName: 't' requiresParameter: AQOptionParameterTypeRequired optional: NO];
    AQOptionParser * parser = [AQOptionParser new];
    [parser addOption: option];
    
    int argc = 2;
    char * argv[] = { "testerApp", "--test-attr=the value", NULL };
    NSError * error = nil;
    STAssertTrue([parser parseCommandLineArguments: argv count: argc nextArgumentIndex: NULL error: &error], @"Expected parser to succeed");
    STAssertTrue(option.matched, @"Expected option to match with long option specified");
    STAssertEqualObjects(option.parameter, @"the value", @"Expected matched value to be 'the value', but got %@", option.parameter);
}

@end
