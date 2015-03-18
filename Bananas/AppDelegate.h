//
//  AppDelegate.h
//  Bananas
//
//  Created by marstall on 12/18/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ListViewController.h"
#import "Bananas.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString * listUUID;

@property (nonatomic, strong) ListViewController * listViewController;
@property (nonatomic, strong) NSMutableArray * logArray;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;




@end

