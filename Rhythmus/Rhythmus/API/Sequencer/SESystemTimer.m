//
//  SESystemTimer.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESystemTimer.h"
#import <mach/mach_time.h>

@interface SESystemTimer ()

@property (nonatomic, readwrite) BOOL shouldReset;
@property (nonatomic, getter = isClocking) BOOL clocking;
@property (nonatomic, weak) id<SESystemTimerDelegate> delegate;
@property (nonatomic, readonly) unsigned int period;

@end

@implementation SESystemTimer

- (instancetype)init
{
    NSLog(@"Method shouldn't be called. Please use an -initWithDelegate method.");
    return nil;
}

// Designated initializer
- (instancetype) initWithDelegate:(id<SESystemTimerDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void) startWithPulsePeriod:(unsigned long)usecPeriod
{
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (self.clocking) {
            if (self.shouldReset) {
                self.shouldReset = NO;
                tick = 0;
            }
            usleep(usecPeriod/1000);
            currentTime = mach_absolute_time();
            tick = (currentTime - beginTime)*timebase.numer / timebase.denom / usecPeriod;
            // Return counted ticks to main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate timer:self didCountTick:tick];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate resetPlayhead];
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

