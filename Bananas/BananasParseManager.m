//
//  BananasParseManager.m
//  Bananas
//
//  Created by marstall on 1/16/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "BananasParseManager.h"

@implementation BananasParseManager

+ (instancetype)sharedManager
{
    static BananasParseManager * sharedManager;
    if (!sharedManager)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^(void){
            sharedManager = [[BananasParseManager alloc] init];
        });
    }
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)setParseListUUID:(NSString *)listUUID
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"listUUID"] = listUUID;
    [currentInstallation saveInBackground];
}


- (void)setupParseUserSuccess: (NSString*)listUUID
{
    [self setParseListUUID:listUUID];
    [PFQuery clearAllCachedResults];
    [PFACL setDefaultACL:[PFACL ACL] withAccessForCurrentUser:YES];
    notify(kPerformSyncNotification);
}

- (void)setupParseUser
{

    NSString * listUUID = [[KeychainManager sharedManager] getValueForKey:@"listUUID"];
    if (!listUUID)
    {
        DDLogVerbose(@"#display #fatal listUUID not found, could not set up user");
        return;
    }
    [PFQuery clearAllCachedResults];
    [PFUser logOut];
   // [NSThread sleepForTimeInterval:5.0];

    // attempt to login. if failed, attempt to sign up
    [PFUser logInWithUsernameInBackground:listUUID password:listUUID block:^(PFUser * user, NSError *error) {
        if (user)
        {
            [self setupParseUserSuccess:listUUID];
        }
        else
        {
            user = [PFUser user];
            user.username = listUUID;
            user.password = listUUID;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
                // only this user can access data created by this user, in other words all data in the app
                // both list users will share the same name/password
                if (succeeded)
                {
                    [self setupParseUserSuccess:listUUID];
                }
                else
                {
                    DDLogVerbose(@"#display failed to login or sign up to parse: %@",error);
                }
            }];
        }
    }];
}



- (void)testParse
{
    DDLogVerbose(@"testing parse, inserting ....");
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    DDLogVerbose(@"parse tested ...");
    
}

/*
 - action
 lifecycle: (launch, minimize)
 items: (add, delete, move, mark as done,mark as not done)
 connecting: (invite issued, failed peer search, invite accepted, disconnect)
 sync: (sync)
 - data
 basic: (action category, time,device info, device name, device name connected to, listUUID, install date, any PID, list items w/statuses)
 lifecycle: ()
 items: (item name, status)
 connecting: (target device name)
 sync: (new items)
 
 LIFECYCLE_LAUNCH
 LIFECYCLE_MINIMIZE
 ITEM_ADD
 ITEM_DELETE
 ITEM_MOVE
 ITEM_DONE
 ITEM_UNDONE
 CONNECTING_INVITE_ISSUED
 CONNECTING_FAILED_PEER_SEARCH
 CONNECTING_INVITE_ACCEPTED
 CONNECTING_DISCONNECT
 SYNC
 PUSH_SENT
 PUSH_RECEIVED
 */

- (NSMutableDictionary *) buildDefaultDictionary
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    UIDevice * device = [UIDevice currentDevice];
    dict[@"listUUID"] = [backend listUUID];
    dict[@"device_name"] = device.name;
    dict[@"device_systemName"] = device.systemName;
    dict[@"device_systemVersion"] = device.systemVersion;
    dict[@"device_model"] = device.model;
//    dict[@"device_identifierForVendor"] = device.identifierForVendor;
    return dict;
}



@end
