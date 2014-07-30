//
//  SESequencerTrack.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencerTrack.h"

@interface SESequencerTrack ()

@property (nonatomic, strong) NSMutableArray *mutableMessages;

@end

@implementation SESequencerTrack

// Designated initializer
- (instancetype) initWithidentifier:(NSString *)identifier
{
    if (self=[super init]) {
        _mutableMessages = [[NSMutableArray alloc]init];
        _currentMessageCounter = @(0);
        identifier = identifier;
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

#pragma mark NSCopying Protocol Methods

- (id) copyWithZone:(NSZone *)zone
{
    SESequencerTrack *newTrack = [[[self class]allocWithZone:zone]init];
    newTrack.mutableMessages = [self.mutableMessages copy];
    newTrack.identifier = [NSString stringWithFormat:@"%@ copy",self.identifier];
    return newTrack;
}

@end
