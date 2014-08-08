
#import <UIKit/UIKit.h>
#import "SEReceiverDelegate.h"
#import "SESequencer.h"



@interface PadsWorkspaceVC : UIViewController <SEReceiverDelegate>

@property (nonatomic, strong) SESequencer *sequencer;

- (void)tuneForSequencer:(SESequencer *)sequencer;

@end
