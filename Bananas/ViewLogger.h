//
//  ViewLogger.h
//  Bananas
//
//  Created by marstall on 12/30/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/DDLog.h>

@interface ViewLogger :  DDAbstractLogger <DDLogger>

@property (nonatomic, strong) NSMutableArray * logArray;

@end

@interface ViewLoggerFormatter : NSObject <DDLogFormatter>

@end