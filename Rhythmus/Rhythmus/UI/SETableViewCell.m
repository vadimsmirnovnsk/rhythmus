//
//  SETableViewCell.m
//  Rhythmus
//
//  Created by Admin on 14/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SETableViewCell.h"

@interface SETableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectButton;
- (IBAction)select:(id)sender;

@end

@implementation SETableViewCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [[UIColor purpleColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
    if(selected == YES){
        [UIView animateWithDuration:0.2 animations:^{
            self.selectButton.hidden = NO;
            [self setBackgroundColor:[UIColor darkGrayColor]];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectButton.hidden = YES;
            [self setBackgroundColor:[UIColor lightGrayColor]];
        }];
    }
}

- (IBAction)select:(id)sender {
    self.buttonBlock();
}

@end
