//
//  SESequencer.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SESystemTimerDelegate.h"
#import "SESequencerTrack.h"
#import "SEReceiverDelegate.h"
#import "SEInputDelegate.h"

#pragma mark - Inputs Interface
@interface SESequencerInput : NSObject
@property (nonatomic, readonly, copy) NSString *identifier;
// CR:  Please rename isMuted to isMute; follow the trend!
@property (nonatomic, readwrite, getter = isMuted) BOOL mute;

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier;

// Generate messages methods
- (void) generateMessage;
- (void) generateMessageWithParameters:(NSDictionary *)parameters;

@end

#pragma mark - Sequencer Interface
@interface SESequencer : NSObject

@property (nonatomic, readonly, getter = isRecording) BOOL recording;
// CR: Why do you use an NSNumber?
@property (nonatomic, strong) NSNumber *tempo;

#pragma mark -
#pragma mark Track Methods
// Creating tracks methods
// CR:  You can simply add a track; you should ask for an identifier.
//      I also think it's not really good to assign a track from the outside.
//      Could you please explain how a hardware sequencer "implements" such
//      a feature?
- (void) addExistingTrack:(SESequencerTrack *)track;

// Removing tracks methods
// CR:  I don't really think this API has to be public.
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier;
- (void) removeAllTracks;

// Info tracks methods
// CR: What for you provide such a method?
- (NSArray *)trackIdentifiers;

// Registering inputs and outputs methods
- (void) registerInput:(SESequencerInput *)input
    forTrackIdentifier:(NSString *)identifier;
    
- (void) registerOutput:(SESequencerOutput *)output
// CR:  I don't like the name of the method: it's too verbose.
//      At least remove 'with'.
    forTrackWithIdentifier:(NSString *)identifier;

#pragma mark Playback Methods
- (BOOL) startRecording;
- (void) stopRecording;
- (void) playAllStreams;
- (void) stop;
- (void) pause;


@end
