//
//  ListViewController.m
//  Bananas
//
//  Created by marstall on 12/18/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "ListViewController.h"
#import "CoreDataManager.h"
@import CoreData;
#import "MultipeerManager.h"
#import "Item.h"
#import "AppDelegate.h"
#import "KeychainManager.h"
#import "UserDefaultsManager.h"
#import "SettingsController.h"
#import "LogViewController.h"
#import "Bananas.h"

@interface ListViewController()
@end

@implementation ListViewController


- (void)viewWillAppear:(BOOL)animated
{
    self.cellBeingEdited=nil;
    self.textFieldShouldBecomeFirstResponder=NO;
    self.didInitiateMultipeerSession=NO;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    observe(self, @selector(keyboardShow:), UIKeyboardWillShowNotification);
    observe(self, @selector(keyboardHide:), UIKeyboardWillHideNotification);
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.cellBeingEdited=nil;
        self.textFieldShouldBecomeFirstResponder=NO;
        self.didInitiateMultipeerSession=NO;
        
        self.navigationItem.title = @"bananas";
        
        
//        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        [self doSetToolBarItems:NO];
        // load the items into an array
        // 1. load model file.
        self.items = Item.allItems;
        
        MultipeerManager * multipeerManager = [MultipeerManager sharedManager];
        MCPeerID *peerId = [multipeerManager setupPeerWithDisplayName:[UIDevice currentDevice].name];
        MCSession * session = [multipeerManager setupSession:peerId withDelegate:(id<MCSessionDelegate>)self] ;
        self.browserViewController = [multipeerManager setupBrowser:session];
        self.browserViewController.maximumNumberOfPeers=1;
        self.browserViewController.delegate=self;
        [multipeerManager advertiseSelf:YES withSession:session];
        
        observe(self, @selector(sync:), kPerformSyncNotification);
        observe(self, @selector(refreshUI:), kRefreshListUI);
    }
    return self;
}



- (void)doSetToolBarItems: (BOOL) syncActive
{
    UIBarButtonItem * connectionButton = nil;
    if (syncActive)
    {
        connectionButton = [[UIBarButtonItem alloc] initWithTitle:@"sharing" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
    }
    else
    {
        connectionButton = [[UIBarButtonItem alloc]
                            initWithTitle:@"invite someone!" style:UIBarButtonItemStylePlain target:self action:@selector(share:)
                                         ];
    }
    UIBarButtonItem *syncButton =  [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                        target:self action: @selector(sync_pressed:)
                        ];
    [syncButton setEnabled:syncActive];
    
    if (self.shouldShowDoneItems) [self setHideDoneItemsButton];
    else [self setShowDoneItemsButton];
    if (!self.doneItemsButton && syncActive)
    {
        self.doneItemsButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"show done items"
                                style:UIBarButtonItemStylePlain target:self
                                action:@selector(hideDoneItems:)
                        ];
    }
    self.doneItemsButton.tintColor=UIColorFromRGB(0x777777);
    UIBarButtonItem * space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if (self.doneItemsButton)
        self.toolbarItems=@[self.doneItemsButton,space,connectionButton];
    else
        self.toolbarItems=@[space,connectionButton];
}



- (IBAction)settings:(id)sender
{
    // create a controller
    SettingsController * settingsController = [[SettingsController alloc] init];

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(done:)];
    settingsController.navigationItem.rightBarButtonItem = doneItem;


    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:settingsController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    settingsController.edgesForExtendedLayout = UIRectEdgeNone;

    settingsController.navigationItem.title=@"Sharing";
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sync_pressed:(id)sender
{
    return [self sync:sender];
}

- (IBAction)refreshUI:(id)sender
{
    self.items = [__backend allItems];
    [self.tableView reloadData];
}

- (IBAction)sync:(id)sender
{
    [self doSetToolBarItems:[__backend isSharing]];
    [__backend sync];
}

- (void) setHideDoneItemsButton
{
    self.doneItemsButton.title=@"hide done items";
    self.doneItemsButton.action=@selector(hideDoneItems:);
    [self.doneItemsButton setEnabled:YES];

}

- (void) setShowDoneItemsButton
{
    self.doneItemsButton.title=@"show done items";
    self.doneItemsButton.action=@selector(showDoneItems:);
    [self.doneItemsButton setEnabled:YES];
}

- (void) deactivateDoneItemsButton
{
    [self.doneItemsButton setEnabled:NO];
}

- (IBAction)showDoneItems:(id)sender
{
    self.shouldShowDoneItems=YES;
    [__backend event:CLICK dimensions:@{BUTTON_TEXT:@"show_done_items"}];

    [__backend syncWithDoneItems:YES AndBlock:^{
        [self setHideDoneItemsButton];
    }];
    // deactivate button
    [self deactivateDoneItemsButton];
}

- (IBAction)hideDoneItems:(id)sender
{
    self.shouldShowDoneItems=NO;
    [__backend event:CLICK dimensions:@{BUTTON_TEXT:@"hide_done_items"}];

    [__backend syncWithDoneItems:NO AndBlock:^{
        [self setShowDoneItemsButton];
    }];
    [self deactivateDoneItemsButton];

}

- (IBAction)share:(id)sender
{
    [__backend event:CLICK dimensions:@{BUTTON_TEXT:@"share"}];
    
    // show explanation prompt
    NSString * msg = @"The person you're inviting should have the Bananas app launched on their iPhone and be in the same room as you.";
    if ([UIAlertController class])
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Invite to connect"            message:msg
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * disconnectAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler: ^(UIAlertAction * alertAction){
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          [self showShareScreen];
                                                                      });}];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * alertAction){
        }];
        
        [alertController addAction:disconnectAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self showShareScreen];
    }
}

- (void)showShareScreen
{
    //show browser controller window
    if (self.browserViewController)
    {
        [self presentViewController:self.browserViewController animated:YES completion:nil];
        self.didInitiateMultipeerSession=YES;
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // find the position value of previous item
    // find the position value of next item
    // divide them in half
    // set that as the position value
    NSUInteger destinationRow = destinationIndexPath.row;
    NSUInteger sourceRow = sourceIndexPath.row;
    
    Item * item = [self.items objectAtIndex:sourceRow];
    
    NSInteger previousRow = destinationRow-1;
    NSInteger nextRow = destinationRow+1;
    float newPosition=0;
    if (previousRow<0)
    {
        newPosition=[[self.items.firstObject valueForKey:@"position"] floatValue]-1.0;
    }
    else if (nextRow>=self.items.count)
    {
        newPosition=[[self.items.lastObject valueForKey:@"position"] floatValue]+1.0;
    }
    else
    {
        float prevPosition = [[[self.items objectAtIndex:previousRow] valueForKey:@"position"] floatValue];
        float nextPosition = [[[self.items objectAtIndex:nextRow] valueForKey:@"position"] floatValue];
        
        newPosition = (prevPosition+nextPosition)/2.0;
    }
    [item setValue:[NSNumber numberWithFloat:newPosition] forKey:@"position"];
    item.shouldSendPush=false;
    item.shouldUpdateRemoteCopy=false;
    [CoreDataManager save];
    self.items=Item.allItems;
    [self.tableView reloadData];
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger cnt = self.items.count;
    if (row==cnt) // final row selected, make textField the receiver
    {
        [self.textField becomeFirstResponder];
        self.textField.superview.backgroundColor=[UIColor whiteColor];
        self.cellBeingEdited=[self.tableView cellForRowAtIndexPath:indexPath];
        //        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop

        return;
    }
    if (indexPath.row>=self.items.count) return;
    Item * item = self.items[indexPath.row];
    NSString * status = [item valueForKey:@"status"];
    NSString * newStatus = @"done";
    if ([status isEqualToString:@"done"])
     {
         newStatus = @"active";
     }
    [item setValue:newStatus forKey:@"status"];
    [item setValue:[NSDate date] forKey:@"status_changed_at"];

    item.shouldSendPush=true;
    item.shouldUpdateRemoteCopy=YES;
    [CoreDataManager save];
    [self.tableView reloadData];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField        // return NO to disallow editing.
{
    self.textField = textField;
 /*   CGRect rect = [textField frame];
    CGRect absRect = [self.tableView convertRect:rect fromView:self.cellBeingEdited.contentView];
    absRect.origin.x=0;
    absRect.origin.y+=self.cellBeingEdited.bounds.size.height;
    [[self tableView] setContentOffset:absRect.origin];*/
    return YES;
}
/*
 height of window is 568
 height of viewable area is 568
 height of scrollable area is either greater than, equal to or less than 568. can be any value.
 
 top of cell is x
 should set x to around 150.
 if x=175, set x = x- (x-150); # x is 150
 if x=125 set x = x- (x-150) @ x is 150
 
*/

// scroll text field so it is 250 px from the top
- (void)keyboardShow: (NSNotification*) n
{
    NSDictionary* d = [n userInfo];
    CGRect keyboardRect = [d[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    keyboardRect = [[self tableView] convertRect:keyboardRect fromView:nil];
    int topOfKeyboard=keyboardRect.origin.y;
    int desiredHeightOfTextField = topOfKeyboard/2;
    CGRect textFieldRectOriginal = [self.textField frame];
    CGRect textFieldRect;
    if (textFieldRectOriginal.origin.y<16) // hack for new-item entry field
    {
        textFieldRect = [self.tableView convertRect:textFieldRectOriginal fromView:self.cellBeingEdited.contentView];
    }
    else
    {
        textFieldRect = textFieldRectOriginal;
    }
    int topOfTextFieldYPosition = textFieldRect.origin.y;
    
    int amountToOffsetY= topOfTextFieldYPosition-desiredHeightOfTextField;
    CGPoint offset = CGPointMake(0, amountToOffsetY);
    if (amountToOffsetY>0) [self.tableView setContentOffset:offset];
}


- (void)keyboardHide: (NSNotification*) n
{
    
}


- (void) tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // remove item from in-memory array
        [self deleteItemAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>=self.items.count) return NO;
    else return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count+1; // add one for the "add new" cell
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[ItemTableViewCell alloc] initWithIndexPath:indexPath controller:self];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    self.didInitiateMultipeerSession=NO;
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteItemAtIndexPath:(NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    if (row>=self.items.count) return;
    Item * item = [self.items objectAtIndex:row];
    item.shouldUpdateRemoteCopy=YES;
    [__backend event:ITEM_DELETE dimensions:@{ITEM_TEXT:[item valueForKey:@"text"]}];
    [self.items removeObject:item];
    
    // remove item from database
    [CoreDataManager removeObject:item];

    // tell table view to delete the row
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    notify(kRefreshListUI);
}

 - (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        self.textFieldShouldBecomeFirstResponder=NO;
        [self.tableView reloadData];
        return YES;
    }
    
    [textField endEditing:YES];
    NSInteger row = ((ItemTableViewCell*)self.cellBeingEdited).indexPath.row;
    NSInteger count = self.items.count;
    if (row==count)
    {
        NSInteger ind = self.items.count;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:ind inSection:0];
        if ([textField.text isEqualToString:@""]) return NO;
        Item * item = [Item create:textField.text withUUID:nil];
        item.shouldUpdateRemoteCopy=YES;
        [__backend event:ITEM_ADD dimensions:@{ITEM_TEXT:[item valueForKey:@"text"]}];

//        [self.tableView reloadData];
        [self.items addObject:item ];
        self.textFieldShouldBecomeFirstResponder=YES;
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
    else
    {
        ItemTableViewCell* cellBeingEdited = (ItemTableViewCell*)self.cellBeingEdited;
        NSString * text = textField.text;
        NSInteger ind = ((ItemTableViewCell *)self.cellBeingEdited).indexPath.row;
        Item * item = [self.items objectAtIndex:ind];
        if ([text isEqualToString:@""]&&cellBeingEdited!=nil)
        {
            //           [self deleteItemAtIndexPath:cellBeingEdited.indexPath];
        }
        else
        {
            [item setValue:textField.text forKey:@"text"];
            item.shouldUpdateRemoteCopy=YES;
            item.shouldSendPush=YES;
            [__backend event:ITEM_EDIT dimensions:@{ITEM_TEXT:[item valueForKey:@"text"]}];

        }
        
    }
    [self.tableView reloadData];
    [CoreDataManager save];

    return NO;
}

- (void)dealloc
{
    remove_observer(self);
}
@end
