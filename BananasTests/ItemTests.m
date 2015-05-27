//
//  ItemTests.m
//  Bananas
//
//  Created by marstall on 5/22/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Bananas.h"

@interface ItemTests : XCTestCase

@end

@implementation ItemTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (Item *) findItem:(NSString *)text
{
    for (Item * item in Item.allItems)
    {
        if ([[item valueForKey:@"text"] isEqualToString:text])
        {
            return item;
        }
    }
    return nil;

}

- (void)testAddEditDelete {

    // This is an example of a functional test case.
    NSString * text = [NSString stringWithFormat:@"test item %ul", arc4random_uniform(100000)];
    Item * item = [Item create:text withUUID:nil];
//    NSString * item_methods = enumerate_methods(item);
    [CoreDataManager save];
    Item * foundItem = [self findItem:text];
    if (foundItem) XCTAssert(YES, @"item add pass");
    else XCTAssert(NO, @"item add fail");

    NSString * text2 = [NSString stringWithFormat:@"test item %ul", arc4random_uniform(100000)];
    [item setValue:text2 forKey:@"text"];
    [CoreDataManager save];
    foundItem = [self findItem:text2];
    if (foundItem) XCTAssert(YES, @"item edit pass");
    else XCTAssert(NO, @"item edit fail");

    [CoreDataManager removeObject:item];
    foundItem = [self findItem:text2];
    if (foundItem) XCTAssert(NO, @"item delete fail");
    else XCTAssert(YES, @"item delete success");
}


@end
