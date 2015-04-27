//
//  ItemTableViewCell.h
//  Bananas
//
//  Created by marstall on 1/5/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bananas.h"
@import UIKit;

@interface ItemTableViewCell : UITableViewCell <UIActionSheetDelegate>

@property (nonatomic, strong) ListViewController * controller;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (instancetype)initWithIndexPath:(NSIndexPath*)indexPath controller:(ListViewController*)controller;
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex;
@end
