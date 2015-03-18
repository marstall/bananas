//
//  LogView.h
//  Bananas
//
//  Created by marstall on 12/31/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface LogView: UIView

@property (nonatomic, strong) NSString * text;
@property (strong, nonatomic) NSMutableAttributedString * mutableAttributedString;

@end
