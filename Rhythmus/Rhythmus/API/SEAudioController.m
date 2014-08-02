//
//  SEAudioController.m
//  Rhythmus
//
//  Created by Wadim on 7/31/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SEAudioController.h"
#import "SESequencerMessage.h"
@import AVFoundation;


#pragma mark - SamplePlayer Extension

@interface SESamplePlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

// Designated initializer
- (id) initWithSample: (NSURL *)sampleUrl;

@end


#pragma mark - AudioController Extension

@interface SEAudioController ()

@property (strong, nonatomic) AVAudioSession *audioSession;

- (void) configureAudioSession;

@end


#pragma mark - SamplePlayer Implementation

@implementation SESamplePlayer

#pragma Initializers
- (id)init
{
    return nil;
}

- (id) initWithSample: (NSURL *)sampleUrl
{
    if (sampleUrl == nil) {
        NSLog(@"Error creating sample player: nil URL");
        return nil;
    }
    if (self = [super init]) {
        // Configuring audio player.
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:sampleUrl error:nil];
        self.player.delegate = self;
        self.player.numberOfLoops = 0;
        [self.player prepareToPlay];
    }
    return self;
}

#pragma Public Methods

- (void)play
{
    if ([self.player isPlaying]) {
        [self.player stop];
    }
    [self.player play];
}

#pragma SEReceiverDelegate Protocol Methods

- (void) receiveMessage:(SESequencerMessage *)message
{
    if ([self.player isPlaying]) {
        [self.player stop];
    }
    [self.player play];
}

#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player
{
	// Music stopped by rhe system.
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags
{
    // Music can be resumed after interruption.
}

@end


#pragma mark - AudioController Implementation

@implementation SEAudioController

#pragma mark Initializers

// Designated initializer
- (instancetype) init
{
    if (self = [super init]) {
        [self configureAudioSession];
    }
    return self;
}

#pragma mark Class Methods

+ (SESamplePlayer *)playerWithSample:(NSURL *)sampleUrl
{
    return [[SESamplePlayer alloc]initWithSample:sampleUrl];
}

#pragma mark Custom Methods

- (void) configureAudioSession
{
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *__autoreleasing audioSessionError = nil;
    BOOL success = [self.audioSession setCategory:
        AVAudioSessionCategoryPlayback error:&audioSessionError];
    if (!success) {
        NSLog(@"Error success for audio session.\n");
    }
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
    
    NSTimeInterval bufferDuration =.005;
    [self.audioSession setPreferredIOBufferDuration:bufferDuration error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
 
    double sampleRate = 44100.0;
    [self.audioSession setPreferredSampleRate:sampleRate error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
 
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification
        object:self.audioSession];
 
    // ToDo: Activate only with PlayButton
    NSLog(@"Activate with start application.");
    [self.audioSession setActive:YES error:&audioSessionError];
        if (audioSessionError) {
            NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
 
    sampleRate = self.audioSession.sampleRate;
    bufferDuration = self.audioSession.IOBufferDuration;
    NSLog(@"Sampe Rate:%0.0fHZ I/O Buffer Duration:%f", sampleRate, bufferDuration);
}

@end
