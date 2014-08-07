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
#define DEFAULT_SIGNATURE_UPPERPART 4;
#define DEFAULT_SIGNATURE_LOWERPART noteDividerQuarter;

/* Set default PPQN */
#define DEFAULT_PPQN_VALUE 96.0;

/* Constant for convertion BPM to single PPQN time in usec */
#define BPM_TO_PPQN_TICK_CONSTANT 60000000.0/DEFAULT_PPQN_VALUE;

static float const defaultPPQN = DEFAULT_PPQN_VALUE;
static float const defaultBPMtoPPQNTickConstant = BPM_TO_PPQN_TICK_CONSTANT;
static NSInteger const defaultTimeSignatureUpperPart = DEFAULT_SIGNATURE_UPPERPART;
static SENoteDividerValue const defaultTimeSignatureLowerPart = noteDividerQuarter;
static NSString *const kDefaultMetronomeOutputIdentifier = @"Metronome Output";
static NSString *const kDefaultMetronomeSyncOutputIdentifier = @"Metronome Sync Output";

#pragma mark - Inputs Extension

@interface SESequencerInput ()

@property (nonatomic, weak) SESequencerTrack *track;
@property (nonatomic, weak) id<SEInputDelegate> delegate;

@end

#pragma mark - Sequencer Extension

// Private interface section
@interface SESequencer () <SESystemTimerDelegate, SEInputDelegate>

@property (nonatomic, strong) NSMutableDictionary *mutableTracks;
@property (nonatomic, strong) NSDate *startRecordingDate;
@property (nonatomic, strong) SESystemTimer *systemTimer;
@property (nonatomic, readwrite) unsigned long expectedTick;

@property (nonatomic, readwrite) NSInteger bar;
@property (nonatomic, readwrite) NSInteger teilInBar;
@property (nonatomic, readwrite) NSInteger ticksPerTeil;
@property (nonatomic, readwrite) unsigned long ticksForLastTeil;
@property (nonatomic, readwrite) uint64_t currentTick;

- (void) processExpectedTick;
- (unsigned long) tickForNearestEvent;

@end


#pragma mark - Inputs Implementation

@implementation SESequencerInput

#pragma mark Inits

- (instancetype)init
{
    NSLog(@"Method shouldn't be called. Please use an -initWithIdentifier: method.");
    return nil;
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
    [self.delegate input:self didGenerateMessage:[SESequencerMessage defaultMessage]];
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
        _tempo = DEFAULT_TEMPO_VALUE;
        _systemTimer = [[SESystemTimer alloc]initWithDelegate:self];
        self.timeSignature = (SETimeSignature){defaultTimeSignatureUpperPart,
            defaultTimeSignatureLowerPart};
        _metronomeOutput = [[SESequencerOutput alloc]
            initWithIdentifier:kDefaultMetronomeOutputIdentifier];
        _metronomeSyncOutput = [[SESequencerOutput alloc]
            initWithIdentifier:kDefaultMetronomeSyncOutputIdentifier];
        _click = YES;
    }
    return self;
}

#pragma mark -
#pragma mark Tracks Methods

// Creating streams methods
- (void) addExistingTrack:(SESequencerTrack *)track
{
    // CR:  It's not a sequencer's responsibility to provide an identifier for track.
    //      We've already discussed it.
    if ([track identifier]) {
        [self.mutableTracks setObject:track forKey:[track identifier]];
    }
}

// Removing tracks methods
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier
{
    [self.mutableTracks setValue:nil forKey:identifier];
    return YES;
}

- (void) removeAllTracks
{
    [self.mutableTracks removeAllObjects];
}

// Returns identifiers for all tracks that contained in Sequencer
- (NSArray *)trackIdentifiers
{
    return [self.mutableTracks allKeys];
}

// Registering inputs method
- (void) registerInput:(SESequencerInput *)input
    forTrackIdentifier:(NSString *)identifier
{
    SESequencerTrack *track = self.mutableTracks[identifier];
    if (!track) {
        track = [[SESequencerTrack alloc]initWithidentifier:identifier];
        self.mutableTracks[identifier] = track;
    }
    input.delegate = self;
    input.track = track;
}

// Registering outputs method
- (void) registerOutput:(SESequencerOutput *)output
    forTrackIdentifier:(NSString *)identifier
{
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
    SESequencerTrack *track = nil;
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        [track removeAllMessages];
    }
    _recording = YES;
    self.startRecordingDate = [NSDate date];
    return YES;
}

/* Stop recording events to streams and convert all raw timestamps into PPQNTimestamps
 */
- (void) stopRecording
{
    _recording = NO;
    SESequencerTrack *track = nil;
    NSTimeInterval stopRecordingTimeInterval = [[NSDate date]
        timeIntervalSinceDate:self.startRecordingDate];
    float singleQuarterPulse = (60/((float)_tempo*defaultPPQN));
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        [track quantizeWithPPQNPulseDuration:singleQuarterPulse
            stopTimeInterval:stopRecordingTimeInterval];
    }
}

/* Play all streams, so what can else say. */
- (void) playAllStreams
{
    // Check arrays for elements
    SESequencerTrack *track = nil;
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        if (![[track allMessages]count]) {
            NSLog(@"Nothing to play in track with identifier: %@", track.identifier);
            return;
        }
    }
    _playing = YES;
    self.expectedTick = 0;
    // Process start tick
    [self processExpectedTick];
    [self.systemTimer startWithPulsePeriod:(long)
        (defaultBPMtoPPQNTickConstant/_tempo)*1000];
#ifdef DEBUG_NSLOG
    NSLog(@"PPQN tick = %f",defaultBPMtoPPQNTickConstant/_tempo);
#endif
}

- (void) stop
{
    [self.systemTimer stop];
    _playing = NO;
}

- (void) pause
{
    [self.systemTimer stop];
    _playing = NO;
}

#pragma mark Setters
- (void) setTimeSignature:(SETimeSignature)timeSignature
{
    _timeSignature = timeSignature;
    self.ticksPerTeil = [SEMusicTimebase ticksPerDuration:
        timeSignature.lowerPart withPPQN:defaultPPQN];
    self.bar = 0;
    self.teilInBar = 0;
}

#pragma mark SESequencerInputDelegate Methods
/* Receive event from source for stream number. If track is not exist return NO.
 * Else create event with raw timestamp and write to stream and try to send event to destination */
- (BOOL) input:(id)sender didGenerateMessage:(SESequencerMessage *)message
{
    SESequencerTrack *const __weak track = [sender track];
    if (!!track) {
        if (message == nil) {
            message = [[SESequencerMessage alloc]initWithRawTimestamp:[[NSDate date]
            timeIntervalSinceDate:self.startRecordingDate]];
        }
        // Write event to stream in Recording mode
        if (_recording) {
            message.rawTimestamp =[[NSDate date]timeIntervalSinceDate:self.startRecordingDate];
            [track addMessage:message];
        }
        // Send to output
        [track sendToOutput:message];
        return YES;
    }
    return NO;
}

#pragma mark SESystemTimerDelegate Protocol Methods
- (void) timer:(SESystemTimer *)timer didCountTick:(uint64_t)tick
{
    // Teils and bars counting
    self.currentTick = tick;
    if (tick - self.ticksForLastTeil>=self.ticksPerTeil) {
        self.teilInBar ++;
        if (self.teilInBar >= self.timeSignature.upperPart) {
            self.teilInBar = 0;
            self.bar = self.bar + 1;
        }
        self.ticksForLastTeil = self.ticksForLastTeil + self.ticksPerTeil;
        if (self.isClick) {
            NSLog(@"Click! Bar: %i Teil: %i", self.bar, self.teilInBar);
        }
    }
    if (!self.isRecording) {
        // Check for nearest event
        if (tick>=self.expectedTick) {
            self.expectedTick = (unsigned long)tick;
            [self processExpectedTick];
        }
    }
}

- (void) resetPlayhead
{
    // Reset self-playhead
    self.ticksForLastTeil = 0;
    self.bar = 0;
    self.teilInBar = 0;
    // Reset track-playheads
    SESequencerTrack *track = nil;
    for (id<NSCopying> identifier in self.mutableTracks) {
        track = [self.mutableTracks objectForKey:identifier];
        [track resetPlayhead];
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
        if (track.playHeadPosition<=self.expectedTick) {
        // ToDo: If isMuted
            [track sendToOutput:trackCurrentMessage];
            track.playHeadPosition = track.playHeadPosition + [trackCurrentMessage initialDuration];
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
    // Find nearest event
    for (id<NSCopying> identifier in self.mutableTracks) {
        unsigned long tempTick = [[self.mutableTracks objectForKey:identifier]playHeadPosition];
        if (tempTick<tickForNearestEvent) {
            tickForNearestEvent = tempTick;
        }
    }
    return tickForNearestEvent;
}

@end
