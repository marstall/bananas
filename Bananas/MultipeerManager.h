//
//  MultipeerManager.h
//  Bananas
//
//  Created by marstall on 12/23/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MultipeerManager : NSObject

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;

+ (instancetype)sharedManager;

- (MCPeerID *)setupPeerWithDisplayName:(NSString *) displayName;
- (MCSession *)setupSession:(MCPeerID *) peerID withDelegate:(<MCSessionDelegate>) delegate;
- (MCBrowserViewController *)setupBrowser:(MCSession *)sessionID;
- (MCAdvertiserAssistant*)advertiseSelf:(BOOL)advertise withSession: (MCSession *)session;
- (void)disconnect;



@end
