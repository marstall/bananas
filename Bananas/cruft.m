//
//  cruft.m
//  Bananas
//
//  Created by marstall on 2/8/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
setting title bar colors: 
     UIColor * yellow = UIColorFromRGB(0xf8e211);
     UIColor * orange = UIColorFromRGB(0xfc7702);
     UIColor * red = UIColorFromRGB(0xff000f);
     UIColor * black = UIColorFromRGB(0x000000);
  UIColor * grey = UIColorFromRGB(0x707070);
 
     [[UINavigationBar appearance] setBackgroundColor:yellow];
     [[UINavigationBar appearance] setTintColor:grey];
     [[UINavigationBar appearance] setTranslucent:NO];
 
 
     NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                grey,NSForegroundColorAttributeName,
                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
 
     [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
 
*/

/*
 if ([UIAlertController class])
 {
 UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil              message:nil
 preferredStyle:UIAlertControllerStyleActionSheet];
 UIAlertAction * editAction = [UIAlertAction actionWithTitle:@"Edit"
 style:UIAlertActionStyleDefault
 handler: ^(UIAlertAction * alertAction){
 dispatch_async(dispatch_get_main_queue(), ^{
 [self handleEditAction];
 });}];
 UIAlertAction * reminderAction = [UIAlertAction actionWithTitle:@"Send reminder"
 style:UIAlertActionStyleDefault
 handler: ^(UIAlertAction * alertAction){
 dispatch_async(dispatch_get_main_queue(), ^{
 //
 });}];
 UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:@"Delete"
 style:UIAlertActionStyleDestructive
 handler: ^(UIAlertAction * alertAction){
 dispatch_async(dispatch_get_main_queue(), ^{
 [self handleDeleteAction];
 });}];
 UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * alertAction){
 }];
 
 [alertController addAction:editAction];
 [alertController addAction:reminderAction];
 [alertController addAction:deleteAction];
 [alertController addAction:cancelAction];
 [self.controller presentViewController:alertController animated:YES completion:nil];
 }
 else
 {
 UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit",@"Send reminder", nil];
 [actionSheet showInView:self.contentView];
 }*/

/*    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:
 @selector(handleDeleteAction:)];
 
 recognizer.direction = UISwipeGestureRecognizerDirectionRight;
 recognizer.numberOfTouchesRequired = 1;
 [self addGestureRecognizer:recognizer];
 */

/*    CGRect tableViewBounds = [[self tableView] bounds];
 CGRect tableViewFrame = [[self tableView] frame];
 CGRect viewFrame = [[self view] frame];
 CGRect viewBounds = [[self view] bounds];
 CGRect cellBeingEditedFrameRect = self.cellBeingEdited.frame;
 CGRect cellBeingEditedBoundsRect = self.cellBeingEdited.bounds;
 CGRect superViewFrame = self.view.superview.frame;
 CGRect superViewBounds = self.view.superview.bounds;
*/
