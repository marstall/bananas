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

- (instancetype)initWithApplication:(UIApplication *)application andLaunchOptions:(NSDictionary*)launchOptions;

- (NSMutableArray *)allItems;

- (BOOL)startSharing;
- (BOOL)isSharing;
- (IBAction)sync;
- (void)setupListUUID;
- (NSString *)listUUID;
- (NSString * )setListUUID:(NSString *) listUUID;
- (void)updateListUUIDOnParse;

- (NSString *)resetListUUID;


- (void)resetBadge;
@end

Backend * backend;
