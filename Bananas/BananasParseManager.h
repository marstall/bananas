//
//  BananasParseManager.h
//  Bananas
//
//  Created by marstall on 1/16/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseManager.h"
#import "Bananas.h"

@interface BananasParseManager : ParseManager
+ (instancetype)sharedManager;
- (void)setupParseUser;
- (void)setParseListUUID:(NSString *)listUUID;
- (NSMutableDictionary *) buildDefaultDictionary;


@end
