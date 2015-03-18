//
//  KeychainManager.h
//  Bananas
//
//  Created by marstall on 12/27/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject

+ (instancetype)sharedManager;

- (NSString *) getValueForKey: (NSString*)key;
- (NSString *) getHashedValueForKey:(NSString *)key;

- (void)setValue: (NSString *)value forKey:(NSString*)key;
- (void)deleteKey: (NSString*)key;
@end
