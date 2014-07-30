//
//  SESystemTimer.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESystemTimer.h"
#import <mach/mach_time.h>

@implementation SESystemTimer

// Designated initializer
- (id) init
{
    if (self = [super init]) {
        _clocking = NO;
        _delegate = nil;
    }
    return self;
}

- (void) startWithPulsePeriod:(unsigned long)usecPeriod
    withDelegate:(id <SESystemTimerDelegate>)delegate
{
    // Checking for already pulsing
    if (_clocking) {
        return;
    }
    _clocking = YES;
    // Init start tick by 0, get timebase and good enough resolution absolut-time
    uint64_t __block tick = 0;
    uint64_t __block currentTime = 0;
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint64_t beginTime = mach_absolute_time();
    id <SESystemTimerDelegate> __weak receiverReference = delegate;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (_clocking && receiverReference) {
            usleep(usecPeriod);
            currentTime = mach_absolute_time();
            tick = (currentTime - beginTime)*timebase.numer / timebase.denom / usecPeriod;
            // Return counted ticks to main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate receiveTick:tick];
            });
        }
    });
}

- (BOOL) start
{
    if ((_period!=0)&&(!!_delegate)) {
        [self startWithPulsePeriod:_period withDelegate:_delegate];
        return YES;
    }
    return NO;
}

- (void) stop
{
    _clocking = NO;
}


@end

