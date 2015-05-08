//
//  AppDelegate.m
//  Bananas
//
//  Created by marstall on 12/18/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "AppDelegate.h"
#import "UIKit/UIKit.h"
#import "ListViewController.h"
#import "KeychainManager.h"
#import "Bananas.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    backend = [[Backend alloc] initWithApplication:application andLaunchOptions:launchOptions];

    self.logArray = [[NSMutableArray alloc] init];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[[ViewLogger alloc] init]];
   
    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    screenRect.size.height = 1200;
    self.window = [[UIWindow alloc] initWithFrame:screenRect];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // create a listcontroller
    self.listViewController = [[ListViewController alloc] init];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.listViewController];
    [navigationController setToolbarHidden:NO];
    [navigationController setNavigationBarHidden:NO];
    
    self.window.rootViewController = navigationController;
 

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
//    });
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BananasParseManager.sharedManager updatePushDeviceToken:deviceToken];
    [backend updateListUUIDOnParse];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        DDLogVerbose(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        DDLogVerbose(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
                                fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    // following code is boilerplate for updating the icon badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation fetchInBackgroundWithBlock:^(PFObject * object, NSError * error) {
        if (((PFInstallation *)object).badge != 0) {
            ((PFInstallation *)object).badge = 0;
            [((PFInstallation *)object) saveEventually];
        }
    }];


    NSDictionary * aps = [userInfo valueForKey:@"aps"];
    NSString *pushMessage = [aps valueForKey:@"alert"];
    DDLogInfo(@"#display received push... : %@",pushMessage);

    if ([PushManager isMessageISentRecently:pushMessage])
    {
        DDLogInfo(@"#display ignored push because it's one that i sent ... : %@",pushMessage);
        return;
    }
    
    // there was a case where this data got corrupted/erased - so if we are receiving push data, reaffirm that we are connected
    UserDefaultsManager * um = [UserDefaultsManager sharedManager];
    if (![um getBooleanForKey:@"connected" ])
    {
        [um setBoolean:YES forKey:@"connected"];
    }
    if (![um getValueForKey:@"peerIAmConnectedTo" ])
    {
        [um setValue:@"[unknown]" forKey:@"peerIAmConnectedTo"];
    }


    DDLogInfo(@"#display push valid, should sync now: %@",pushMessage);
//    [self.listViewController sync:self];
    notify(kPerformSyncNotification);
    [handler invoke];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.listViewController.textField resignFirstResponder];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.listViewController.shouldShowDoneItems=false;
    if (![backend startSharing]) notify(kPerformSyncNotification);

    [backend resetBadge];
    
    [backend setupListUUID];
//    [backend startSharing];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    DDLogVerbose(@"#display currentInstallation's listUUID is %@",makeUUIDTag(currentInstallation[@"listUUID"]));
//    self.listViewController.cellBeingEdited=nil;

    [PushManager clearCount];
    
    [backend event:LIFECYCLE_LAUNCH];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.twopines.Bananas" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Bananas" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Bananas.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DDLogVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DDLogVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



- (void)testKeychainManager
{
    KeychainManager * sharedManager = KeychainManager.sharedManager;
    [sharedManager setValue:@"1234" forKey:@"chrisID"];
    [sharedManager setValue:@"5678" forKey:@"paulID"];
    NSString * value1 = [sharedManager getValueForKey:@"chrisID"];
    NSString * value2 = [sharedManager getValueForKey:@"paulID"];
    if ([value1 isEqualToString:@"1234"] && [value2 isEqualToString:@"5678"]) DDLogVerbose(@"keychain add/update ok");
    [sharedManager deleteKey:@"chrisID"];
    NSString * value3 = [sharedManager getValueForKey:@"chrisID"];
    if (!value3) DDLogVerbose(@"keychain delete ok");
    [sharedManager setValue:@"argh" forKey:@"paulID"];
    NSString * value4 = [sharedManager getValueForKey:@"paulID"];
    if ([value4 isEqualToString:@"argh"]) DDLogVerbose(@"keychain update ok");
}

@end
