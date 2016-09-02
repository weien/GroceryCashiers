//
//  GroceryCashiersTests.m
//  GroceryCashiersTests
//
//  Created by Weien Wang on 9/1/16.
//  Copyright © 2016 Weien Wang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface GroceryCashiersTests : XCTestCase
@property (nonatomic, strong) ViewController* vc;
@end

@implementation GroceryCashiersTests

- (void)setUp {
    [super setUp];
    self.vc = [ViewController new];
}

- (void)tearDown {
    self.vc = nil;
    [super tearDown];
}

- (void)testExample1 {
    NSString* example = @"1\nA 1 2\nA 2 1";
    NSDictionary* output = [self.vc runSimulationWithEntry:example];
    XCTAssertEqual(7,[output[@"minutes"] integerValue]);
}

- (void)testExample2 {
    NSString* example = @"2\nA 1 5\nB 2 1\nA 3 5\nB 5 3\nA 8 2";
    NSDictionary* output = [self.vc runSimulationWithEntry:example];
    XCTAssertEqual(13,[output[@"minutes"] integerValue]);
}

- (void)testExample3 {
    NSString* example = @"2\nA 1 2\nA 1 2\nA 2 1\nA 3 2";
    NSDictionary* output = [self.vc runSimulationWithEntry:example];
    XCTAssertEqual(6,[output[@"minutes"] integerValue]);
}

- (void)testError {
    NSString* example = @"2\nC 1 2";
    NSDictionary* output = [self.vc runSimulationWithEntry:example];
    XCTAssertNotNil(output[@"error"]);
}

@end
