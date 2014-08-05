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

// CR:  The property's name is obscure. What do you mean by 'isReset'?
@property (nonatomic, readwrite) BOOL isReset;

@end

@implementation SESystemTimer

// Designated initializer
- (id) init
{
    if (self = [super init]) {
        _clocking = NO; // CR:  It's already assigned with @b NO.
        _delegate = nil; // CR: It's already assigned with @b nil.
    }
    return self;
}

- (void) startWithPulsePeriod:(unsigned long)usecPeriod
    withDelegate:(id <SESystemTimerDelegate>)delegate
{
    // Checking for already pulsing
    if (_clocking) { // CR: We never ever access the ivars directly,
                     //     unless you do such a thing from within
                     //     an initializer or a getter/setter.
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
            if (self.isReset) {
                self.isReset = NO;
                tick = 0;
            }
            usleep(usecPeriod/1000);
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
        // CR:  Same thing: do NOT access the ivars directly.
        [self startWithPulsePeriod:_period withDelegate:_delegate];
        return YES;
    }
    return NO;
}

- (void) stop
{
    _clocking = NO;
}

- (void) reset
{
    self.isReset = YES;
}


@end

