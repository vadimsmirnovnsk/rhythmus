
#import <UIKit/UIKit.h>
#import "SEReceiverDelegate.h"
#import "SESequencer.h"



@interface PadsWorkspaceVC : UIViewController <SEReceiverDelegate>

@property (nonatomic, strong /*TODO: change to weak*/) SESequencer *sequencer;

@end
