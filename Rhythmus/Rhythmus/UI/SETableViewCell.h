//
//  SETableViewCell.h
//  Rhythmus
//
//  Created by Admin on 14/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SETableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,copy) void(^buttonBlock)(void);

@end
