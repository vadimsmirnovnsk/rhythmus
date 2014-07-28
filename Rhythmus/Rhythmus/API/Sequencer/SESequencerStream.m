//
//  SESequencerStream.m
//  TestSingleViewApp
//
//  Created by Wadim on 7/26/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencerStream.h"

@interface SESequencerStream ()

@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation SESequencerStream

#pragma mark -
#pragma mark Initializers

// Designated initializer
- (id) initWithSource:(id<SEStreamHandler>)source andDestination:(id<SEStreamHandler>)destination {
    if (self=[super init]) {
        _source = source;
        _destination = destination;
        _events = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark Events Methods

/* Add event to sequencer stream */
- (void) addEvent:(SESequencerEvent *)event {
    [_events addObject:event];
}

- (void) setEventsArray:(NSArray *)eventsArray {
    _events = [eventsArray mutableCopy];
}

- (NSArray *) events {
    return [NSArray arrayWithArray:_events];
}

#pragma mark NSCopying Protocol Methods

- (id) copyWithZone:(NSZone *)zone {
    SESequencerStream *newStream = [[[self class]allocWithZone:zone]init];
    newStream.source = _source;
    newStream.destination = _destination;
    [newStream setEventsArray:[_events copy]];
    return newStream;
}

@end
