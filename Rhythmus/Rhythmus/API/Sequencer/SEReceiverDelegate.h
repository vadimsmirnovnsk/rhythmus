
#import <Foundation/Foundation.h>
@class SESequencerMessage;
@class SESequencerOutput;

@protocol SEReceiverDelegate <NSObject>

- (void) output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message;

@end
