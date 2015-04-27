//
//  PushManager.m
//  
//
//  Created by marstall on 1/5/15.
//
//

#import "PushManager.h"

static NSMutableSet * messagesIRecentlyPushed = nil;
static int num_sent=0;

static int threshold=3;

@implementation PushManager

+ (void)clearCount
{
    num_sent=0;
}

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
    num_sent++;
    if (num_sent>threshold) return;
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
