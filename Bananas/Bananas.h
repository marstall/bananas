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
#import <objc/runtime.h>


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static NSString * const kPerformSyncNotification = @"kPerformSyncNotifcation";
static NSString * const kRefreshListUI = @"kRefreshListUI";
static NSString * const kPerformDoSetToolBarItems = @"kPerformDoSetToolBarItems";


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


NSString * enumerate_methods(NSObject * obj);


#define ITEM_ADD @"item_added"
#define ITEM_EDIT @"item_edited"
#define ITEM_DELETE @"item_deleted"
#define ITEM_DONE @"item_marked_as_done"
#define ITEM_UNDONE @"item_marked_as_undone"

#define CONNNECTING_INVITE_ISSUED @"connecting_invite_issued"
#define CONNECTING_FAILED_PEER_SEARCH @"connecting_failed_peer_search"
#define CONNECTING_INVITE_ACCEPTED @"connecting_invite_accepted"
#define CONNECTING_DISCONNECT @"connecting_disconnect"
#define SYNC @"sync"
#define PUSH_SENT @"push_sent"
#define PUSH_RECEIVED @"push_received"
#define LIFECYCLE_LAUNCH @"lifecycle_launch"
#define CLICK @"click"

#define ITEM_TEXT @"item_text"
#define BUTTON_TEXT @"button_text"

#endif

