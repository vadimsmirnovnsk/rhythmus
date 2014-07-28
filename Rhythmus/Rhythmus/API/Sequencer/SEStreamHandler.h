//
//  SEStreamHandler.h
//  TestSingleViewApp
//
//  Created by Wadim on 7/25/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESequencerEvent.h"

@protocol SEStreamHandler <NSObject>

- (BOOL) readyToEventFromStream;
- (void) receiveEvent:(SESequencerEvent *)event fromStreamNumber:(NSNumber *)streamNumber;

@end
