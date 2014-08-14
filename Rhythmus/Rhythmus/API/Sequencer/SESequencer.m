
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
static NSString *const kDefaultPadsFeedbackOutputIdentifier = @"Pads Feedback Output";


#pragma mark - Sequencer Track Interface

@interface SESequencerTrack : NSObject <NSCopying>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, weak, readonly) SESequencerMessage *currentMessage;
@property (nonatomic, readwrite) unsigned long playHeadPosition;

// Designated initializer
- (instancetype) initWithidentifier: (NSString *)identifier;

// Messages methods
- (void) addMessage:(SESequencerMessage *)message;
- (void) sendToOutput:(SESequencerMessage *)message;
- (void) removeCurrentMessage;
- (BOOL) removeMessagesAtIndexes:(NSIndexSet *)indexSet;
- (void) removeAllMessages;
- (void) goToNextMessage;

// Return array with all messages that contains in Track
- (NSArray *) allMessages;

// Register output method
- (void) registerOutput:(SESequencerOutput *)output;

// Quantize to PPQN pulses
- (void) quantizeWithPPQNPulseDuration:(float)singleQuarterPulse
    stopTimeInterval:(NSTimeInterval)stopTimeInterval;

// Quantize to PPQN pulses
- (void) quantizeWithPPQNPulseDuration:(float)singleQuarterPulse
    stopTick:(unsigned long)stopTick;

// Playhead methods
- (void) resetPlayhead;

@end


#pragma mark - Sequencer Track Extension

@interface SESequencerTrack ()

@property (nonatomic, strong) NSMutableArray *mutableMessages;
@property (nonatomic, weak) SESequencerOutput *output;
@property (nonatomic, readwrite) NSInteger messageCounter;

- (void) unregisterOutput;

@end


#pragma mark - Inputs Extension

@interface SESequencerInput ()

@property (nonatomic, weak) SESequencerTrack *track;
@property (nonatomic, weak) id<SEInputDelegate> delegate;

@end


#pragma mark - Sequencer Extension

@interface SESequencer () <SESystemTimerDelegate, SEInputDelegate>

@property (nonatomic, strong) NSMutableDictionary *mutableTracks;
@property (nonatomic, strong) NSDate *startRecordingDate; // TODO: remove startRecodringDate
@property (nonatomic, readwrite) unsigned long startRecordingTick;
@property (nonatomic, strong) SESystemTimer *systemTimer;
@property (nonatomic, readwrite) unsigned long expectedTick;

@property (nonatomic, readwrite) NSInteger bar;
@property (nonatomic, readwrite) NSInteger teilInBar;
@property (nonatomic, readwrite) NSInteger ticksPerTeil;
@property (nonatomic, readwrite) unsigned long ticksForLastTeil;
@property (nonatomic, readwrite) uint64_t currentTick;

@property (nonatomic, readwrite, getter = isRecording) BOOL recording;
@property (nonatomic, readwrite, getter = isPlaying) BOOL playing;
@property (nonatomic, readwrite, getter = isPreparing) BOOL preparing;

@property (nonatomic, copy) NSString *timeStampStringValue;

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


#pragma mark - Outputs Implementation

@implementation SESequencerOutput

- (instancetype) init
{
    NSLog(@"Method shouldn't be called. Please use an -initWithIdentifier method.");
    return nil;
}

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
    _identifier = [identifier copy];
    }
    return self;
}


@end


#pragma mark - Sequencer Track Implementation

@implementation SESequencerTrack

- (instancetype)init
{
    NSLog(@"Method shouldn't be called. Please use an -initWithIdentifier method.");
    return nil;
}

// Designated initializer
- (instancetype) initWithidentifier:(NSString *)identifier
{
    if (self=[super init]) {
        _mutableMessages = [[NSMutableArray alloc]init];
        _messageCounter = 0;
        _identifier = [identifier copy];
        _output = nil;
        _playHeadPosition = 0;
    }
    return self;
}

/* Add message to sequencer track */
- (void) addMessage:(SESequencerMessage *)message
{
    [self.mutableMessages addObject:message];
}

- (SESequencerMessage *)currentMessage {
    if (self.messageCounter<[self.mutableMessages count]) {
        return self.mutableMessages[self.messageCounter];
    }
    else {
        return nil;
    }
}

- (void) sendToOutput:(SESequencerMessage *)message
{
    [self.output.delegate output:self.output didGenerateMessage:message];
}

- (void) removeCurrentMessage
{
    if ((!!self.messageCounter) &&
        (self.messageCounter<=[self.mutableMessages count])) {
        [self.mutableMessages removeObjectAtIndex:self.messageCounter];
    }
}


- (BOOL) removeMessagesAtIndexes:(NSIndexSet *)indexSet
{
    if ([self.mutableMessages objectsAtIndexes:indexSet]) {
        [self.mutableMessages removeObjectsAtIndexes:indexSet];
        return YES;
    }
    return NO;
}

- (void)removeAllMessages
{
    [self.mutableMessages removeAllObjects];
}

/* Move counter to the next Event or loop to 0. */
- (void) goToNextMessage
{
    if (self.messageCounter<[self.mutableMessages count]-1) {
        self.messageCounter = self.messageCounter + 1;
    }
    else {
        self.messageCounter = 0;
    }
}

// Quantize to PPQN pulses and Stop Timeinterval
- (void) quantizeWithPPQNPulseDuration:(float)singleQuarterPulse
    stopTimeInterval:(NSTimeInterval)stopTimeInterval
{
    SESequencerMessage *previousMessage = nil;
    SESequencerMessage *endMessage = nil;
    for (SESequencerMessage *message in self.mutableMessages) {
        if (message.PPQNTimeStamp == 0) {
            message.PPQNTimeStamp = message.rawTimestamp/singleQuarterPulse;
        }
        NSInteger index = [self.mutableMessages indexOfObject:message];
        // Process first trigger-message in track and convert it to pause.
        if (index == 0) {
            message.type = messageTypePause;
            message.initialDuration = message.rawTimestamp/singleQuarterPulse;
            // If array contains only 1 message
            if (index == [self.mutableMessages count]-1) {
                // Create last message on track for duration-messages processing
                endMessage = [SESequencerMessage defaultMessage];
                endMessage.PPQNTimeStamp = stopTimeInterval/singleQuarterPulse;
                endMessage.type = messageTypeSample;
                endMessage.initialDuration = endMessage.PPQNTimeStamp - message.PPQNTimeStamp;
            }
        }
        // Process last trigger-message
        else if (index == [self.mutableMessages count]-1) {
            previousMessage = [self.mutableMessages objectAtIndex:
                [self.mutableMessages indexOfObject:message]-1];
            message.type = messageTypeSample;
            message.initialDuration = message.PPQNTimeStamp - previousMessage.PPQNTimeStamp;
            // Create last message on track for duration-messages processing
            endMessage = [SESequencerMessage defaultMessage];
            endMessage.PPQNTimeStamp = stopTimeInterval/singleQuarterPulse;
            endMessage.type = messageTypeSample;
            endMessage.initialDuration = endMessage.PPQNTimeStamp - message.PPQNTimeStamp;
        }
        // Process all other-within messages
        else {
            NSUInteger const index = [self.mutableMessages indexOfObject:message];
            NSAssert((index != NSNotFound), 
                     @"A sequencer has failed to detect an index of a message.");
            NSAssert((index > 0), @"A message index is out of bounds.");
            previousMessage = [self.mutableMessages objectAtIndex:(index - 1)];
            message.type = messageTypeSample;
            message.initialDuration = message.PPQNTimeStamp - previousMessage.PPQNTimeStamp;
        }
    }
    if (endMessage) {
        [self.mutableMessages addObject:endMessage];
    }
}

- (void) quantizeWithPPQNPulseDuration:(float)singleQuarterPulse
    stopTick:(unsigned long)stopTick
{
    // Process empty track: add only 1 pause message
    if ([self.mutableMessages count] == 0) {
        SESequencerMessage *zeroMessage = [SESequencerMessage defaultMessage];
        zeroMessage.PPQNTimeStamp = stopTick;
        zeroMessage.type = messageTypePause;
        zeroMessage.initialDuration = stopTick;
        [self addMessage:zeroMessage];
        return;
    }
    SESequencerMessage *previousMessage = nil;
    SESequencerMessage *endMessage = nil;
    for (SESequencerMessage *message in self.mutableMessages) {
        NSInteger index = [self.mutableMessages indexOfObject:message];
        // Process first trigger-message in track and convert it to pause.
        if (index == 0) {
            message.type = messageTypePause;
            message.initialDuration = message.PPQNTimeStamp;
            // If array contains only 1 message
            if (index == [self.mutableMessages count]-1) {
                // Create last message on track for duration-messages processing
                endMessage = [SESequencerMessage defaultMessage];
                endMessage.PPQNTimeStamp = stopTick;
                endMessage.type = messageTypeSample;
                endMessage.initialDuration = endMessage.PPQNTimeStamp - message.PPQNTimeStamp;
            }
        }
        // Process last trigger-message
        else if (index == [self.mutableMessages count]-1) {
            previousMessage = [self.mutableMessages objectAtIndex:
                [self.mutableMessages indexOfObject:message]-1];
            message.type = messageTypeSample;
            message.initialDuration = message.PPQNTimeStamp - previousMessage.PPQNTimeStamp;
            // Create last message on track for duration-messages processing
            endMessage = [SESequencerMessage defaultMessage];
            endMessage.PPQNTimeStamp = stopTick;
            endMessage.type = messageTypeSample;
            endMessage.initialDuration = endMessage.PPQNTimeStamp - message.PPQNTimeStamp;
        }
        // Process all other-within messages
        else {
            previousMessage = [self.mutableMessages objectAtIndex:
                [self.mutableMessages indexOfObject:message]-1];
            message.type = messageTypeSample;
            message.initialDuration = message.PPQNTimeStamp - previousMessage.PPQNTimeStamp;
        }
    }
    if (endMessage) {
        [self.mutableMessages addObject:endMessage];
    }

}

// Reset track playing state
- (void) resetPlayhead
{
    self.playHeadPosition = 0;
    self.messageCounter = 0;
}

// Return array with all messages that contains in Track
- (NSArray *) allMessages
{
    return [self.mutableMessages copy];
}

// Register output method
- (void) registerOutput:(SESequencerOutput *)output
{
    self.output = output;
    [output addObserver:self forKeyPath:NSStringFromSelector(@selector(delegate))
        options:NSKeyValueObservingOptionNew context:nil];
}

// KVO draft method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
    change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(delegate))]) {
        if (![self.output delegate]) {
            [self unregisterOutput];
        }
    }
}


#pragma mark Private Methods
- (void) unregisterOutput
{
    [self.output removeObserver:self forKeyPath:NSStringFromSelector(@selector(delegate))];
    self.output = nil;
}

#pragma mark NSCopying Protocol Methods
- (id) copyWithZone:(NSZone *)zone
{
    SESequencerTrack *newTrack = [[[self class]allocWithZone:zone]init];
    newTrack.mutableMessages = [self.mutableMessages mutableCopy];
    newTrack.identifier = [NSString stringWithFormat:@"%@ copy",self.identifier];
    newTrack.output = self.output;
    newTrack.messageCounter = self.messageCounter;
    newTrack.playHeadPosition = self.playHeadPosition;
    return newTrack;
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
        _systemTimer = [[SESystemTimer alloc]init];
        _systemTimer.delegate = self;

        self.timeSignature = (SETimeSignature){defaultTimeSignatureUpperPart,
            defaultTimeSignatureLowerPart};

        _metronomeOutput = [[SESequencerOutput alloc]
            initWithIdentifier:kDefaultMetronomeOutputIdentifier];
        _metronomeSyncOutput = [[SESequencerOutput alloc]
            initWithIdentifier:kDefaultMetronomeSyncOutputIdentifier];
        _metronomeSyncOutput2 = [[SESequencerOutput alloc]
            initWithIdentifier:kDefaultMetronomeSyncOutputIdentifier];
        _padsFeedbackOutput = [[SESequencerOutput alloc]
            initWithIdentifier:kDefaultPadsFeedbackOutputIdentifier];
        _click = YES;
        _teilInBar = 0;
    }
    return self;
}


#pragma mark Tracks Methods
// Removing tracks methods
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier
{
    if (self.mutableTracks[identifier]) {
        [self.mutableTracks setValue:nil forKey:identifier];
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

// Load new data for track with identifier
- (void)loadData:(NSArray *)trackData forTrackIdentifier:(NSString *)identifier
{
    if (self.mutableTracks[identifier]) {
        [self.mutableTracks[identifier]setMutableMessages:[trackData mutableCopy]];
    }
}

// Get track data for saving in a pattern or processing in the redactor
- (NSArray *)dataForTrackIdentifier:(NSString *)identifier
{
    if (self.mutableTracks[identifier]) {
        return [self.mutableTracks[identifier]allMessages];
    }
    else {
        return nil;
    }
}

#pragma mark Playback Methods
- (BOOL) startRecording
{
    if (self.isPreparing || self.isRecording || self.isPlaying) {
        return NO;
    }
    [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
         didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
         parameters:@{kMetronomeWillStartParameter: kMetronomeWillStartParameter}]];
    [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
         didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
         parameters:@{kMetronomeWillStartParameter: kMetronomeWillStartParameter}]];
    SESequencerTrack *track = nil;
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        [track removeAllMessages];
    }
    _recording = YES;
    self.startRecordingDate = [NSDate date];
    return YES;
}

- (void)startRecordingWithPrepare
{
    if (self.isPreparing || self.isRecording || self.isPlaying) {
        return;
    }
    SESequencerTrack *track = nil;
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        [track removeAllMessages];
    }
    self.preparing = YES;
    self.teilInBar = -1;
    [self.padsFeedbackOutput.delegate output:self.padsFeedbackOutput didGenerateMessage:[SESequencerMessage messageWithType:messageTypeSystemPrepare parameters:
                    @{kSequencerPrepareWillStartParameter: kSequencerPrepareWillStartParameter}]];
    [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
        parameters:@{kMetronomeWillStartParameter: kMetronomeWillStartParameter}]];
    [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
        parameters:@{kMetronomeWillStartParameter: kMetronomeWillStartParameter}]];
    [self.systemTimer startWithPulsePeriod:(long)
        (defaultBPMtoPPQNTickConstant/_tempo)*1000];
}

/* Stop recording events to streams and convert all raw timestamps into PPQNTimestamps
 */
- (void) stopRecording
{
    if (self.isPreparing) {
        [self.padsFeedbackOutput.delegate output:self.padsFeedbackOutput
            didGenerateMessage:[SESequencerMessage
            messageWithType:messageTypeSystemPrepare parameters:
            @{kSequencerPrepareWillAbortParameter:kSequencerPrepareWillAbortParameter}]];
    }
    [self.systemTimer stop];
    self.startRecordingTick = 0;
    self.bar = self.bar + 1;
    self.teilInBar = - 1;
    unsigned long stopRecordingTick = (self.bar ? self.bar : 1)
     * self.timeSignature.upperPart *
     [SEMusicTimebase ticksPerDuration:self.timeSignature.lowerPart withPPQN:defaultPPQN];
    SESequencerTrack *track = nil;
    float singleQuarterPulse = (60/((float)_tempo*defaultPPQN));
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        [track quantizeWithPPQNPulseDuration:singleQuarterPulse
            stopTick:stopRecordingTick];
    }
    [self.padsFeedbackOutput.delegate output:self.padsFeedbackOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeWorkspaceFeedback
        parameters:@{kSequencerDidFifnishRecordingWithLastBar:@(self.bar)}]];
    [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
        parameters:@{kMetronomeWillStopParameter: kMetronomeWillStopParameter}]];
    [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
        parameters:@{kMetronomeWillStopParameter: kMetronomeWillStopParameter}]];
}

/* Play all streams, so what can else say. */
- (BOOL) playAllStreams
{
    if (self.isPreparing || self.isRecording || self.isPlaying) {
        return YES;
    }
    // Check arrays for elements
    SESequencerTrack *track = nil;
    for (id<NSCopying> key in self.mutableTracks) {
        track = self.mutableTracks[key];
        if (![[track allMessages]count]) {
            NSLog(@"Nothing to play in track with identifier: %@", track.identifier);
            return NO;
        }
    }
    self.playing = YES;
    self.expectedTick = 0;
    // Process start tick
    [self processExpectedTick];
    [self.metronomeOutput.delegate output:self.metronomeOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeClick
                parameters:@{@"Bar":@(self.bar), @"Teil":@(self.teilInBar)}]];
    [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
                parameters:@{kMetronomeWillStartParameter: kMetronomeWillStartParameter}]];
    [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
                parameters:@{@"Bar":@(self.bar), @"Teil":@(self.teilInBar)}]];
    [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
                parameters:@{kMetronomeWillStartParameter: kMetronomeWillStartParameter}]];
    [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
                parameters:@{@"Bar":@(self.bar), @"Teil":@(self.teilInBar)}]];
    [self.systemTimer startWithPulsePeriod:(long)
        (defaultBPMtoPPQNTickConstant/_tempo)*1000];
#ifdef DEBUG_NSLOG
    NSLog(@"PPQN tick = %f",defaultBPMtoPPQNTickConstant/_tempo);
#endif
    return YES;
}

- (void) stop
{
    [self.systemTimer stop];
    [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
        parameters:@{kMetronomeWillStopParameter: kMetronomeWillStopParameter}]];
    [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
        didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
        parameters:@{kMetronomeWillStopParameter: kMetronomeWillStopParameter}]];
}

- (void) pause
{
    [self.systemTimer stop];
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

- (void)setTimeStampStringValue:(NSString *)timeStampStringValue
{
    NSString *barSubstring = nil;
    NSString *teilSubstring = nil;
    if (self.teilInBar < 9) {
        teilSubstring = [NSString stringWithFormat:@"0%i",self.teilInBar + 1];
    }
    else {
        teilSubstring = [NSString stringWithFormat:@"%i",self.teilInBar + 1];
    }
    if (self.bar < 10) {
        barSubstring = [NSString stringWithFormat:@"00%i", self.bar + 1];
    }
    else if (self.bar < 100) {
        barSubstring = [NSString stringWithFormat:@"0%i", self.bar + 1];
    }
    else {
        barSubstring = [NSString stringWithFormat:@"%i",self.bar + 1];
    }
    _timeStampStringValue = [NSString stringWithFormat:@"%@:%@",
        barSubstring, teilSubstring];
}


- (void) setTempo:(NSInteger)tempo
{
    _tempo = tempo;
    // TODO: Make changing tempo in runtime. Rewrite systemTimer with NSThread.
    // self.systemTimer.period = (defaultBPMtoPPQNTickConstant/_tempo)*1000;
}

#pragma mark Private Methods
- (void) processExpectedTick
{
    SESequencerMessage *__weak trackCurrentMessage = nil;
    SESequencerTrack *__weak track = nil;
    for (id<NSCopying> identifier in self.mutableTracks) {
        track = [self.mutableTracks objectForKey:identifier];
        trackCurrentMessage = [track currentMessage];
        if (track.playHeadPosition<=self.expectedTick) {
        // ToDo: If isMuted
            if (trackCurrentMessage.type != messageTypePause) {
                [track sendToOutput:trackCurrentMessage];
                [self.padsFeedbackOutput.delegate output:self.padsFeedbackOutput didGenerateMessage:[SESequencerMessage messageWithType:messageTypeWorkspaceFeedback parameters:
                    @{kSequencerPadsFeedbackParameter: track.identifier}]];
            }
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

#pragma mark SESequencerInputDelegate Methods
/* Receive event from source for stream number. If track is not exist return NO.
 * Else create event with raw timestamp and write to stream and try to send event to destination */
- (BOOL) input:(id)sender didGenerateMessage:(SESequencerMessage *)message
{
    SESequencerTrack *const track = [sender track];
    if (!!track) {
        if (message == nil) {
            message = [[SESequencerMessage alloc]initWithRawTimestamp:[[NSDate date]
            timeIntervalSinceDate:self.startRecordingDate] type:messageTypeDefault parameters:nil];
        }
        // Write event to stream in Recording mode
        if (self.recording) {
            if (self.startRecordingTick!=0) {
                message.PPQNTimeStamp = (unsigned long)self.currentTick - self.startRecordingTick;
            }
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
        self.teilInBar = self.teilInBar + 1;
        if (self.teilInBar >= self.timeSignature.upperPart) {
            self.teilInBar = 0;
            self.bar = self.bar + 1;
        }
        self.ticksForLastTeil = self.ticksForLastTeil + self.ticksPerTeil;
        if (self.isClick) {
            [self.metronomeOutput.delegate output:self.metronomeOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeClick
                parameters:@{@"Bar":@(self.bar), @"Teil":@(self.teilInBar)}]];
            [self.metronomeSyncOutput.delegate output:self.metronomeSyncOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
                parameters:@{@"Bar":@(self.bar), @"Teil":@(self.teilInBar)}]];
            [self.metronomeSyncOutput2.delegate output:self.metronomeSyncOutput
                didGenerateMessage:[SESequencerMessage messageWithType:messageTypeMetronomeSync
                parameters:@{@"Bar":@(self.bar), @"Teil":@(self.teilInBar)}]];
                // Process preparing ticks
                if (self.isPreparing) {
                    [self processPreparingTime];
                }
        }
    }
    // Set actual timestamp
    if (!self.isPreparing) {
        [self setTimeStampStringValue:nil];
    }
    // Process play tracks
    if (!self.isRecording && !self.preparing) {
        // Check for nearest event
        if (tick>=self.expectedTick) {
            self.expectedTick = (unsigned long)tick;
            [self processExpectedTick];
        }
    }
}

- (void) processPreparingTime
{
    if (self.isPreparing && self.isRecording) {
        self.startRecordingDate = [NSDate date];
        self.startRecordingTick = (unsigned long)self.currentTick;
        self.preparing = NO;
    }
    if (self.timeSignature.upperPart - 1 == self.teilInBar) {
        [self.padsFeedbackOutput.delegate output:self.padsFeedbackOutput
            didGenerateMessage:[SESequencerMessage
            messageWithType:messageTypeSystemPrepare parameters:
            @{kSequencerRecordWillStartParameter:kSequencerRecordWillStartParameter}]];
        self.bar = 0;
        self.teilInBar = -1;
        self.preparing = YES;
        self.recording = YES;
    }
    else {
        [self.padsFeedbackOutput.delegate output:self.padsFeedbackOutput
                didGenerateMessage:[SESequencerMessage
                messageWithType:messageTypeSystemPrepare parameters:
                @{kSequencerPrepareDidClickWithTeil:
                @(self.timeSignature.upperPart - self.teilInBar - 1)}]];
    }

}

- (void) timerDidStop:(SESystemTimer *)timer
{
    // Reset self-playhead
    self.playing = NO;
    self.recording = NO;
    self.preparing = NO;
    self.ticksForLastTeil = 0;
    self.bar = 0;
    self.teilInBar = 0;
    [self setTimeStampStringValue:nil];
    // Reset track-playheads
    SESequencerTrack *track = nil;
    for (id<NSCopying> identifier in self.mutableTracks) {
        track = [self.mutableTracks objectForKey:identifier];
        [track resetPlayhead];
    }
}

@end
