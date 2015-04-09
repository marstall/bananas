//
//  ViewLogger.m
//  Bananas
//
//  Created by marstall on 12/30/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "ViewLogger.h"
#import "AppDelegate.h"
#import "Bananas.h"

@implementation ViewLogger

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->formatter = [ViewLoggerFormatter new];
    }
    return self;
}

/*
+ (instancetype)sharedViewLogger
{
    static ViewLogger * sharedViewLogger;
    if (!sharedViewLogger)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^(void){
            sharedViewLogger = [[ViewLogger alloc] init];
        });
    }
    return sharedViewLogger;
}
*/

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->logMsg;
    
    if (self->formatter)
        logMsg = [self->formatter formatLogMessage:logMessage];
    
    if (logMsg)
    {
        // Write logMsg to wherever...
/*        int max_length =1000;
        // trim array back to last 500 if it goes over 1000
        if ([self.logArray count]>max_length)
        {
            NSArray * newArray =
                [self.logArray subarrayWithRange:NSMakeRange([self.logArray count]-max_length/2 , max_length)];
            [self.logArray removeAllObjects];
            self.logArray = [[NSMutableArray alloc] initWithArray:newArray];
        }*/
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

        [appDelegate.logArray addObject:logMsg];
        
    }
}

@end

@implementation ViewLoggerFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->logMsg;
    NSString * newString =[logMsg stringByReplacingOccurrencesOfString:@"#display" withString:@""];
    if (newString.length!=logMsg.length) // a replacement was made
    {
#ifdef DEBUG_LISTUUID
        NSString * listUUID = makeUUIDTag([[KeychainManager sharedManager] getValueForKey:@"listUUID"]);
        newString = [NSString stringWithFormat:@"%@:%@",listUUID,newString];
#endif
        return newString;
    }
    else
    {
        return nil;
    }

}

@end

