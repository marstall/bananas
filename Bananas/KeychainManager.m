//
//  KeychainManager.m
//  Bananas
//
//  Created by marstall on 12/27/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "KeychainManager.h"
#import "Bananas.h"

static NSString * serviceName=@"com.psychoastronomy.Bananas";

@interface KeychainManager()
- (void)updateValue: (NSString *)value forKey:(NSString*)key;
- (void)addValue: (NSString *)value forKey:(NSString*)key;
@end

@implementation KeychainManager
+ (instancetype)sharedManager
{
    static KeychainManager * sharedManager;
    if (!sharedManager)
    {
        static dispatch_once_t predicate1;
        dispatch_once(&predicate1, ^(void){
            sharedManager = [[KeychainManager alloc] init];
        });
    }
    return sharedManager;
}

- (NSMutableDictionary *) createConfigDictionary:(NSString *) key
{
    NSMutableDictionary * attrs = [NSMutableDictionary new];
    
    [attrs setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    NSData * encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    [attrs setObject:encodedKey forKey:(__bridge id)kSecAttrGeneric];
    [attrs setObject:encodedKey forKey:(__bridge id)kSecAttrAccount];
    [attrs setObject:serviceName forKey:(__bridge id)kSecAttrService];
    return attrs;
}

- (NSString *)getHashedValueForKey:(NSString *)key
{
    NSString * value = [self getValueForKey:key];
    if (!value) return value;
    else return sha1(value);
}

- (NSString *) getValueForKey: (NSString*)key
{
    NSMutableDictionary * attrs = [self createConfigDictionary:key];

    [attrs setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [attrs setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attrs, (CFTypeRef*)&result);
    if (status==errSecSuccess)
    {
        NSString * stringResults = [[NSString alloc] initWithData:(__bridge NSData *)result encoding:NSUTF8StringEncoding];
        return stringResults;
    }
    else
    {
        return nil;
    }
}

- (void)setValue:(NSString *)value forKey:(NSString *)key
{
    if ([self getValueForKey:key])
    {
        return [self updateValue:value forKey:key];
    }
    else
    {
        return [self addValue:value forKey:key];
    }
    
}

- (void)updateValue: (NSString *)value forKey:(NSString*)key
{
    NSMutableDictionary * attrs = [self createConfigDictionary:key];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    
    NSData * encodedValue = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:encodedValue forKey:(__bridge id)kSecValueData];
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)attrs, (__bridge CFDictionaryRef)updateDictionary);
    if (status==errSecSuccess)
    {
        return;
    }
    else if (status==errSecDuplicateItem)
    {
        return;
    }
    else
    {
        DDLogError(@"FATAL could not update value for %@ in keychain",key);
    }
}

- (void)addValue: (NSString *)value forKey:(NSString*)key
{
    
    NSMutableDictionary * attrs = [self createConfigDictionary:key];
    CFTypeRef * result;
    
    NSData * encodedValue = [value dataUsingEncoding:NSUTF8StringEncoding];
    [attrs setObject:encodedValue forKey:(__bridge id)kSecValueData];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attrs, result);
    if (status==errSecSuccess)
    {
        return;
    }
    else if (status==errSecDuplicateItem)
    {
        return;
    }
    else
    {
        DDLogError(@"FATAL could not add value for %@ in keychain",key);
    }
}


- (void)deleteKey: (NSString*)key
{
    NSMutableDictionary * attrs = [self createConfigDictionary:key];
    SecItemDelete((__bridge CFDictionaryRef)attrs);
}

@end
