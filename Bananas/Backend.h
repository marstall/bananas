//
//  Backend.h
//  Bananas
//
//  Created by marstall on 2/8/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "Bananas.h"
#import <Foundation/Foundation.h>
#import "BackendIncludes.h"

@interface Backend : NSObject

@property dispatch_queue_t queue;
@property NSString * carumba;

- (instancetype)initWithApplication:(UIApplication *)application andLaunchOptions:(NSDictionary*)launchOptions;

- (NSMutableArray *)allItems;

- (BOOL)startSharing;
- (BOOL)isSharing;
- (IBAction)sync;
- (IBAction)syncWithDoneItems:(BOOL)showDoneItems;
- (IBAction)syncWithDoneItems:(BOOL)showDoneItems AndBlock: (void (^)())passed_block;
- (void)setupListUUID;
- (NSString *)listUUID;
- (NSString * )setListUUID:(NSString *) listUUID;
- (void)updateListUUIDOnParse;

- (NSString *)resetListUUID;

- (void)event:(NSString *) name;
- (void)event:(NSString *) name dimensions:(NSDictionary *)dimensions;

- (IBAction)syncTest: (void (^)())passed_block;
- (IBAction)async: (void (^)())block;

- (void)basicBitch;



- (void)resetBadge;
@end

Backend * __backend;
