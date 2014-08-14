
#import <Foundation/Foundation.h>


#pragma mark SESystemTimerDelegate Protocol

@class SESystemTimer;
@protocol SESystemTimerDelegate <NSObject>

- (void) timer:(SESystemTimer *)timer didCountTick:(uint64_t)tick;
- (void) timerDidStop:(SESystemTimer *)timer;

@end


#pragma mark SESystemTimer Interface

@interface SESystemTimer : NSObject

@property (nonatomic, weak) id<SESystemTimerDelegate> delegate;
@property (atomic, readwrite) unsigned long period;
@property (nonatomic, getter = isClocking) BOOL clocking;

- (void) startWithPulsePeriod:(unsigned long)usecPeriod;
- (BOOL) start; // Start with current options
- (void) stop;
- (void) reset;

@end
