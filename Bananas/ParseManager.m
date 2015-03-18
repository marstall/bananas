//
//  ParseManager.m
//  Bananas
//
//  Created by marstall on 1/16/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "ParseManager.h"

@implementation ParseManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)initParseWithLaunchOptions:(NSDictionary*)launchOptions andApplication:(UIApplication * )application
{
    [Parse enableLocalDatastore];
    // Initialize Parse.
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (void)updatePushDeviceToken:(NSData*)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
}

@end
