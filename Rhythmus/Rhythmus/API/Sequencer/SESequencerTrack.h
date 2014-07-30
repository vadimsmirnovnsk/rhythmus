//
//  SESequencerTrack.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESequencerMessage.h"

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

@end
