
#import <UIKit/UIKit.h>
#import "SEReceiverDelegate.h"
#import "SESequencer.h"
#import "SERhythmusPattern.h"


#pragma mark PadsWorkspaceProtocol

@class PadsWorkspaceVC;
@protocol PadsWorkspaceProtocol <NSObject>

- (void) workspaceDidFinishPatternRecording:(PadsWorkspaceVC *)sender;

@end


#pragma mark - SEPad Interface

@interface SEPad : UIButton

@property (nonatomic, copy) NSString *colorName;

@end


#pragma mark - PadsWorkspace Interface

@interface PadsWorkspaceVC : UIViewController <SEReceiverDelegate>

@property (nonatomic, weak) SESequencer *sequencer;
@property (nonatomic, weak) SERhythmusPattern *currentPattern;
@property (nonatomic, weak) id<PadsWorkspaceProtocol> delegate;

- (void)tuneForSequencer:(SESequencer *)sequencer;
- (void)tuneForSequencer:(SESequencer *)sequencer
    withContentsOfPattern:(SERhythmusPattern *)currentPattern;

@end
