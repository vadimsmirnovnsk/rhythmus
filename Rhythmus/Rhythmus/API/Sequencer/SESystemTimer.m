//
//  SESystemTimer.m
//  TestSingleViewApp
//
//  Created by Wadim on 7/27/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESystemTimer.h"
#import <mach/mach_time.h>

@implementation SESystemTimer

- (id) init {
    if (self = [super init]) {
        _isClocking = NO;
        _handler = nil;
    }
    return self;
}

- (void) startWithPulsePeriod:(unsigned long)usecPeriod
    callbackObject:(id <SESystemTimerHandler>)receiver
{
    // Checking for already pulsing
    if (_isClocking) {
        return;
    }
    _isClocking = YES;
    // Init start tick by 0, get timebase and good enough resolution absolut-time
    uint64_t __block tick = 0;
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint64_t beginTime = mach_absolute_time();
    uint64_t __block currentTime = 0;
    id <SESystemTimerHandler> __weak receiverReference = receiver;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (_isClocking && receiverReference) {
            usleep(usecPeriod);
            currentTime = mach_absolute_time();
            tick = (currentTime - beginTime)*timebase.numer / timebase.denom / usecPeriod;
            // Return counted ticks to main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                [receiver receiveTick:tick];
            });
        }
    });
}

- (BOOL) start {
    if ((_period!=0)&&(!!_handler)) {
        [self startWithPulsePeriod:_period callbackObject:_handler];
        return YES;
    }
    return NO;
}

- (void) stop {
    _isClocking = NO;
}

@end
