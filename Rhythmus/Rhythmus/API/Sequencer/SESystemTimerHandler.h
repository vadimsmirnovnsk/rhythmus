//
//  SESystemTimerHandler.h
//  TestSingleViewApp
//
//  Created by Wadim on 7/27/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SESystemTimerHandler <NSObject>

- (void) receiveTick:(uint64_t)tick;

@end
