
#import <UIKit/UIKit.h>
#import "SESequencer.h"
#import "SERhythmusPattern.h"


#pragma mark - StatusBarVC Interface

@interface StatusBarVC : UIViewController

@property (nonatomic, weak) SESequencer *sequencer;
@property (nonatomic, weak) SERhythmusPattern *currentPattern;

@end
