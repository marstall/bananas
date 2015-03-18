//
//  ItemTableViewCell.m
//  Bananas
//
//  Created by marstall on 1/5/15.
//  Copyright (c) 2015 Two Pines. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "Bananas.h"

@implementation ItemTableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath*)indexPath controller:(ListViewController*)controller
{
    self.controller = controller;
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
    if (self)
    {
        // retrieve the nth element of the items array, set the cell.textLabel.text to the element's text value
        NSInteger ind = indexPath.row;
        if (ind<controller.items.count)
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
                                        value:@1
                                        range:NSMakeRange(0, [attributeString length])];
                self.textLabel.textColor = [UIColor grayColor];
                self.textLabel.attributedText = attributeString;
            }
            self.textLabel.text = text;
        }
        else if (ind==controller.items.count)
        {
            UITextField * textField = [[UITextField alloc] initWithFrame:self.frame];
            textField.delegate = self.controller;
            controller.textField = textField;
            textField.translatesAutoresizingMaskIntoConstraints=NO;
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
            if (controller.textFieldShouldBecomeFirstResponder)
            {
                textField.becomeFirstResponder;
//                controller.textFieldShouldBecomeFirstResponder=NO;
            }
            

        }
    }
    return self;
}
@end
