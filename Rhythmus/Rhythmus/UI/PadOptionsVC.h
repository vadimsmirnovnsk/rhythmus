
#import <UIKit/UIKit.h>
#import "PadsWorkspaceVC.h"


#pragma mark PadOptionsVCDelegate Protocol

@class PadOptionsVC;
@protocol PadOptionsVCDelegate <NSObject>

- (void)optionsControllerDidCanceled:(PadOptionsVC *)sender;

@end


#pragma mark PadOptionsVC Interface

@interface PadOptionsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<PadOptionsVCDelegate> delegate;
@property (nonatomic, weak) SEPad *pad;

@end
