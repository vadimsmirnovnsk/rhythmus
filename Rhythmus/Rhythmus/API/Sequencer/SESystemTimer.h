//
//  SESystemTimer.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface SESystemTimer : NSObject

- (instancetype) initWithDelegate:(id<SESystemTimerDelegate>)delegate;
- (void) startWithPulsePeriod:(unsigned long)usecPeriod;
- (BOOL) start; // With current options
- (void) stop;
- (void) reset;

@end
