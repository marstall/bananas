//
//  Item.h
//  Bananas
//
//  Created by marstall on 12/26/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
#import "Parse/Parse.h"


@interface Item : NSManagedObject

    @property BOOL shouldSendPush;
    @property BOOL foundRemoteVersion;
    @property BOOL isNewOrChanged;
    @property BOOL shouldUpdateRemoteCopy;

    + (NSMutableArray *)allItems;
    + (BOOL) atLeastOneDoneItem;

    + (void)deleteAll;
//    + (void)setAllItems:(NSMutableArray *) __allItems;

    + (instancetype)create:(NSString *) text withUUID:(NSString *)itemUUID;

    + (void) remoteFindAllInList:(NSString *) listUUID  withBlock:(void (^)(NSArray*,NSError *))block; // show active first, then inactive
    + (void) remoteFindAllInListExceptStale:(NSString *) listUUID withBlock:(void (^)(NSArray*,NSError *))block;

    - (void) mergeWith:(PFObject *) pfObject;


@end
