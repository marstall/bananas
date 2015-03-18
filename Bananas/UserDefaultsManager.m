//
//  UserDefaultsManager.m
//  Bananas
//
//  Created by marstall on 12/29/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "UserDefaultsManager.h"
#import "Bananas.h"

@implementation UserDefaultsManager
+ (instancetype)sharedManager
{
    static UserDefaultsManager * sharedManager;
    if (!sharedManager)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^(void){
            sharedManager = [[UserDefaultsManager alloc] init];
        });
    }
    return sharedManager;
}

- (BOOL) getBooleanForKey: (NSString*)key
{
    NSString * value = [self getValueForKey:key];
    return [value isEqualToString:@"true"];
}

- (void)setBoolean: (BOOL)boolean forKey:(NSString*)key
{
    NSString * stringValue = boolean ? @"true" : @"false";
    [self setValue:stringValue forKey:key];
}


- (NSString *) getValueForKey: (NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}

- (void)setValue: (NSString *)value forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    DDLogVerbose(@"set new keychain value: %@=%@",key,value);
    [defaults synchronize];
}

@end
