//
//  ListViewController.m
//  Bananas
//
//  Created by marstall on 12/18/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "ListViewController.h"
#import "EditItemViewController.h"
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


- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.textFieldShouldBecomeFirstResponder=NO;
        self.didInitiateMultipeerSession=NO;
        
        self.navigationItem.title = NSLocalizedString(@"Bananas", "@Bananas page title");
        
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
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
        connectionButton = [[UIBarButtonItem alloc] initWithTitle:@"Sharing" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
//        UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:18.0];
//        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              f1, NSFontAttributeName,
//                              
//                              nil];
//        [connectionButton setTitleTextAttributes:dict forState:UIControlStateNormal];
    }
    else
    {
        connectionButton = [[UIBarButtonItem alloc]
                            initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(share:)
                                         ];
    }
    UIBarButtonItem *syncButton =  [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                        target:self action: @selector(sync_pressed:)
                        ];
    [syncButton setEnabled:syncActive];
    self.navigationItem.rightBarButtonItem=connectionButton;

}

- (IBAction)enterEditMode:(id)sender
{
    
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

    settingsController.navigationItem.title=@"Settings";
    [self presentViewController:navController animated:YES completion:nil];
    // add view to controller
    // display text on view?
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
    self.items = [backend allItems];
    [self.tableView reloadData];

}

- (IBAction)sync:(id)sender
{
    [self doSetToolBarItems:[backend isSharing]];
    [backend sync];
}

- (IBAction)share:(id)sender
{
    DDLogVerbose(@"Share!");
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger cnt = self.items.count;
    if (row==cnt) // final row selected, make textField the receiver
    {
        [self.textField becomeFirstResponder];
        self.textField.superview.backgroundColor=[UIColor whiteColor];
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
    item.shouldSendPush=true;
    item.shouldUpdateRemoteCopy=YES;
    [CoreDataManager save];
    [self.tableView reloadData];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void) tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // remove item from in-memory array
        if (indexPath.row>=self.items.count) return;
        Item * item = self.items[indexPath.row];
        item.shouldUpdateRemoteCopy=YES;
        [self.items removeObject:item];

        // remove item from database
        [CoreDataManager removeObject:item];
        // tell table view to delete the row
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DDLogVerbose(@"finished editing with '%@'",textField.text);
    if ([textField.text isEqualToString:@""]) return;
    Item * item = [Item create:textField.text withUUID:nil];
    item.shouldUpdateRemoteCopy=YES;
    [self.tableView reloadData];
    [self.items addObject:item ];
    [CoreDataManager save];
//    notify(kRefreshListUI);
}


// so instead of reloading the table when the user presses enter,
// we should manually 'stich' onto the existing table ... close up the current table row and add a new one,
// making it the first responder.

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        self.textFieldShouldBecomeFirstResponder=NO;
        [self.tableView reloadData];
        return YES;
    }

    [textField endEditing:YES];
    
    NSInteger ind = self.items.count;
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:ind inSection:0];
        self.textFieldShouldBecomeFirstResponder=YES;
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    [self.tableView reloadData];

    return NO;
}

- (void)dealloc
{
    remove_observer(self);
}
@end