//
//  MultipeerManager.m
//  Bananas
//
//  Created by marstall on 12/23/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "MultipeerManager.h"
#import "Bananas.h"

const NSString * SERVICE_TYPE = @"Bananas";

@implementation MultipeerManager

+ (instancetype)sharedManager
{
    static MultipeerManager * sharedManager;
    if (!sharedManager)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^(void){
            sharedManager = [[MultipeerManager alloc] init];
        });
    }
    return sharedManager;
}

- (MCPeerID *)setupPeerWithDisplayName:(NSString *) displayName
{
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    return self.peerID;
}

- (MCSession *)setupSession:(MCPeerID *) peerID withDelegate:(id<MCSessionDelegate>) delegate
{
    self.session = [[MCSession alloc] initWithPeer:peerID];
    self.session.delegate = delegate;
    return self.session;
}

- (MCBrowserViewController *)setupBrowser:(MCSession *)session
{
    self.browserViewController = [[MCBrowserViewController alloc] initWithServiceType:(NSString*)SERVICE_TYPE session:session];
    return self.browserViewController;
}

- (MCAdvertiserAssistant*)advertiseSelf:(BOOL)advertise withSession: (MCSession *)session
{
    if (advertise)
    {
        self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:(NSString*)SERVICE_TYPE discoveryInfo:nil session:session];
        [self.advertiserAssistant start];
        return self.advertiserAssistant;
    }
    else
    {
        [self.advertiserAssistant stop];
        self.advertiserAssistant = nil;
        return nil;
    }
}

- (void)disconnect
{
    [self.session disconnect];
}

@end
