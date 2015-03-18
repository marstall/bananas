    //
//  CoreDataManager.m
//  Bananas
//
//  Created by marstall on 12/19/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "CoreDataManager.h"

// CoreDataManager should create context once, then return same object every time it's asked.
@interface CoreDataManager ()
    + (NSManagedObjectContext *) context;
@end

@implementation CoreDataManager

+ (NSManagedObjectContext *)context
{
    static NSManagedObjectContext * context;

    static dispatch_once_t once_token;

    if (!context) dispatch_once(&once_token,^{
        context = [CoreDataManager createContext];
        });
    return context;
}

+ (NSManagedObjectContext *)createContext
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // 2. instantiate storeCoordinator with model & path to sqlite file
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSArray *documentDirectories =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"store.data"];
    DDLogVerbose(@"sqlite3 path: %@",path);
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    
    // 3. instantiate managed object context with PSC.
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        @throw [NSException exceptionWithName:@"Open Failure" reason:[error localizedDescription] userInfo:nil];
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;
    
    return context;
}

+ (NSMutableArray *)fetchAll:(NSString *) entityName withPredicate:(NSPredicate *)predicate withSortDescriptions: (NSArray *)sortDescriptorKeys
{
    NSManagedObjectContext * context = [CoreDataManager context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *e = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    request.entity = e;
    
    if (predicate) [request setPredicate:predicate];
    
    NSMutableArray * sortDescriptors = [[NSMutableArray alloc] init];
    if (sortDescriptorKeys.count>0)
    {
        for (NSString * key in sortDescriptorKeys)
        {
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
            [sortDescriptors addObject:sd];
        }
        request.sortDescriptors=sortDescriptors;
    }
    
    NSError * error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result)
    {
        [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
    }
    return [[NSMutableArray alloc] initWithArray:result];
}

+ (NSManagedObject *)insertEntityWithName: (NSString *) entityName andAttributes: (NSDictionary *) attributes toArray: (NSMutableArray *) array
{
    NSManagedObject * managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[CoreDataManager context]];
    for (NSString * key in [attributes allKeys])
    {
        [managedObject setValue:attributes[key] forKey:key];
    }
    if (array) [array addObject:managedObject];
//    [self save];
    return managedObject;

}

+ (void)removeObject:(NSManagedObject *)object
{
    [self.context deleteObject:object];
    [self save];
}

+ (void) save
{
    NSError * error = nil;
    [self.context save:&error];
}


@end
