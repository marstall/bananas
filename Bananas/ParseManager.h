//
//  ParseManager.h
//  Bananas
//
//  Created by marstall on 1/16/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

static NSString * const PARSE_APPLICATION_ID=@"sWeVUikcOz1sL2EJIfgMnmAgwpF4Zq8cWW8CVZg1";
static NSString * const PARSE_CLIENT_KEY=@"jIw9gPqHIiNry3NB0d70qf2EqHvxchWUxwXlIU5H";

@interface ParseManager : NSObject
- (void)initParseWithLaunchOptions:(NSDictionary*)launchOptions andApplication:(UIApplication * )application;
- (void)updatePushDeviceToken:(NSData*)deviceToken;
- (void)event:(NSString *) name dimensions:(NSDictionary *)dimensions;
@end
