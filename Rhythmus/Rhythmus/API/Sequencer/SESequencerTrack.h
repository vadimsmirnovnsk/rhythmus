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

@interface SESequencerOutput : NSObject
@property (nonatomic, readonly, copy) NSString *identifier;

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier;

// Linking the Destination object
- (void) linkWith:(id<SEReceiverDelegate>)receiver;

@end

#pragma mark - Sequencer Track Interface

@interface SESequencerTrack : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, weak, readonly) SESequencerMessage *currentMessage;
@property (nonatomic, readwrite) NSInteger currentMessageCounter;

// Designated initializer
- (instancetype) initWithidentifier: (NSString *)identifier;

// Messages methods
- (void) addMessage:(SESequencerMessage *)message;
- (void) sendToOutput:(SESequencerMessage *)message;
- (void) removeCurrentMessage;
- (BOOL) removeMessagesAtIndexes:(NSIndexSet *)indexSet;
- (void) goToNextMessage;

// Return array with all messages that contains in Track
- (NSArray *) allMessages;

// Register output method
- (void) registerOutput:(SESequencerOutput *)output;

@end
