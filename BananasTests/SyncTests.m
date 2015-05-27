//
//  SyncTests.m
//  Bananas
//
//  Created by marstall on 5/25/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "bananas.h"
#import "AppDelegate.h"


@interface SyncTests : XCTestCase


@end

@implementation SyncTests


- (void)setUp {
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (IBAction)async: (void (^)())block
{
    DDLogVerbose(@"async");
    [block invoke];
}
/*
- (void)_testBasicBitch
{
    NSString * self_methods = enumerate_methods(self);
    NSString * backend_methods = enumerate_methods(__backend);
    NSString * backend_alloc_methods = enumerate_methods([Backend alloc]);
    
    if ([__backend respondsToSelector:@selector(basicBitch)])
    {
        [__backend basicBitch];
    }
    else XCTAssert(NO, @"__backend not responding to basicBitch");
}

- (void)_testSync {
    // This is an example of a functional test case.
    XCTestExpectation *syncExpectation = [self expectationWithDescription:@"sync performed"];
    //[[Backend2 alloc] async];
//    [backend syncWithDoneItems:NO AndBlock:^{
    [__backend async:^{
        XCTAssert(YES,"sync returned.");
   //     [syncExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        DDLogVerbose(@"exp");
    }];
}
*/

@end
