//
//  ItemTableViewCell.m
//  Bananas
//
//  Created by marstall on 1/5/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "Bananas.h"
#import "Backend.h"
@import UIKit;

@implementation ItemTableViewCell


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state]!=UIGestureRecognizerStateBegan) return;
    [self handleEditAction];

    return;
}

-(void)handleDeleteAction:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSInteger row = self.indexPath.row;
    Item * item = self.controller.items[row];
    item.shouldUpdateRemoteCopy=YES;
    [self.controller.items removeObject:item];

    // remove item from database
    [CoreDataManager removeObject:item];
    // tell table view to delete the row
    [self.controller.tableView deleteRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.controller.tableView reloadData];

}

- (void) handleEditAction
{
    [self enterEditMode:true];

}

- (instancetype)initWithIndexPath:(NSIndexPath*)indexPath controller:(ListViewController*)controller
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];

    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
    
    self.controller = controller;
    self.indexPath = indexPath;
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
    if (self)
    {
        // retrieve the nth element of the items array, set the cell.textLabel.text to the element's text value
        NSInteger ind = indexPath.row;
        if (ind<backend.allItems.count)
        {
            Item * item = (Item *)[controller.items objectAtIndex:ind];
            NSString * status = [item valueForKey:@"status"];
            NSString * text =  [item valueForKey:@"text"];
            if (item.isNewOrChanged)
            {
                self.backgroundColor=UIColorFromRGB(0xffffcc);
                self.contentView.backgroundColor=UIColorFromRGB(0xffffcc);
                [UIView animateWithDuration:1.0 animations:^{
                    self.backgroundColor=[UIColor clearColor];
                    self.contentView.backgroundColor=[UIColor clearColor];
                }];
                item.isNewOrChanged=NO;
            }
            if ([status isEqualToString:@"done"])
            {
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
                [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                        value:[NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle]
                                        range:NSMakeRange(0, [attributeString length])];
                self.textLabel.textColor = [UIColor grayColor];
                self.textLabel.attributedText = attributeString;
            }
            self.textLabel.text = text;
        }
        else if (ind==controller.items.count)
        {
            [self enterEditMode:false];
        }
    }
    return self;
}

- (void) enterEditMode: (Boolean)becomeFirstResponder
{
    // constructs the UITextfield, sets it to self.controller.textfield, applies constraint makes it the first responder
//    [self.controller.textField resignFirstResponder]; // if there is one with existing focus, unfocus it
    UITextField * textField = [[UITextField alloc] initWithFrame:self.frame];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self.controller;
    if (self.textLabel.text)
    {
        textField.text=[NSString stringWithString:self.textLabel.text];
    }
    self.controller.textField = textField;
    self.controller.cellBeingEdited=self;

    self.textLabel.hidden=YES;
    self.textLabel.text=@"";

    textField.translatesAutoresizingMaskIntoConstraints=NO;
    
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.contentView addSubview:textField];

    NSDictionary *dict = @{@"textField":textField};
    NSArray *layoutConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[textField]-15-|"
                                            options:0 metrics:nil views:dict];
    [self.contentView addConstraints:layoutConstraints];
    layoutConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[textField]-11-|"
                                            options:0 metrics:nil views:dict];
    [self.contentView addConstraints:layoutConstraints];
    if (self.controller.textFieldShouldBecomeFirstResponder||becomeFirstResponder)
    {
        textField.becomeFirstResponder;
        //                controller.textFieldShouldBecomeFirstResponder=NO;
    }
}
@end
