//
//  SESequencerMessage.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SESequencerMessage : NSObject

#define SEQUENCE_MESSAGE_PPQN_NO_INTERVAL -1;
#define SEQUENCE_MESSAGE_NULL_TIMESTAMP -1;
#define SEQUENCE_MESSAGE_NULL_DURATION -1;

typedef enum {
    messageTypeDefault = 0,
    messageTypeTrigger = 0,
    messageTypePause = 1,
    messageTypeSample = 2
} MessageType;

@property (nonatomic, readwrite) MessageType type;
@property (nonatomic, strong) NSData /*with raw MIDI message data*/ *data;
@property (nonatomic, readwrite) unsigned long PPQNTimeStamp;
@property (nonatomic, readwrite) NSInteger initialDuration; // Non-music-quantized duration - in PPQN.
@property (nonatomic, readwrite) NSTimeInterval rawTimestamp;

#pragma mark Class Methods
+ (instancetype) defaultMessage;

#pragma mark -
#pragma mark Initializers
- (id) initWithRawTimestamp:(NSTimeInterval)rawTimestamp;


@end
