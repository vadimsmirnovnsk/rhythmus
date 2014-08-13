
#import "SESystemTimer.h"
#import <mach/mach_time.h>


#pragma mark SESystemTimerDelegate Extension

@interface SESystemTimer ()

@property (nonatomic, readwrite) BOOL shouldReset;
@property (nonatomic, readwrite) unsigned long oldPeriod;

@end


#pragma mark SESystemTimerDelegate Implementation

@implementation SESystemTimer

- (void) startWithPulsePeriod:(unsigned long)usecPeriod
{
    self.period = usecPeriod;
    self.oldPeriod = usecPeriod;
    // Checking for already pulsing
    if (self.clocking) {
        return;
    }
    self.clocking = YES;
    // Init start tick by 0, get timebase and good enough resolution of absolute-time
    uint64_t __block tick = 0;
    uint64_t __block currentTime = 0;
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint64_t beginTime = mach_absolute_time();
    __typeof (self) __weak blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (blockSelf.clocking) {
            if (blockSelf.shouldReset) {
                blockSelf.shouldReset = NO;
                tick = 0;
            }
            usleep(blockSelf.period/1000);
            currentTime = mach_absolute_time();
            tick = (currentTime - beginTime)*timebase.numer / timebase.denom / blockSelf.period;
            // Return counted ticks to main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                [blockSelf.delegate timer:blockSelf didCountTick:tick];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [blockSelf.delegate timerDidStop:blockSelf];
        });
    });
}

- (BOOL) start
{
    if ((self.period!=0)&&(!!self.delegate)) {
        [self startWithPulsePeriod:self.period];
        return YES;
    }
    return NO;
}

- (void) stop
{
    self.clocking = NO;
}

- (void) reset
{
    self.shouldReset = YES;
}


@end

