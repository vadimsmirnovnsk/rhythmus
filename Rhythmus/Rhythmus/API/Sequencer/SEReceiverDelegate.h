
#import <Foundation/Foundation.h>
@class SESequencerMessage;
@class SESequencerOutput;

@protocol SEReceiverDelegate <NSObject>

/**
 *      Follow these patterns when delegating any duties:
 *
 *          - (BOOL)shouldSomebodyDoSomething:(id)sender;
 *          - (void)somebodyDid/WillDoSomething:(id)sender;
 *          - (void)somebody:(id)sender did/WillFinishDoingSomethingWithResult:(id)result;
 *
 *      That's it! Isn't it simple? ;-)
 */
- (void) output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message;

@end
