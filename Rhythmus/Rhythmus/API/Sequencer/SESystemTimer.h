
#import <Foundation/Foundation.h>


#pragma mark SESystemTimerDelegate Protocol

@class SESystemTimer;
@protocol SESystemTimerDelegate <NSObject>

/**
 *      Follow these patterns when delegating any duties:
 *
 *          - (BOOL)shouldSomebodyDoSomething:(id)sender;
 *          - (void)somebodyDid/WillDoSomething:(id)sender;
 *          - (void)somebody:(id)sender did/WillFinishDoingSomethingWithResult:(id)result;
 *
 *      That's it! Isn't it simple? ;-)
 */
 
- (void) timer:(SESystemTimer *)timer didCountTick:(uint64_t)tick;
- (void) timerDidStop:(SESystemTimer *)timer;

@end


#pragma mark SESystemTimer Interface

@interface SESystemTimer : NSObject

@property (nonatomic, weak) id<SESystemTimerDelegate> delegate;

- (void) startWithPulsePeriod:(unsigned long)usecPeriod;
- (BOOL) start; // Start with current options
- (void) stop;
- (void) reset;

@end
