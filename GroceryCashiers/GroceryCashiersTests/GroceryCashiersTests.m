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
    NSString* example1 = @"1\nA 1 2\nA 2 1";
    NSDictionary* output = [self.vc runSimulationWithEntry:example1];
    XCTAssertEqual(7,[output[@"minutes"] integerValue]);
}

@end
