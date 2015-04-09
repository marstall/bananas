//
//  ListViewController+MCDelegate.m
//  Bananas
//
//  Created by marstall on 12/24/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "ListViewController+MCDelegate.h"
#import "MultipeerManager.h"
#import "KeychainManager.h"
#import "UserDefaultsManager.h"
#import "Bananas.h"
#import "AppDelegate.h"



@implementation ListViewController (MCDelegate)

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    //    NSDictionary * dict
    DDLogVerbose(@"MC change state");
    if (state==MCSessionStateConnected)
    {
        MCPeerID* peer = [[session connectedPeers] firstObject];
        NSString * displayName = [peer displayName];
        NSString * listUUID = [backend listUUID];
/*        if (!listUUID)
        {
            listUUID = [backend resetListUUID];
        }*/
        if (self.didInitiateMultipeerSession) // only initiator sends peerID
        {
            DDLogVerbose(@"#display successfully initiated connection (with my listUUID %@)",makeUUIDTag(listUUID));
            NSData * data = [listUUID dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            [session sendData:data toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
//            [backend startSharing];
            self.didInitiateMultipeerSession=NO; // clear out this flag for next time in cases of connecting and reconnecting within a session

        }
        else
        {
            DDLogVerbose(@"#display successfully accepted connection with %@",displayName);
        }
        [[UserDefaultsManager sharedManager] setBoolean:YES forKey:@"connected"];
        [[UserDefaultsManager sharedManager] setValue:displayName forKey:@"peerIAmConnectedTo"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doSetToolBarItems:YES];
        });

        // register for push applications now
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
        
//        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                        UIUserNotificationTypeBadge |
//                                                        UIUserNotificationTypeSound);
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                                 categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString * uuidString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DDLogInfo(@"#display received new listUUID %@ via multipeer",makeUUIDTag(uuidString));

        [backend setListUUID:uuidString];
        [backend startSharing];
    });

}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

@end
