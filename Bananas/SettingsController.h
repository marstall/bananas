//
//  SettingsController.h
//  Bananas
//
//  Created by marstall on 12/31/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface SettingsController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *wipeUUIDButton;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UISwitch *disconnectSwitch;

@end
