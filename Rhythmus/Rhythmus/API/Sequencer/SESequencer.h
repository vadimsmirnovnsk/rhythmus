//
//  SESequencer.h
//  TestSingleViewApp
//
//  Created by Wadim on 7/25/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

/* SESequencer is class that realised model of real SMPTE sequencer with constant PPQN.
 * Logic of simple using this sequencer:
 * 1. Create streams [with events], for objects-sources of new events, and objects-receivers of events.
 * 2. Object source creates new events and send this events to sequencer.
 * 3. Sequencer save this events to streams with timestamps in Recording mode or just resend to receiver<?>.
 */

#import <Foundation/Foundation.h>
#import "SEStreamHandler.h"
#import "SESequencerStream.h"
#import "SESystemTimerHandler.h"

@interface SESequencer : NSObject <SESystemTimerHandler>

@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, strong) NSNumber *tempo;
@property (nonatomic, readonly, getter = streamsCount) NSNumber *streamsCount;

#pragma mark -
#pragma mark Streams Methods

// Creating streams methods
- (NSNumber*) createStreamWithSource:(id<SEStreamHandler>)source andDestination:(id<SEStreamHandler>)destination;
- (NSNumber*) createStreamWithStream:(SESequencerStream *)stream;

// Removing streams methods
- (BOOL) removeStreamNumber:(NSNumber *)/* With Int*/streamNumber;
- (void) removeAllStreams;

// Info streams methods
- (id<SEStreamHandler>) sourceForStreamNumber:(NSNumber *)/* With Int*/streamNumber;
- (id<SEStreamHandler>) destinationForStreamNumber:(NSNumber *)/* With Int*/streamNumber;

// Redacting front-end point and back-end point for streams methods
- (BOOL) registerDestination:(id<SEStreamHandler>)destination forStreamNumber:(NSNumber *)/* With Int*/streamNumber;
- (BOOL) registerSource:(id<SEStreamHandler>)source forStreamNumber:(NSNumber *)/* With Int*/streamNumber;

#pragma mark Pipe Methods

- (BOOL) receiveTriggerEventForStreamNumber:(NSNumber *)/* With Int*/streamNumber;

#pragma mark Playback Methods

- (BOOL) startRecording;
- (void) stopRecording;
- (void) playAllStreams;
- (void) stop;
- (void) pause;

@end
