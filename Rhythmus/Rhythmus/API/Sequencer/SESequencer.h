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
#import "SESequencerInput.h"
#import "SEInputDelegate.h"

// CR:  I regret to say the class looks like a mess to me.
//      Why have you ignored my suggestion to use a dedicated branch?
//      It's really hard to review the source code.
//      It's also not a good practice to implement everything in one trip.
//      I guess we need to discuss it once again.

@interface SESequencer : NSObject
// CR: Are you sure these protocols have to be public? I doubt.
    <SESystemTimerDelegate, SEInputDelegate>

@property (nonatomic, readonly, getter = isRecording) BOOL recording;
@property (nonatomic, strong) NSNumber *tempo;

// CR:  Why do you use an NSNumber?
@property (nonatomic, readonly) NSNumber *tracksCount;
// CR:  What for do you need this?
@property (nonatomic, readonly) NSArray *trackNames;

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
// CR:  I don't like the name of the method: it's too verbose.
    forTrackWithIdentifier:(NSString *)identifier;
    
- (void) registerOutput:(id<SEReceiverDelegate>)output
    forTrackWithIdentifier:(NSString *)identifier;

#pragma mark Playback Methods
- (BOOL) startRecording;
- (void) stopRecording;
- (void) playAllStreams;
- (void) stop;
- (void) pause;


@end
