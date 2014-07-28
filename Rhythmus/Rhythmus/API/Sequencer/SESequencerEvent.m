//
//  SESequencerEvent.m
//  TestSingleViewApp
//
//  Created by Wadim on 7/26/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencerEvent.h"


@implementation SESequencerEvent

#pragma mark -
#pragma mark Initializers

- (id) initWithRawTimestamp:(NSTimeInterval)rawTimestamp {
    if (self=[super init]) {
        _type = eventDefaultType;
        _data = nil;
        _PPQNTimeStamp = PPQNNoInterval;
        _rawTimestamp = rawTimestamp;
    }
    return self;
}

#pragma mark NSCopying Protocol Methods

- (id)copyWithZone:(NSZone *)zone {
    SESequencerEvent *newEvent = [[[self class]allocWithZone:zone]init];
    newEvent.type = self.type;
    newEvent.data = [NSData dataWithBytes:[_data bytes] length:[_data length]];
    return newEvent;
}

@end
