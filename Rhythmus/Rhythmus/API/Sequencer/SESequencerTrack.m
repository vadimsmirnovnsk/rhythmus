//
//  SESequencerTrack.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencerTrack.h"
#import "SEReceiverDelegate.h"

#pragma mark - Outputs Extension

@interface SESequencerOutput ()
@property (nonatomic, weak) id<SEReceiverDelegate> delegate;
@end

#pragma mark - Sequencer Track Extension

@interface SESequencerTrack ()

@property (nonatomic, strong) NSMutableArray *mutableMessages;
@property (nonatomic, weak) SESequencerOutput *output;

- (void) unregisterOutput;

@end

#pragma mark - Outputs Implementation

@implementation SESequencerOutput

- (instancetype) init
{
    //  CR: I'd say there is no way to create a new output with no identifier.
    return [self initWithIdentifier:nil];
}

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
    _identifier = [identifier copy];
    }
    return self;
}

- (void) linkWithReceiver:(id<SEReceiverDelegate>)receiver
{
    self.delegate = receiver;
}

@end


#pragma mark - Sequencer Track Implementation

@implementation SESequencerTrack

// Designated initializer
- (instancetype) initWithidentifier:(NSString *)identifier
{
    if (self=[super init]) {
        _mutableMessages = [[NSMutableArray alloc]init];
        _currentMessageCounter = 0;
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
    return self.mutableMessages[self.currentMessageCounter];
}

- (void) sendToOutput:(SESequencerMessage *)message
{
    [self.output.delegate receiveMessage:message];
}

- (void) removeCurrentMessage
{
    if ((!!_currentMessageCounter) &&
        (_currentMessageCounter<=[self.mutableMessages count])) {
        [self.mutableMessages removeObjectAtIndex:_currentMessageCounter];
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
    if (self.currentMessageCounter<[self.mutableMessages count]-1) {
        self.currentMessageCounter = self.currentMessageCounter + 1;
    }
    else {
        self.currentMessageCounter = 0;
    }
}

// Quantize to PPQN pulses and Stop Timeinterval
- (void) quantizeWithPPQNPulseDuration:(float)singleQuarterPulse
    stopTimeInterval:(NSTimeInterval)stopTimeInterval
{
    SESequencerMessage *previousMessage = nil;
    SESequencerMessage *endMessage = nil;
    for (SESequencerMessage *message in self.mutableMessages) {
        message.PPQNTimeStamp = message.rawTimestamp/singleQuarterPulse;
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
            previousMessage = [self.mutableMessages objectAtIndex:
                [self.mutableMessages indexOfObject:message]-1];
            message.type = messageTypeSample;
            message.initialDuration = message.PPQNTimeStamp - previousMessage.PPQNTimeStamp;
        }
        NSLog(@"Message %i quantized.\nType: %i\nPPQNTimestamp: %lu\nInitialDuration:%i",
            index, message.type, message.PPQNTimeStamp, message.initialDuration);
    }
    if (endMessage) {
        [self.mutableMessages addObject:endMessage];
    }
}

// Reset track playing state
- (void) resetPlayhead
{
    self.playHeadPosition = 0;
    self.currentMessageCounter = 0;
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

    // CR:  This looks like a magic to me.
    [output addObserver:self forKeyPath:@"delegate"
        options:NSKeyValueObservingOptionNew context:nil];
}

// KVO draft method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
    change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"delegate"]) {
        if (![self.output delegate]) {
            [self unregisterOutput];
        }
    }
}


#pragma mark Private Methods

- (void) unregisterOutput
{
    [self.output removeObserver:self forKeyPath:@"delegate"];
    self.output = nil;
}

#pragma mark NSCopying Protocol Methods

- (id) copyWithZone:(NSZone *)zone
{
    SESequencerTrack *newTrack = [[[self class]allocWithZone:zone]init];
    newTrack.mutableMessages = [self.mutableMessages copy];
    newTrack.identifier = [NSString stringWithFormat:@"%@ copy",self.identifier];
    return newTrack;
}

@end
