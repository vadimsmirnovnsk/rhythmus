//
//  SESequencerEvent.h
//  TestSingleViewApp
//
//  Created by Wadim on 7/26/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PPQNNoInterval -1;

typedef enum {
    eventDefaultType = 0,
    eventTypeTrigger = 0,
    eventTypeNoteOn = 1,
    eventTypeNoteOff = 2
} EventType;

@interface SESequencerEvent : NSObject <NSCopying>

@property (nonatomic, readwrite) EventType type;
@property (nonatomic, strong) NSData /*with raw MIDI message data*/ *data;
@property (nonatomic, readwrite) NSInteger PPQNTimeStamp;
@property (nonatomic, readwrite) NSTimeInterval rawTimestamp;

#pragma mark -
#pragma mark Initializers
- (id) initWithRawTimestamp:(NSTimeInterval)rawTimestamp;

@end
