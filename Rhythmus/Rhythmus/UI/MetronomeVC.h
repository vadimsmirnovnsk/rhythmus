
#import <UIKit/UIKit.h>
#import "SESequencer.h"

@interface MetronomeVC : UIViewController <SEReceiverDelegate>

@property (nonatomic, weak) SESequencer *sequencer;

@end
