//
//  Bananas.h
//  Bananas
//
//  Created by marstall on 12/30/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#ifndef Bananas_Bananas_h
#define Bananas_Bananas_h
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "ViewLogger.h"
#import "KeychainManager.h"
#import "UserDefaultsManager.h"
#import "Item.h"
#import "PushManager.h"
#import "KeychainManager.h"
#import "ListViewController.h"
#import "LogViewController.h"
#import "ItemTableViewCell.h"
#import "MultipeerManager.h"
#include "CommonCrypto/CommonDigest.h"
#include "Backend.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static NSString * const kPerformSyncNotification = @"kPerformSyncNotifcation";
static NSString * const kRefreshListUI = @"kRefreshListUI";

#define DEBUG_LISTUUID 1

NSString * makeUUIDTag(NSString * uuidString);

void notify(NSString * notification);
void observe(NSObject *id, SEL selector, const NSString * __strong notification);
void remove_observer(NSObject * id);

NSString * sha1(NSString * s);


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#endif

/*
 things to track:
 
 - app launch
 
 basic data to send:
 
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

#define ITEM_ADD @"item_added"
#define ITEM_TEXT @"item_text"


