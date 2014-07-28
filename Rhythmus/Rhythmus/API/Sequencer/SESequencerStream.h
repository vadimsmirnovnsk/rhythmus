//
//  SESequencerStream.h
//  TestSingleViewApp
//
//  Created by Wadim on 7/26/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESequencerEvent.h"
#import "SEStreamHandler.h"

@interface SESequencerStream : NSObject <NSCopying>

@property (nonatomic, strong) id<SEStreamHandler> source;
@property (nonatomic, strong) id<SEStreamHandler> destination;
@property (nonatomic, strong, readonly, getter = events) NSArray *sharedEvents;


// Designated initializer
- (id) initWithSource:(id<SEStreamHandler>)source andDestination:(id<SEStreamHandler>)destination;
- (void) addEvent:(SESequencerEvent *)event;
- (void) setEventsArray:(NSArray *)eventsArray;

@end
