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

@interface SESequencer : NSObject <SESystemTimerDelegate, SEInputDelegate>

@property (nonatomic, readonly, getter = isRecording) BOOL recording;
@property (nonatomic, strong) NSNumber *tempo;
@property (nonatomic, readonly) NSNumber *tracksCount;
@property (nonatomic, readonly) NSArray *trackNames;

#pragma mark -
#pragma mark Track Methods
// Creating tracks methods
- (void) addExistingTrack:(SESequencerTrack *)track;

// Removing tracks methods
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier;
- (void) removeAllTracks;

// Info tracks methods
- (NSArray *)trackIdentifiers;

// Registering inputs and outputs methods
- (void) registerInput:(SESequencerInput *)input
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
