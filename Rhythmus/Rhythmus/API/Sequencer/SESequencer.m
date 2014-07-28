//
//  SESequencer.m
//  TestSingleViewApp
//
//  Created by Wadim on 7/25/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencer.h"
#import "SESystemTimer.h"

#define DEBUG_NSLOG

/*Set default PPQN*/
#define defaultPPQNValue 960.0;
/* Constant for convertion BPM to single PPQN time in usec */
#define BPMtoPPQNTickConstant 60000000.0/defaultPPQNValue;

const float defaultPPQN = defaultPPQNValue;

const float defaultBPMtoPPQNTickConstant = BPMtoPPQNTickConstant;

// Private interface section
@interface SESequencer ()

@property (nonatomic, strong) NSMutableArray *streams;
@property (nonatomic, strong) NSDate *startRecordingDate;
@property (nonatomic, strong) SESystemTimer *systemTimer;

@end

@implementation SESequencer

#pragma mark -
#pragma mark Inits
- (id) init {
    if (self = [super init]) {
        _streams = [[NSMutableArray alloc]init];
        _startRecordingDate = nil;
        _isRecording = NO;
        _tempo = @(100);
        _systemTimer = [[SESystemTimer alloc]init];
    }
    return self;
}


#pragma mark - 
#pragma mark Streams Methods

/*  Create stream for source-object and destination object for creating pipe.
 *  After creating the stream, Sequencer can send or receive events via this 
 *  pipe connection, for recording or playing created stream. 
 *  Return stream number in Sequencer streams pool. */

- (NSNumber*) createStreamWithSource:(id<SEStreamHandler>)source andDestination:(id<SEStreamHandler>)destination{
    SESequencerStream *newStream = [[SESequencerStream alloc]initWithSource:source andDestination:destination];
    [_streams addObject:newStream];
    return @([_streams indexOfObject:newStream]);
}

/* Create stream by copying existing stream */
- (NSNumber *) createStreamWithStream:(SESequencerStream *)stream {
    SESequencerStream *copyStream = [stream copy];
    [_streams addObject:copyStream];
    return @([_streams indexOfObject:copyStream]);
}

/* Remove stream and pipe-connection with handler.
 * Return YES if operation was done successful */

- (BOOL) removeStreamNumber:(NSNumber *)streamNumber {
    if ([_streams count]>[streamNumber intValue]) {
        [_streams removeObjectAtIndex:[streamNumber intValue]];
        return YES;
    }
    return NO;
}

/* Remove all streams and all pipe-connections with handlers. */

- (void) removeAllStreams {
    [_streams removeAllObjects];
}

/* Return source-object for streamNumber. Return nil if stream for streamNumber isn't exist. */

- (id<SEStreamHandler>) sourceForStreamNumber:(NSNumber *)streamNumber {
    if ([_streams count]>[streamNumber intValue]) {
        return [[_streams objectAtIndex:[streamNumber intValue]]source];
    }
    return nil;
}

/* Return destination-object for streamNumber. Return nil if stream for streamNumber isn't exist. */

- (id<SEStreamHandler>) destinationForStreamNumber:(NSNumber *)streamNumber{
    if ([_streams count]>[streamNumber intValue]) {
        return [[_streams objectAtIndex:[streamNumber intValue]]destination];
    }
    return nil;
}

/* Register new destination for stream. Return nil if stream for streamNumber isn't exist.*/

- (BOOL) registerDestination:(id<SEStreamHandler>)destination forStreamNumber:(NSNumber *)streamNumber {
    if ([_streams count]>[streamNumber intValue]) {
        [[_streams objectAtIndex:[streamNumber intValue]]setDestination:destination];
        return YES;
    }
    return NO;
}

/* Register new source for stream. Return nil if stream for streamNumber isn't exist.*/

- (BOOL) registerSource:(id<SEStreamHandler>)source forStreamNumber:(NSNumber *)streamNumber {
    if ([_streams count]>[streamNumber intValue]) {
        [[_streams objectAtIndex:[streamNumber intValue]]setSource:source];
        return YES;
    }  
    return NO;
}

- (NSNumber *) streamsCount {
    return @([_streams count]);
}

#pragma mark Pipe Methods
/* Receive event from source for stream number. If stream with number not exist return NO.
 * Else create event with raw timestamp and write to stream and try to send event to destination */
- (BOOL) receiveTriggerEventForStreamNumber: (NSNumber *)streamNumber {
    if ([_streams count]>[streamNumber intValue]) {
        id __weak tempStream = [_streams objectAtIndex:[streamNumber intValue]];
        SESequencerEvent *newEvent = [[SESequencerEvent alloc]initWithRawTimestamp:[[NSDate date]
                                                                                    timeIntervalSinceDate:_startRecordingDate]];
        // Write event to stream in Recording mode
        if (_isRecording) {
            [tempStream addEvent:newEvent];
        }
        // Send 
        if ([[tempStream destination]readyToEventFromStream]) {
            [[tempStream destination]receiveEvent:newEvent fromStreamNumber:streamNumber];
        }
        return YES;
    }
    return NO;
}


#pragma mark Playback Methods

- (BOOL) startRecording {
    _isRecording = YES;
    _startRecordingDate = [NSDate date];
    return YES;
}

/* Stop recording events to streams and convert all raw timestamps into PPQNTimestamps
 */
- (void) stopRecording {
    _isRecording = NO;
    // Get raw stop timestamp for correct processing convertation to PPQN for last events in every stream
    NSTimeInterval stopRecordingTimeInterval = [[NSDate date]timeIntervalSinceDate:_startRecordingDate];
    float singleQuarterPulse = (60/((float)[_tempo intValue]*defaultPPQN));
    for (SESequencerStream *stream in _streams) {
        for (SESequencerEvent *event in [stream events]) {
            event.PPQNTimeStamp = (int)(event.rawTimestamp/singleQuarterPulse);
#ifdef DEBUG_NSLOG
            NSLog(@"Raw Timestamp = %f",event.rawTimestamp);
            NSLog(@"PPQN TimeStamp = %i",event.PPQNTimeStamp);
#endif
        }
    }
}

- (void) playStreams:(NSSet */*of NSNumbers*/)streamsNumbers {
    
}

- (void) playAllStreams {
    // DEBUG!!!
    [_systemTimer startWithPulsePeriod:(long)
     (defaultBPMtoPPQNTickConstant/[_tempo intValue])*1000 callbackObject:self];
#ifdef DEBUG_NSLOG
    NSLog(@"PPQN tick = %f",defaultBPMtoPPQNTickConstant/[_tempo intValue]);
#endif
}

- (void) stop {
    [_systemTimer stop];
}
- (void) pause {
    
}

- (void) recordStreams:(NSSet * /*of NSNumbers*/)streams {
    
}

- (void) recordAllStreams {
    
}

#pragma mark SESystemTimerHandler Protocol Methods
- (void) receiveTick:(uint64_t)tick {
    if (!!tick%960) {
        NSLog(@"Quarter %llu Received!",tick/960);
    }
}



@end
