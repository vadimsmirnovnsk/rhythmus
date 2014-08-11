
#import "SEAudioController.h"
#import "SESequencerMessage.h"
@import AVFoundation;

/* Set Default max number of players in pool. */
#define DEFAULT_PLAYER_POOL_CAPACITY 10;


#pragma mark - SamplePlayer Extension

@interface SESamplePlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableArray /*of AVAudioPlayers*/ *players;
@property (nonatomic, copy) NSURL *sampleUrl;

// Designated initializer
- (id) initWithSample: (NSURL *)sampleUrl;

@end


#pragma mark - AudioController Extension

@interface SEAudioController ()

@property (nonatomic, strong) AVAudioSession *audioSession;

- (void) configureAudioSession;

@end


#pragma mark - SamplePlayer Implementation

@implementation SESamplePlayer

#pragma Initializers
- (id)init
{
    NSLog(@"Method shouldn't be called. Please use an -initWithSample: method.");
    return nil;
}

- (id) initWithSample: (NSURL *)sampleUrl
{
    if (sampleUrl == nil) {
        NSLog(@"Error creating sample player: nil URL");
        return nil;
    }
    if (self = [super init]) {
        // Configuring first audio player in the players-pool.
        _sampleUrl = [sampleUrl copy];
        _playersPoolCapacity = DEFAULT_PLAYER_POOL_CAPACITY;
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
            sampleUrl error:nil];
        newPlayer.delegate = self;
        newPlayer.numberOfLoops = 0;
        [newPlayer prepareToPlay];
        self.players = [@[newPlayer] mutableCopy];
    }
    return self;
}

#pragma Public Methods

- (void)play
{
    NSArray *playersCopy = [self.players copy];
    for (AVAudioPlayer *player in playersCopy) {
        if (![player isPlaying]) {
            [player play];
            // Create new player if this player is last active in pool
            if ([playersCopy indexOfObject:player]==[playersCopy count]-1) {
                if ([playersCopy count] < self.playersPoolCapacity) {
                    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:self.sampleUrl error:nil];
                    newPlayer.delegate = self;
                    newPlayer.numberOfLoops = 0;
                    [newPlayer prepareToPlay];
                    [self.players addObject:newPlayer];
                }
                else {
                    NSLog(@"Error: trying to overflow players pool with capacity: %i",
                        self.playersPoolCapacity);
                }
            }
            break;
        }
    }
}

#pragma SEReceiverDelegate Protocol Methods

- (void) output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message;
{
    if (message.type == messageTypePause) {
        return;
    }
    [self play];
}

#pragma mark AVAudioPlayerDelegate methods

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

+ (SESamplePlayer *)playerWithContentsOfURL:(NSURL *)fileURL
{
    return [[SESamplePlayer alloc]initWithSample:fileURL];
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
        NSLog(@"Error %ld, %@", (long)audioSessionError.code,
            audioSessionError.localizedDescription);
    }
    
    NSTimeInterval bufferDuration =.005;
    [self.audioSession setPreferredIOBufferDuration:bufferDuration error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code,
            audioSessionError.localizedDescription);
    }
 
    double sampleRate = 22050.0;
    [self.audioSession setPreferredSampleRate:sampleRate error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code,
            audioSessionError.localizedDescription);
    }
 
//    [[NSNotificationCenter defaultCenter] addObserver:self
//        selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification
//        object:self.audioSession];
 
    // ToDo: Activate only with PlayButton
    NSLog(@"Activate with start application.");
    [self.audioSession setActive:YES error:&audioSessionError];
        if (audioSessionError) {
            NSLog(@"Error %ld, %@", (long)audioSessionError.code,
                audioSessionError.localizedDescription);
    }
 
    sampleRate = self.audioSession.sampleRate;
    bufferDuration = self.audioSession.IOBufferDuration;
    NSLog(@"Sampe Rate:%0.0fHZ I/O Buffer Duration:%f", sampleRate, bufferDuration);
}

@end
