
#import <UIKit/UIKit.h>
#import "SESequencer.h"
#import "SERhythmusPattern.h"


#pragma mark - StatusBarVC Interface

@interface StatusBarVC : UIViewController

- (void) tuneForSequencer:(SESequencer *)sequencer withPattern:(SERhythmusPattern *)pattern;

@end
