//
//  UserDefaultsManager.h
//  Bananas
//
//  Created by marstall on 12/29/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsManager : NSObject
+ (instancetype)sharedManager;

- (NSString *) getValueForKey: (NSString*)key;
- (BOOL) getBooleanForKey: (NSString*)key;

- (void)setValue: (NSString *)value forKey:(NSString*)key;
- (void)setBoolean: (BOOL)boolean forKey:(NSString*)key;

@end
