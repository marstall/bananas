//
//  LogController.h
//  Bananas
//
//  Created by marstall on 12/31/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface LogViewController : UIViewController

@property (strong, nonatomic) NSMutableAttributedString * mutableAttributedString;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
