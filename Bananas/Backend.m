//
//  Backend.m
//  Bananas
//
//  Created by marstall on 2/8/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "Backend.h"

@implementation Backend

- (instancetype)initWithApplication:(UIApplication *)application andLaunchOptions:(NSDictionary*)launchOptions
{
    self = [super init];
    if (self)
    {
        BOOL __block initialized=NO;
        static dispatch_once_t predicate1;
        dispatch_once(&predicate1, ^(void){
            initialized=YES;
            [[BananasParseManager sharedManager] initParseWithLaunchOptions:launchOptions andApplication:application];
            [self setupListUUID];
            self.queue=dispatch_queue_create("Bananas.Backend", nil);
        });
        if (!initialized) [NSException raise:@"Backend cannot be re-initialized" format:@""];
    }
    return self;
}

- (IBAction)sync
{
    dispatch_async(self.queue, ^{
        if ([self isSharing])
        {
            DDLogVerbose(@"syncing ...");
            // get all values from remote store
            // loop through them
            // for each, find local match via itemUUID
            // if a match is found, perform merge logic
            // if no match is found, add row
            NSString * listUUID = [KeychainManager.sharedManager getValueForKey:@"listUUID"];
            //        static dispatch_once_t onceToken;
            [Item remoteFindAllInListExceptStale:listUUID withBlock:^(NSArray * pfObjects, NSError * error) {
                if (error) return;
                if (!pfObjects) return;
                NSMutableArray * items = Item.allItems;
                for (Item * item in items)
                {
                    item.foundRemoteVersion=NO;
                } // local objects guilty until proven innocent
                
                for (PFObject * pfObject in pfObjects) // for each remote object
                {
                    BOOL matchFound = NO;
                    for (Item * item in items) // for each local object
                     {
                        // update existing if it is a match
                        if ([[pfObject valueForKey:@"itemUUID"] isEqualToString: [item valueForKey:@"itemUUID"]])
                        {
                            [item mergeWith: pfObject];
                            matchFound = YES;
                            item.foundRemoteVersion=YES;
                        }
                    }
                    if (!matchFound) // if no match for remote object create linked local object
                    {
                        // create new
                        Item *item = [Item create:[pfObject valueForKey:@"text"] withUUID:[pfObject valueForKey:@"itemUUID"]];
                        item.shouldUpdateRemoteCopy=NO;
                        item.foundRemoteVersion=YES;
                        [items addObject:item];
                        [CoreDataManager save];
                    }
                } 
                
                // delete local objects not found in remote repo
                NSMutableArray * itemsToRemove = [NSMutableArray new];
                for (Item * item in items)
                {
                    if (!item.foundRemoteVersion)
                    {
                        [itemsToRemove addObject:item];
                    }
                }
                for (Item * item in itemsToRemove)
                {
                    [items removeObject:item];
                    [CoreDataManager removeObject:item];
                }
                [CoreDataManager save];
                notify(kRefreshListUI);
                DDLogVerbose(@"sync complete.");
                
            }];
        }
    }); // dispatch_async
}

- (void)setupListUUID
{
    if (![self listUUID])
    {
        NSString * listUUID = [self resetListUUID];
        [[KeychainManager sharedManager] setValue:listUUID forKey:@"listUUID"];
        DDLogVerbose(@"#display launched with new list %@",listUUID);
    }
    else
    {
        DDLogVerbose(@"#display launched with existing list %@",[self listUUID]);
    }
}

- (NSString *)listUUID
{
    return [KeychainManager.sharedManager getValueForKey:@"listUUID"];
}

- (NSString *)resetListUUID
{
    [[UserDefaultsManager sharedManager] setBoolean:NO forKey:@"connected"];
    [[UserDefaultsManager sharedManager] setValue:nil forKey:@"peerIAmConnectedTo"];
    [Item deleteAll];
    [[MultipeerManager sharedManager] disconnect]; // disconnect from multipeer session if one exists
    return [self setListUUID:[[[NSUUID alloc] init] UUIDString]];
}

- (NSString * )setListUUID:(NSString *) listUUID
{
    if (!listUUID) [NSException raise:@"backend.setListUUID: listUUID must not be null" format:@""];
    //if (!listUUID) listUUID = [[[NSUUID alloc] init] UUIDString];
    [KeychainManager.sharedManager setValue:listUUID forKey:@"listUUID"];
    [BananasParseManager.sharedManager setParseListUUID:listUUID];
    return listUUID;
}

- (void)updateListUUIDOnParse
{
    [[BananasParseManager sharedManager] setParseListUUID:[self listUUID]];
}

- (NSMutableArray *)allItems
{
    return [Item allItems];
}

- (BOOL)startSharing
{
    dispatch_async(self.queue, ^{
        [[BananasParseManager sharedManager] setupParseUser];
    });
    return true;
}

- (BOOL)isSharing
{
    PFUser * user = [PFUser currentUser];
    BOOL connected = [[UserDefaultsManager sharedManager] getBooleanForKey:@"connected"];
    return user&&connected;
}

- (void)resetBadge
{
    //reset red icon badge count to zero
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation save];
    }
}

- (void)event:(NSString *) name dimensions:(NSDictionary *)dimensions
{
    [[BananasParseManager sharedManager] event:name dimensions:dimensions];
}


@end

