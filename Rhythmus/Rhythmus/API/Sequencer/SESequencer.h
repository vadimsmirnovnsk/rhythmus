//
//  SESequencer.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEReceiverDelegate.h"
#import "SEMusicTimebase.h"

@class SESequencerInput;
@class SESequencerTrack;


#pragma mark - SEInputDelegate Protocol

@protocol SEInputDelegate <NSObject>

- (BOOL) input:(SESequencerInput *)sender didGenerateMessage:(SESequencerMessage *)message;

@end


#pragma mark - Inputs Interface

@interface SESequencerInput : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readwrite, getter = isMute) BOOL mute;

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier;

// Generate messages methods
- (void) generateMessage;
- (void) generateMessageWithParameters:(NSDictionary *)parameters;

@end


#pragma mark - Outputs Interface

@interface SESequencerOutput : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, strong) id<SEReceiverDelegate> delegate;

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier;

@end


#pragma mark - Sequencer Interface

@interface SESequencer : NSObject

@property (nonatomic, readonly, getter = isRecording) BOOL recording;
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;
@property (nonatomic, readonly, getter = isPreparing) BOOL preparing;
@property (nonatomic, getter = isClick) BOOL click;
@property (nonatomic, readwrite) NSInteger tempo;
@property (nonatomic, readwrite) SETimeSignature timeSignature;
@property (nonatomic, strong) SESequencerOutput *metronomeOutput;
@property (nonatomic, strong) SESequencerOutput *metronomeSyncOutput;
@property (nonatomic, strong) SESequencerOutput *padsFeedbackOutput;
@property (nonatomic, copy, readonly) NSString *timeStampStringValue;


#pragma mark Track Methods
// Creating tracks methods
// CR:  You can't simply add a track; you should ask for an identifier.
//      I also think it's not really good to assign a track from the outside.
//      Could you please explain how a hardware sequencer "implements" such
//      a feature?
- (void) addExistingTrack:(SESequencerTrack *)track;

// Removing tracks methods
// CR:  I don't really think this API has to be public.
- (BOOL) removeTrackWithIdentifier:(NSString *)identifier;
- (void) removeAllTracks;
- (void) loadData:(NSArray * /*of SESequencerMessages*/)trackData
    forTrackIdentifier:(NSString *)identifier;
- (NSArray */*of SESequencerMessages*/) dataForTrackIdentifier:(NSString *)identifier;

// Info tracks methods
// CR: What for you provide such a method?
- (NSArray *)trackIdentifiers;

// Registering inputs and outputs methods
- (void) registerInput:(SESequencerInput *)input
    forTrackIdentifier:(NSString *)identifier;
    
- (void) registerOutput:(SESequencerOutput *)output
    forTrackIdentifier:(NSString *)identifier;

#pragma mark Playback Methods
- (BOOL) startRecording;
- (void) startRecordingWithPrepare;
- (void) stopRecording;
- (BOOL) playAllStreams;
- (void) stop;
- (void) pause;


@end
