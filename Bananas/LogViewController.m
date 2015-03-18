//
//  LogController.m
//  Bananas
//
//  Created by marstall on 12/31/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "LogViewController.h"
#import "Bananas.h"
#import "LogView.h"
#import "AppDelegate.h"
@import UIKit;

@implementation LogViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        
     //   DDLogVerbose(@"log init");
        //
    }
 
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    NSMutableAttributedString * mutableAttributedString = [self setupString];
    frame.size.height=mutableAttributedString.size.height+180;
    LogView * logView = [[LogView alloc] initWithFrame:frame];
    logView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    logView.mutableAttributedString = mutableAttributedString;
    logView.backgroundColor=[UIColor whiteColor];
//    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:logView];
//    [self.view addSubview:scrollView];
    self.scrollView.contentSize=frame.size;
}

-(NSMutableAttributedString *) setupString
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSArray * array = appDelegate.logArray;

    NSString * string = @"";
    for (int i = array.count;i--;i>=0)
    {
        NSString * elem = [array objectAtIndex:i];
        string=[NSString stringWithFormat:@"%@\n%@",string,elem];
    }

    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    para.firstLineHeadIndent = 10;
    para.headIndent = 15;
    para.paragraphSpacing=2.0;
    NSDictionary * attrs = @{
                             NSForegroundColorAttributeName:[UIColor blackColor],
                             NSParagraphStyleAttributeName:para
                             };
    NSMutableAttributedString * mutableAttributedString = [[NSMutableAttributedString alloc]
                                       initWithString:string
                                       attributes:attrs];
    return mutableAttributedString;
    
}

@end
