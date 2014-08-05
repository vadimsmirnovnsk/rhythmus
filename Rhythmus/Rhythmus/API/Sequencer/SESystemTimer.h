//
//  SESystemTimer.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESystemTimerDelegate.h"

@interface SESystemTimer : NSObject

// CR:  Are you sure it's possible to start cloking from the outside?
@property (nonatomic, getter = isClocking) BOOL clocking;
@property (nonatomic, readonly) unsigned int period;
@property (nonatomic, weak) id<SESystemTimerDelegate> delegate;

// CR:  What for do you need a delegate to be passed in?
- (void) startWithPulsePeriod:(unsigned long)usecPeriod withDelegate:
    (id<SESystemTimerDelegate>)delegate;
- (BOOL) start; // With current options
- (void) stop;
- (void) reset;

@end
