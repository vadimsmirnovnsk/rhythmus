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

#pragma mark - Inputs Extension

@interface SESequencerInput ()

@property (nonatomic, weak) SESequencerTrack *track;
@property (nonatomic, weak) SESequencer *delegate;

@end

#pragma mark - Sequencer Extension

// Private interface section
@interface SESequencer () <SESystemTimerDelegate, SEInputDelegate>

// CR:Fixed The 'private' is redundant. Fixed.
@property (nonatomic, strong) NSMutableDictionary *mutableTracks;
// CR:Fixed Same thing here. Fixed.
@property (nonatomic, strong) NSMutableDictionary *mutableOutputs;
// CR:Fixed ... and here. Fixed.
@property (nonatomic, strong) NSMutableDictionary *mutableInputs;
// CR:Fixed ... and here. Fixed.
@property (nonatomic, strong) NSDate *startRecordingDate;
// CR:Fixed ... and here. Fixed.
@property (nonatomic, strong) SESystemTimer *systemTimer;
// CR:Fixed ... and here. Fixed.
@property (nonatomic, readwrite) unsigned long expectedTick;

- (void) processExpectedTick;
- (unsigned long) tickForNearestEvent;

@end


#pragma mark - Inputs Implementation

@implementation SESequencerInput

#pragma mark Inits

- (instancetype) init
{
    return [self initWithIdentifier:nil];
}

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
    _identifier = identifier;
    }
    return self;
}

#pragma mark Generate Messages Methods
- (void) generateMessage
{
    [self.delegate receiveMessage:[SESequencerMessage defaultMessage] forTrack:self.track];
}

- (void)generateMessageWithParameters:(NSDictionary *)parameters
{
    
}

@end


#pragma mark - Sequencer Implementation

@implementation SESequencer

#pragma mark Inits
- (id) init
{
    if (self = [super init]) {
        _mutableTracks = [[NSMutableDictionary alloc]init];
        _mutableOutputs = [[NSMutableDictionary alloc]init];
        _mutableInputs = [[NSMutableDictionary alloc]init];
        _startRecordingDate = nil;
        _recording = NO;
        _tempo = @(defaultTempo);
        _systemTimer = [[SESystemTimer alloc]init];
        _expectedTick = 0;
    }
    return self;
}

#pragma mark -
#pragma mark Tracks Methods

// Creating streams methods
- (void) addExistingTrack:(SESequencerTrack *)track
{
    if ([track identifier]) {
        [self.mutableTracks setObject:track forKey:[track identifier]];
    }
}

// Removing tracks methods
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier
{
    if ([self.mutableTracks objectForKey:identifier]) {
        [self.mutableTracks removeObjectForKey:identifier];
        return YES;
    }
    return NO;
}

- (void) removeAllTracks
{
    [self.mutableTracks removeAllObjects];
}

// Returns identifiers for all tracks that contained in Sequencer
- (NSArray *)trackIdentifiers
{
    NSMutableArray *trackIdentifiers = [[NSMutableArray alloc]init];
    for (id<NSCopying> key in self.mutableTracks) {
        [trackIdentifiers addObject:key];
    }
    return [NSArray arrayWithArray:trackIdentifiers];
}

// Registering inputs method
- (void) registerInput:(SESequencerInput *)input
    forTrackIdentifier:(NSString *)identifier
{
    SESequencerTrack *track = self.mutableTracks[identifier];
    if (!track) {
         // CR:Fixed Never ever do such a thing again. Replace the nested calls with
         //     the lines given below.
         //
         //     track = [[SESequencerTrack alloc]initWithidentifier:identifier];
         //     [self.mutableTracks setObject:track forKey:identifier];
         //
         // Fixed.
        track = [[SESequencerTrack alloc]initWithidentifier:identifier];
        self.mutableTracks[identifier] = track;
    }
    input.delegate = self;
    input.track = track;
    // CR:Fixed None of the sequencers should know about any inputs.
    // Fixed.
}

// Registering outputs method
- (void) registerOutput:(SESequencerOutput *)output
    forTrackWithIdentifier:(NSString *)identifier
{
    // CR:  None of the equesncers should know about outputs.
    //      IMHO, a track may have a weak pointer to an output.
    //      How do you think?
    
    // I think tha your idea with Output and linking with KVO is extremely good!)
    SESequencerTrack *track = self.mutableTracks[identifier];
    if (!track) {
        track = [[SESequencerTrack alloc]initWithidentifier:identifier];
        self.mutableTracks[identifier] = track;
    }
    [track registerOutput:output];
}

#pragma mark Playback Methods

- (BOOL) startRecording
{
    _recording = YES;
    self.startRecordingDate = [NSDate date];
    return YES;
}

/* Stop recording events to streams and convert all raw timestamps into PPQNTimestamps
 */
- (void) stopRecording
{
    _recording = NO;
    // ToDo: Get raw stop timestamp for correct processing convertation to PPQN
    // for last events in every stream
    NSTimeInterval stopRecordingTimeInterval = [[NSDate date]
        timeIntervalSinceDate:self.startRecordingDate];
    float singleQuarterPulse = (60/((float)[_tempo intValue]*defaultPPQN));
    for (id<NSCopying> key in self.mutableTracks) {
        for (SESequencerMessage *message in
            [[self.mutableTracks objectForKey:key]allMessages]) {
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
    self.expectedTick = 0;
    self.expectedTick = [self tickForNearestEvent];
    [self.systemTimer startWithPulsePeriod:(long)
        (defaultBPMtoPPQNTickConstant/[_tempo intValue])*1000 withDelegate:self];
#ifdef DEBUG_NSLOG
    NSLog(@"PPQN tick = %f",defaultBPMtoPPQNTickConstant/[_tempo intValue]);
#endif
}

- (void) stop
{
    [self.systemTimer stop];
}

- (void) pause
{
    [self.systemTimer stop];
}


#pragma mark SESequencerInputDelegate Methods
/* Receive event from source for stream number. If stream with number not exist return NO.
 * Else create event with raw timestamp and write to stream and try to send event to destination */
- (BOOL) receiveMessage:(SESequencerMessage *)message forTrack:(SESequencerTrack *)track
{
    if (!!track) {
        if (message == nil) {
            message = [[SESequencerMessage alloc]initWithRawTimestamp:[[NSDate date]
            timeIntervalSinceDate:self.startRecordingDate]];
        }
        // Write event to stream in Recording mode
        if (_recording) {
            [track addMessage:message];
        }
        // Send to output
        id __weak tempObjectForKey = [self.mutableOutputs objectForKey:[track identifier]];
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
    if (tick>=self.expectedTick) {
        self.expectedTick = (unsigned long)tick;
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
    for (id<NSCopying> identifier in self.mutableTracks) {
        track = [self.mutableTracks objectForKey:identifier];
        trackCurrentMessage = [track currentMessage];
        if ([trackCurrentMessage PPQNTimeStamp]<=self.expectedTick) {
            if (![[self.mutableInputs objectForKey:identifier]isMuted]) {
                [[self.mutableOutputs objectForKey:identifier]
                    receiveMessage:trackCurrentMessage];
            }
        [track goToNextMessage];
        }
    }
    self.expectedTick = [self tickForNearestEvent];
}

/* Find one nearest Event time (in ticks) in all streams. 
 * Return PPQN-value of nearest Event. 
 */
- (unsigned long) tickForNearestEvent
{
    unsigned long tickForNearestEvent = UINT32_MAX;
    // Process 0 tick (begin playing)
    if (self.expectedTick == 0) {
        for (id<NSCopying> identifier in self.mutableTracks) {
            [[self.mutableTracks objectForKey:identifier]
                setCurrentMessageCounter:@(0)];
        }
    }
    // Find nearest event
    for (id<NSCopying> identifier in self.mutableTracks) {
        unsigned long tempTick = [[[self.mutableTracks objectForKey:identifier]
            currentMessage]PPQNTimeStamp];
        if (tempTick<tickForNearestEvent) {
            tickForNearestEvent = tempTick;
        }
    }
    return tickForNearestEvent;
}

@end
