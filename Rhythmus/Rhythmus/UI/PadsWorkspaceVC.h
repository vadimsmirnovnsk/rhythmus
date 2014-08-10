
#import <UIKit/UIKit.h>
#import "SEReceiverDelegate.h"
#import "SESequencer.h"
#import "SERhythmusPattern.h"


#pragma mark - SEPad Interface

@interface SEPad : UIButton

@property (nonatomic, copy) NSString *colorName;

@end

@interface PadsWorkspaceVC : UIViewController <SEReceiverDelegate>

@property (nonatomic, strong) SESequencer *sequencer;
@property (nonatomic, strong) SERhythmusPattern *currentPattern;

- (void)tuneForSequencer:(SESequencer *)sequencer;
- (void)tuneForSequencer:(SESequencer *)sequencer
    withContentsOfPattern:(SERhythmusPattern *)currentPattern;

@end
