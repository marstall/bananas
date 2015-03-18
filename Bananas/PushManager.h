//
//  PushManager.h
//  
//
//  Created by marstall on 1/5/15.
//
//

#import <Foundation/Foundation.h>
#import "Bananas.h"

@interface PushManager : NSObject
    + (BOOL)isMessageISentRecently:(NSString *)pushMessage;
    +(void)sendPushMessage:(NSString*) pushMessage forQuery:(NSDictionary*) queryDictionary;
@end
