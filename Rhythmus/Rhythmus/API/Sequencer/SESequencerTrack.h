//
//  SESequencerTrack.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESequencerMessage.h"
#import "SEReceiverDelegate.h"

#pragma mark - Outputs Interface
// CR:  This class has to be a part of the SESequencer.
@interface SESequencerOutput : NSObject
@property (nonatomic, readonly, copy) NSString *identifier;

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier;

// Linking the Destination object
// CR:  Link with what? With a carrot? Or may be with an elephant?
- (void) linkWith:(id<SEReceiverDelegate>)receiver;

@end

#pragma mark - Sequencer Track Interface
// CR:  This class has to be private; define it within the SESequencer.m
@interface SESequencerTrack : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, weak) SESequencerMessage *currentMessage;
@property (nonatomic, strong) NSNumber *currentMessageCounter;

// Designated initializer
- (instancetype) initWithidentifier: (NSString *)identifier;

// Messages methods
- (void) addMessage:(SESequencerMessage *)message;
- (void) removeCurrentMessage;
- (BOOL) removeMessagesAtIndexes:(NSIndexSet *)indexSet;
- (void) goToNextMessage;

// Return array with all messages that contains in Track
- (NSArray *) allMessages;

// Register output method
- (void) registerOutput:(SESequencerOutput *)output;

@end
