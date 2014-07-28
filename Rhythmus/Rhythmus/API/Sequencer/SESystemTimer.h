//
//  SESystemTimer.h
//  TestSingleViewApp
//
//  Created by Wadim on 7/27/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

/* System Timer Class
 * Create in High Priority Queue task and returns fine sync pulses.
 */

#import <Foundation/Foundation.h>
#import "SESystemTimerHandler.h"

@interface SESystemTimer : NSObject

@property (atomic, readwrite) BOOL isClocking;
@property (nonatomic, readonly) unsigned int period;
@property (nonatomic, weak) id<SESystemTimerHandler> handler;

- (void) startWithPulsePeriod:(unsigned long)usecPeriod callbackObject:(id<SESystemTimerHandler>)receiver;
- (BOOL) start; // With current options
- (void) stop;

@end
