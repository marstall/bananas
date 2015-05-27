//
//  SettingsController.m
//  Bananas
//
//  Created by marstall on 12/31/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "SettingsController.h"
#import "Bananas.h"
@import UIKit;

@implementation SettingsController
- (IBAction)wipeUUIDButtonClicked:(id)sender
{

}
- (IBAction)activityClicked:(id)sender
{

    LogViewController * logController = [[LogViewController alloc] init];

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(done:)];
    logController.navigationItem.rightBarButtonItem = doneItem;

    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:logController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    logController.edgesForExtendedLayout = UIRectEdgeNone;
    
    logController.navigationItem.title=@"Recent activity";
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)disconnectSwitchValueChanged:(id)sender
{
    BOOL on = self.disconnectSwitch.on;
    if (!on)
    {
        NSString * displayName = [[UserDefaultsManager sharedManager] getValueForKey:@"peerIAmConnectedTo"];
        NSString * msg = [NSString stringWithFormat:@"Do you want to disconnect from %@? You will lose your current list.",displayName];
        if ([UIAlertController class])
        {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Warning"            message:msg
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * disconnectAction = [UIAlertAction actionWithTitle:@"Disconnect"
                                                style:UIAlertActionStyleDestructive
                                                handler: ^(UIAlertAction * alertAction){
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                [self setupUUIDLabel];
                [__backend resetListUUID];
                [[BananasParseManager sharedManager] setupParseUser];
                notify(kRefreshListUI);
                notify(kPerformSyncNotification);
                // send push to delete listUUID on the other side
                // [PushManager sendPushMessage:@"List deleted" forQuery:@{@"listUUID":listUUID}];
            });}];
            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * alertAction){
                [self.disconnectSwitch setOn:YES];
            }];
            
            [alertController addAction:disconnectAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Disconnect", nil];
            
            [alert show];
        }
    }
    else
    {
        DDLogVerbose(@"on");
        [self.disconnectSwitch setOn:NO];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        
        //User clicked cancel
        DDLogVerbose(@"#display cancel clicked.");
        [self.disconnectSwitch setOn:YES];
    }
    else
    {
        [self setupUUIDLabel];
        [__backend resetListUUID];
        [[BananasParseManager sharedManager] setupParseUser];
        notify(kRefreshListUI);
        notify(kPerformSyncNotification);
        DDLogVerbose(@"#display ok clicked.");
    }
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Activity" style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(activityClicked:)];
    self.navigationItem.leftBarButtonItem  = activityItem;

    
    UIColor *color = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.uuidLabel.layer.borderColor=[color CGColor];

    [self setupUUIDLabel];
}

- (void) setupUUIDLabel
{
    NSString * listUUID = [[KeychainManager sharedManager] getValueForKey:@"listUUID"];
    if (!listUUID) listUUID = @"nil";
    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    para.firstLineHeadIndent = 10;
    NSDictionary * attrs = @{
                             NSForegroundColorAttributeName:[UIColor blackColor],
                             NSFontAttributeName:[UIFont systemFontOfSize:16.0],
                             NSParagraphStyleAttributeName:para
                             };
    NSString * displayName = [[UserDefaultsManager sharedManager] getValueForKey:@"peerIAmConnectedTo"];
    if (!displayName) displayName = @"NONE";
    NSMutableAttributedString * mutableAttributedString = [[NSMutableAttributedString alloc]
                                                           initWithString:displayName
                                                           attributes:attrs];
    self.uuidLabel.attributedText = mutableAttributedString;
}


@end
