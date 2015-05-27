//
//  Bananas.m
//  Bananas
//
//  Created by marstall on 1/4/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "Bananas.h"


NSString * makeUUIDTag(NSString * uuidString)
{
    if (!uuidString) return uuidString;
    if (uuidString.length<4) return uuidString;
    NSString * beginning = [uuidString substringWithRange:NSMakeRange(0,2) ];
    NSString * end = [uuidString substringWithRange:NSMakeRange(uuidString.length-2, 2) ];
    return [NSString stringWithFormat:@"%@-%@",beginning,end];
}

void notify(NSString * notification)
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:notification object:nil]];
}

void observe(NSObject *id, SEL selector, NSString * notification)
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:id
           selector:selector
               name:notification object:nil];
}

void remove_observer(NSObject * id)
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:id];
}

NSString * sha1(NSString * s)
{
    if (!s) return s;
    const char * cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char buffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cstr, strlen(cstr), buffer);
    NSMutableString * ret = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
    for (int i=0;i<CC_SHA1_DIGEST_LENGTH;++i)
        [ret appendFormat:@"%02x",buffer[i]];
    return ret;
}
/*
NSString * enumerate_methods(NSObject * obj)
{
    int i=0;
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(object_getClass(obj), &mc);
    NSString * str = [[NSString alloc] initWithFormat:@"%d methods", mc ];
    for(i=0;i<mc;i++)
    {
        char* s = sel_getName(method_getName(mlist[i]));
        NSString* _s = [[NSString alloc] initWithFormat:@" %s",s];
        str = [str stringByAppendingString:_s];
        NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
    }
    return str;
}

*/

