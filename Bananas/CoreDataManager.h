//
//  CoreDataManager.h
//  Bananas
//
//  Created by marstall on 12/19/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//
#import "Bananas.h"
#import <Foundation/Foundation.h>
@import CoreData;

@interface CoreDataManager : NSObject
+ (NSMutableArray *)fetchAll:(NSString *)entityName
               withPredicate:(NSPredicate *)predicateString
        withSortDescriptions:(NSArray *)sortDescriptorKeys;
+ (NSManagedObject *)insertEntityWithName: (NSString *) entityName andAttributes: (NSDictionary *) attributes toArray: (NSMutableArray *) array;
+ (void)removeObject:(NSManagedObject *)object;
+ (void)save;

@end
