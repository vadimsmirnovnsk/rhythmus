//
//  SESequencerMessage.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencerMessage.h"

@implementation SESequencerMessage

#pragma mark -
#pragma mark Initializers

+ (instancetype)defaultMessage
{
    return ([[SESequencerMessage alloc]init]);
}

+ (instancetype) messageWithType:(MessageType)type andParameters:(NSDictionary *)parameters
{
    double empty_time_interval = SEQUENCE_MESSAGE_NULL_TIMESTAMP;
    return [[SESequencerMessage alloc]initWithRawTimestamp:empty_time_interval
        type:type parameters:parameters];
}

- (instancetype) init
{
    double empty_time_interval = SEQUENCE_MESSAGE_NULL_TIMESTAMP;
    return [self initWithRawTimestamp:empty_time_interval type:messageTypeDefault parameters:nil];
}

// Designated initializer
- (instancetype) initWithRawTimestamp:(NSTimeInterval)rawTimestamp
    type:(MessageType)type parameters:(NSDictionary *)parameters
{
    if (self=[super init]) {
        _type = type;
        _data = nil;
        _PPQNTimeStamp = SEQUENCE_MESSAGE_PPQN_NO_INTERVAL;
        _rawTimestamp = rawTimestamp;
        _initialDuration = SEQUENCE_MESSAGE_NULL_DURATION;
        _parameters = parameters;
    }
    return self;
}

#pragma mark NSCopying Protocol Methods

- (id)copyWithZone:(NSZone *)zone
{
    SESequencerMessage *newMessage = [[[self class]allocWithZone:zone]init];
    newMessage.type = self.type;
    newMessage.data = [NSData dataWithBytes:[_data bytes] length:[_data length]];
    return newMessage;
}


@end
