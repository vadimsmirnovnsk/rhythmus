
#import <Foundation/Foundation.h>
@class SelectDurationViewController;
@class SoundDurationView;

@protocol SelectDurationViewControllerDelegate <NSObject>

-(void)selectDurationViewController:(SelectDurationViewController*)sender
      finishedWithSoundDurationView:(SoundDurationView*)soundDurationView;

@end
