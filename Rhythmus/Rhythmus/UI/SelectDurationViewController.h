
#import <UIKit/UIKit.h>
#import "SelectDurationViewControllerDelegate.h"
@class SoundDurationView;

@interface SelectDurationViewController : UIViewController

@property (strong, nonatomic) SoundDurationView* currentDuration;
@property id<SelectDurationViewControllerDelegate> delegate;

@end
