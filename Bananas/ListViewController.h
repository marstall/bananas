//
//  ListViewController.h
//  Bananas
//
//  Created by marstall on 12/18/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import <UIKit/UIKit.h>


@import MultipeerConnectivity;

@interface ListViewController : UITableViewController <MCBrowserViewControllerDelegate, UITextFieldDelegate>

@property(nonatomic, strong) NSMutableArray * items;
@property(nonatomic, strong) NSManagedObjectContext *context;
@property(nonatomic, retain) UIRefreshControl *refreshControl;
@property(nonatomic, retain) UIBarButtonItem * doneItemsButton;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UITableViewCell * cellBeingEdited;
@property BOOL didInitiateMultipeerSession;
@property BOOL shouldShowDoneItems;

- (void) setHideDoneItemsButton;
- (void) setShowDoneItemsButton;
- (void) deactivateDoneItemsButton;


@property BOOL textFieldShouldBecomeFirstResponder;

- (void)doSetToolBarItems: (BOOL) syncActive;

- (IBAction)sync_pressed:(id)sender;

- (IBAction)sync:(id)sender;

- (IBAction)share:(id)sender;

- (void)deleteItemAtIndexPath:(NSIndexPath*) indexPath;

@end
