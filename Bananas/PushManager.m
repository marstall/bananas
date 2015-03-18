//
//  PushManager.m
//  
//
//  Created by marstall on 1/5/15.
//
//

#import "PushManager.h"

static NSMutableSet * messagesIRecentlyPushed = nil;

@implementation PushManager

+ (BOOL)isMessageISentRecently:(NSString *)pushMessage
{
    if (!messagesIRecentlyPushed) return NO;
    if ([messagesIRecentlyPushed containsObject:pushMessage])
    {
        [messagesIRecentlyPushed removeObject:pushMessage];
        return YES;
    }
    else
    {
        return NO;
        
    }
}

+ (void)sendPushMessage:(NSString*) pushMessage forQuery:(NSDictionary*) queryDictionary
{
    if (!messagesIRecentlyPushed) messagesIRecentlyPushed=[NSMutableSet set];
    [messagesIRecentlyPushed addObject:pushMessage];
    NSString * key = queryDictionary.allKeys.firstObject;
    NSString * value = [queryDictionary valueForKey:key];
//    DDLogVerbose(@"sending push: %@",pushMessage);
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:key equalTo:value];

    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushMessage, @"alert",
                          @"Increment", @"badge",
                          nil];
    [push setData:data];
//    [push setMessage:pushMessage];
    [push sendPushInBackground];
}
@end
