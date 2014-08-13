//
//  SelectDurationViewController.m
//  Rhythmus
//
//  Created by Admin on 08/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SelectDurationViewController.h"
#import "SoundDurationView.h"

@interface SelectDurationViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SelectDurationViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define REUSABLE_CELL_ID @"ReusableCellID"
    
    UITableViewCell *tableViewCell =
    [tableView dequeueReusableCellWithIdentifier:REUSABLE_CELL_ID];
    if (!tableViewCell) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:REUSABLE_CELL_ID];
        if (self.currentDuration.duration == 1.f/powf(2, indexPath.row)) {
            [tableView selectRowAtIndexPath:indexPath
                                   animated:NO
                             scrollPosition:UITableViewScrollPositionNone];
        }
    }
    tableViewCell.textLabel.text = [NSString stringWithFormat:@"1/%d",(int)powf(2, indexPath.row)];
    return tableViewCell;
    
#undef REUSABLE_CELL_ID
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentDuration.duration = 1.f/(int)powf(2, indexPath.row);
    [self.delegate selectDurationViewController:self
                  finishedWithSoundDurationView:(self.currentDuration)];
}

@end
