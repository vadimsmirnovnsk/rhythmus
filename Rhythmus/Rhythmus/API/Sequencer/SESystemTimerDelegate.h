//
//  SESystemTimerDelegate.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//
//  Protocol that must accept Sequencer for receiving the Ticks from Timer

#import <Foundation/Foundation.h>

@protocol SESystemTimerDelegate <NSObject>

- (void) receiveTick:(uint64_t)tick;

@end
