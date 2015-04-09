//
//  Item.m
//  Bananas
//
//  Created by marstall on 12/26/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "Item.h"
#import "CoreDataManager.h"
#import "KeychainManager.h"
#import "Bananas.h"

@interface Item ()
    @property (nonatomic, strong) PFObject *pfObject;

@end

@implementation Item

//static NSMutableArray * _allItems=nil;

@synthesize pfObject;
@synthesize shouldSendPush;
@synthesize foundRemoteVersion;
@synthesize isNewOrChanged;
@synthesize shouldUpdateRemoteCopy;

+ (NSMutableArray *)allItems
{
    NSString * listUUIDHash = [[KeychainManager sharedManager] getHashedValueForKey:@"listUUID"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"listUUIDHash == %@",listUUIDHash];
    return [CoreDataManager fetchAll:@"Item"
                withPredicate:predicate
                withSortDescriptions:@[@"position"]];
}

+ (void)deleteAll
{
    for (Item * object in Item.allItems)
    {
        [CoreDataManager removeObject:object];
    }
}


+ (instancetype)create:(NSString *) text withUUID:(NSString *)itemUUID
{
    if (!itemUUID) itemUUID = [[[NSUUID alloc] init] UUIDString];
    
    NSString * listUUIDHash = [[KeychainManager sharedManager] getHashedValueForKey:@"listUUID"];
    if (!listUUIDHash) [NSException raise:@"listUUID must not be null" format:@""];
    NSMutableArray * items = Item.allItems;
    NSNumber * position =0;
    if (items.count>0) position = [items.lastObject valueForKey:@"position"];
    float floatPosition = [position floatValue];
    floatPosition++;
    Item *item = (Item *)[CoreDataManager insertEntityWithName: @"Item"
                                         andAttributes:@{
                                                         @"text":text,
                                                         @"itemUUID":itemUUID,
                                                         @"status":@"active",
                                                         @"listUUIDHash":listUUIDHash,
                                                         @"position":[NSNumber numberWithFloat:floatPosition]
                                                         }
                                               toArray:nil
                  ];
    item.shouldSendPush=true;
    item.isNewOrChanged=YES;
    return item;
}

- (instancetype)init
{
    if (self=[super init])
    {
        self.shouldSendPush=false;
        self.foundRemoteVersion=false;
        self.shouldUpdateRemoteCopy=NO;
    }
    return self;
}
- (void) mergeWith:(PFObject *) _pfObject
{
    self.pfObject = _pfObject;
//    NSString * text = [self valueForKey:@"text"];
    NSString * remoteStatus = [self.pfObject valueForKey:@"status"];
    NSString * selfStatus = [self valueForKey:@"status"];
    if ([remoteStatus isEqualToString:selfStatus]) return;
    [self setValue: remoteStatus forKey:@"status"];
}

+ (NSArray *) findAllInList:(NSString *) listUUID
{
    if (![PFUser currentUser]) return nil;
    [PFQuery clearAllCachedResults];
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"listUUID" equalTo:listUUID];
    NSArray * objects = [query findObjects];
    return objects;
}

+ (void) remoteFindAllInListExceptStale:(NSString *) listUUID withBlock:(void (^)(NSArray*,NSError *))block
{
    if (![PFUser currentUser]) return ;
    NSString * predicateFormat = @"listUUID = %@ and (status='active' or (status='done' and updatedAt>%@))";
    int secondsInMinute = 60;
    NSDate * date = [NSDate dateWithTimeInterval: -(45*secondsInMinute) sinceDate:[NSDate date]]; // 3 days ago
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat,listUUID,date];
    // return all where listUUID=$listUUID and (status='active' or (status='done' and updatedAt>today-7days))
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item" predicate:predicate];
    [query findObjectsInBackgroundWithBlock:block];
//    return objects;
}

- (void)loadPFObjectWithItemUUID:(NSString *)itemUUID andBlock:(void (^)(NSArray*,NSError *))block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"itemUUID" equalTo:itemUUID];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void)prepareForDeletion
{
    NSString * itemUUID = [self valueForKey:@"itemUUID"];
    NSString * text = [self valueForKey:@"text"];
    
    [self loadPFObjectWithItemUUID:itemUUID andBlock: ^(NSArray * pfObjects, NSError * error) {
        if (pfObjects.count==0) return;
        PFObject * pfObjectToDelete =  pfObjects.firstObject;
        if (self.shouldUpdateRemoteCopy && pfObjectToDelete)
        {
            NSString * pushMessage = [NSString stringWithFormat:@"%@ was deleted.",text];
            NSString * listUUID = [KeychainManager.sharedManager getValueForKey:@"listUUID"];
            [PushManager sendPushMessage:pushMessage forQuery:@{@"listUUID":listUUID}];
            [pfObjectToDelete deleteEventually];
        }
    }];
}

-(void)willSave
{
    static int cnt =0;
    DDLogVerbose(@"Item willSave ...");
    NSArray * allKeys = [[self changedValues] allKeys];
    NSUInteger numChanges = allKeys.count;
    if (numChanges==0) return;
    self.isNewOrChanged=YES;
    DDLogInfo(@"saving %lu values (%i th call)",(unsigned long)numChanges,cnt++);
    NSString * pushMessage=nil;
    NSString * textString = [self valueForKey:@"text"] ;
    [backend event:ITEM_ADD dimensions:@{ITEM_TEXT:textString}];
    NSString * listUUID = [[KeychainManager sharedManager] getValueForKey:@"listUUID"];
    self.pfObject= [PFObject objectWithClassName:@"Item"];
    // validations
    if (((NSString*)[self valueForKey:@"text"]).length==0) return;
    
    if (!self.isDeleted)
    {
        if ([self changedValues][@"text"])
        {
            NSString * s = [NSString stringWithFormat:@"%@ added to list.",textString];
            DDLogInfo(@"#display %@",s);
            pushMessage=s;
        } else
        if ([self changedValues][@"status"])
        {
            NSString * text = [self valueForKey:@"text"];
            NSString * newStatus = [self valueForKey:@"status"];
            NSString * logStatus = [newStatus copy];
            if ([logStatus isEqualToString:@""]) logStatus = @"active";
            DDLogInfo(@"#display %@ marked as %@",text,logStatus);
            if ([newStatus isEqualToString:@"done"])
            {
                pushMessage=[NSString stringWithFormat:@"%@ marked as done.",textString];
            }
            else
            {
                pushMessage=[NSString stringWithFormat:@"%@ still needed.",textString];
            }
        }
        if (self.shouldUpdateRemoteCopy) // don't send push for an update to the object that was triggered by a remote sync
        {
            DDLogVerbose(@"Updating remote copy ...");
            [self.pfObject setObject:listUUID forKey:@"listUUID"];

            [self.pfObject setObject:[self valueForKey:@"text"]        forKey:@"text"];
            [self.pfObject setObject:[self valueForKey:@"itemUUID"]    forKey:@"itemUUID"];
            [self.pfObject setObject:[self valueForKey:@"status"]      forKey:@"status"];
            [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
               //  NSString * cloudId = self.pfObject.objectId;
               //  [self setValue: cloudId forKey:@"cloudId"];
                 if (pushMessage && self.shouldSendPush && [backend isSharing])
                 {
                     [PushManager sendPushMessage:pushMessage forQuery:@{@"listUUID":listUUID}];
                     NSLog(@"#display sending push message '%@' ...",pushMessage);
                     
                     self.shouldSendPush=false;
                 }
                 //[CoreDataManager save];
             }];
        }
    }
    else
    {
        // delete it
//        [self.pfObject delete];
    }
    self.shouldUpdateRemoteCopy=NO;
    DDLogVerbose(@"persisting item %@ %@ ...",[self valueForKey:@"text"],[self valueForKey:@"itemUUID"]);
}

@end
