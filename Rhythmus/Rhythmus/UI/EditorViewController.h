
#import <UIKit/UIKit.h>
#import "SERedactorVC.h"

@interface EditorViewController : UIViewController <UIScrollViewDelegate>

// TODO: rewrite for delegate with protocol
@property (nonatomic, weak) SERedactorVC *delegate;
// Set currentPattern after setting the Sequencer
@property (nonatomic, weak) SERhythmusPattern *currentPattern;

- (void)redraw;

@end
