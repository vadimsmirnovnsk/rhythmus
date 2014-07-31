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

- (void) linkWith:(id<SEReceiverDelegate>)receiver
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
        _currentMessageCounter = @(0);
        identifier = identifier;
        _output = nil;
    }
    return self;
}

/* Add message to sequencer track */
- (void) addMessage:(SESequencerMessage *)message
{
    [self.mutableMessages addObject:message];
}

- (void) removeCurrentMessage
{
    if ((!!_currentMessageCounter) &&
        ([_currentMessageCounter intValue]<=[self.mutableMessages count])) {
        [self.mutableMessages removeObjectAtIndex:[_currentMessageCounter intValue]];
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

/* Move counter to the next Event or loop to 0. */
- (void) goToNextMessage
{
    if ([_currentMessageCounter intValue]<[self.mutableMessages count]-1) {
        _currentMessageCounter = @([_currentMessageCounter intValue]+1);
    }
    else {
    _currentMessageCounter = @(0);
    }
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
