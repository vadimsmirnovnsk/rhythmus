//
//  SESequencer.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencer.h"
#import "SESystemTimer.h"
#import "SESequencerMessage.h"
#import "SESequencerInput.h"

#define DEBUG_NSLOG

/* Set Default Tempo value in BPM */
#define DEFAULT_TEMPO_VALUE 100;

/* Set default PPQN */
#define DEFAULT_PPQN_VALUE 960.0;

/* Constant for convertion BPM to single PPQN time in usec */
#define BPM_TO_PPQN_TICK_CONSTANT 60000000.0/DEFAULT_PPQN_VALUE;

const float defaultPPQN = DEFAULT_PPQN_VALUE;
const int defaultTempo = DEFAULT_TEMPO_VALUE;
const float defaultBPMtoPPQNTickConstant = BPM_TO_PPQN_TICK_CONSTANT;

// Private interface section
@interface SESequencer ()

// CR: The 'private' is redundant.
@property (nonatomic, strong) NSMutableDictionary *privateMutableTracks;
// CR: Same thing here.
@property (nonatomic, strong) NSMutableDictionary *privateMutableOutputs;
// CR: ... and here.
@property (nonatomic, strong) NSMutableDictionary *privateMutableInputs;
// CR: ... and here.
@property (nonatomic, strong) NSDate *privateStartRecordingDate;
// CR: ... and here.
@property (nonatomic, strong) SESystemTimer *privateSystemTimer;
// CR: ... and here.
@property (nonatomic, readwrite) unsigned long privateExpectedTick;

- (void) processExpectedTick;
- (unsigned long) tickForNearestEvent;

@end

@interface SESequencerInput ()

@property (nonatomic, weak) SESequencerTrack *track;
@property (nonatomic, weak) SESequencer *delegate;

@end


@implementation SESequencer

#pragma mark -
#pragma mark Inits
- (id) init
{
    if (self = [super init]) {
        _privateMutableTracks = [[NSMutableDictionary alloc]init];
        _privateMutableOutputs = [[NSMutableDictionary alloc]init];
        _privateMutableInputs = [[NSMutableDictionary alloc]init];
        _privateStartRecordingDate = nil;
        _recording = NO;
        _tempo = @(defaultTempo);
        _privateSystemTimer = [[SESystemTimer alloc]init];
        _privateExpectedTick = 0;
    }
    return self;
}

#pragma mark -
#pragma mark Tracks Methods

// Creating streams methods
- (void) addExistingTrack:(SESequencerTrack *)track
{
    if ([track identifier]) {
        [self.privateMutableTracks setObject:track forKey:[track identifier]];
    }
}

// Removing tracks methods
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier
{
    if ([self.privateMutableTracks objectForKey:identifier]) {
        [self.privateMutableTracks removeObjectForKey:identifier];
        return YES;
    }
    return NO;
}

- (void) removeAllTracks
{
    [self.privateMutableTracks removeAllObjects];
}

// Returns identifiers for all tracks that contained in Sequencer
- (NSArray *)trackIdentifiers
{
    NSMutableArray *trackIdentifiers = [[NSMutableArray alloc]init];
    for (id<NSCopying> key in self.privateMutableTracks) {
        [trackIdentifiers addObject:key];
    }
    return [NSArray arrayWithArray:trackIdentifiers];
}

// Registering inputs method
- (void) registerInput:(SESequencerInput *)input
    forTrackWithIdentifier:(NSString *)identifier
{
    SESequencerTrack *track = [self.privateMutableTracks objectForKey:identifier];
    if (!track) {
        [self.privateMutableTracks setObject:
         // CR: Never ever do such a thing again. Replace the nested calls with
         //     the lines given below.
         //
         //     track = [[SESequencerTrack alloc]initWithidentifier:identifier];
         //     [self.privateMutableTracks setObject:track forKey:identifier];
         //
            track = [[SESequencerTrack alloc]initWithidentifier:identifier] forKey:identifier];
    }
    input.delegate = self;
    input.track = track;

    // CR: None of the sequencers should know about any inputs.
    [self.privateMutableInputs setObject:input forKey:identifier];
}

// Registering outputs method
- (void) registerOutput:(id<SEReceiverDelegate>)output
    forTrackWithIdentifier:(NSString *)identifier
{
    // CR:  None of the equesncers should know about outputs.
    //      IMHO, a track may have a weak pointer to an output.
    //      How do you think?
    [self.privateMutableOutputs setObject:output forKey:identifier];
}

#pragma mark Playback Methods

- (BOOL) startRecording
{
    _recording = YES;
    self.privateStartRecordingDate = [NSDate date];
    return YES;
}

/* Stop recording events to streams and convert all raw timestamps into PPQNTimestamps
 */
- (void) stopRecording
{
    _recording = NO;
    // Get raw stop timestamp for correct processing convertation to PPQN
    // for last events in every stream
    NSTimeInterval stopRecordingTimeInterval = [[NSDate date]
        timeIntervalSinceDate:self.privateStartRecordingDate];
    float singleQuarterPulse = (60/((float)[_tempo intValue]*defaultPPQN));
    for (id<NSCopying> key in self.privateMutableTracks) {
        for (SESequencerMessage *message in
            [[self.privateMutableTracks objectForKey:key]allMessages]) {
            message.PPQNTimeStamp = (int)(message.rawTimestamp/singleQuarterPulse);
#ifdef DEBUG_NSLOG
            NSLog(@"Raw Timestamp = %f",message.rawTimestamp);
            NSLog(@"PPQN TimeStamp = %li",message.PPQNTimeStamp);
#endif
        }
    }
}

/* Play all streams, so what can else say. */
- (void) playAllStreams
{
    self.privateExpectedTick = 0;
    self.privateExpectedTick = [self tickForNearestEvent];
    [self.privateSystemTimer startWithPulsePeriod:(long)
        (defaultBPMtoPPQNTickConstant/[_tempo intValue])*1000 withDelegate:self];
#ifdef DEBUG_NSLOG
    NSLog(@"PPQN tick = %f",defaultBPMtoPPQNTickConstant/[_tempo intValue]);
#endif
}

- (void) stop
{
    [self.privateSystemTimer stop];
}

- (void) pause
{
    [self.privateSystemTimer stop];
}


#pragma mark SESequencerInputDelegate Methods
/* Receive event from source for stream number. If stream with number not exist return NO.
 * Else create event with raw timestamp and write to stream and try to send event to destination */
- (BOOL) receiveMessage:(SESequencerMessage *)message forTrack:(SESequencerTrack *)track
{
    if (!!track) {
        if (message == nil) {
            message = [[SESequencerMessage alloc]initWithRawTimestamp:[[NSDate date]
            timeIntervalSinceDate:self.privateStartRecordingDate]];
        }
        // Write event to stream in Recording mode
        if (_recording) {
            [track addMessage:message];
        }
        // Send to output
        id __weak tempObjectForKey = [self.privateMutableOutputs objectForKey:[track identifier]];
        if (tempObjectForKey) {
            if ([tempObjectForKey isKindOfClass:[NSMutableArray class]]) {
                // Object for key is NSMutaleArray
                for (id<SEReceiverDelegate> output in tempObjectForKey) {
                    [output receiveMessage:message];
                }
            }
            else {
                // Object for key is just a single output
                [tempObjectForKey receiveMessage:message];
            }
        }
        
        return YES;
    }
    return NO;
}

#pragma mark SESystemTimerDelegate Protocol Methods
- (void) receiveTick:(uint64_t)tick
{
    // Check for 1/4 click
    if (!!tick%960) {
        NSLog(@"Quarter %llu Received!",tick/960);
    }
    // Check for nearest event
    if (tick>=self.privateExpectedTick) {
        self.privateExpectedTick = (unsigned long)tick;
        [self processExpectedTick];
    }
    
}

#pragma mark Private Methods

/* Process all streams with
 */

- (void) processExpectedTick
{
    SESequencerMessage *__weak trackCurrentMessage = nil;
    SESequencerTrack *__weak track = nil;
    for (id<NSCopying> identifier in self.privateMutableTracks) {
        track = [self.privateMutableTracks objectForKey:identifier];
        trackCurrentMessage = [track currentMessage];
        if ([trackCurrentMessage PPQNTimeStamp]<=self.privateExpectedTick) {
            if (![[self.privateMutableInputs objectForKey:identifier]isMuted]) {
                [[self.privateMutableOutputs objectForKey:identifier]
                    receiveMessage:trackCurrentMessage];
            }
        [track goToNextMessage];
        }
    }
    self.privateExpectedTick = [self tickForNearestEvent];
}

/* Find one nearest Event time (in ticks) in all streams. 
 * Return PPQN-value of nearest Event. 
 */
- (unsigned long) tickForNearestEvent
{
    unsigned long tickForNearestEvent = UINT32_MAX;
    // Process 0 tick (begin playing)
    if (self.privateExpectedTick == 0) {
        for (id<NSCopying> identifier in self.privateMutableTracks) {
            [[self.privateMutableTracks objectForKey:identifier]
                setCurrentMessageCounter:@(0)];
        }
    }
    // Find nearest event
    for (id<NSCopying> identifier in self.privateMutableTracks) {
        unsigned long tempTick = [[[self.privateMutableTracks objectForKey:identifier]
            currentMessage]PPQNTimeStamp];
        if (tempTick<tickForNearestEvent) {
            tickForNearestEvent = tempTick;
        }
    }
    return tickForNearestEvent;
}

@end
