
#import "SEPadsVC.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "PadsWorkspaceVC.h"
#import "PlaybackVC.h"
#import "StatusBarVC.h"
#import "MetronomeVC.h"

static CGRect const padsWorkspaceLayout = (CGRect){0, 205, 320, 360};
static CGRect const padsPlaybackLayout = (CGRect){5, 134, 310, 115};
static CGRect const padsStatusBarLayout = (CGRect){0, 21, 320, 90};
static CGRect const padsMetronomeLayout = (CGRect){5, 65, 310, 114};


#pragma mark - SEPadsVC Extension

@interface SEPadsVC () <PadsWorkspaceProtocol>

@property (nonatomic, strong) PadsWorkspaceVC *workspaceVC;
@property (nonatomic, strong) PlaybackVC *playbackVC;
@property (nonatomic, strong) StatusBarVC *statusBarVC;
@property (nonatomic, strong) MetronomeVC *metronomeVC;
@property (nonatomic, strong) SESamplePlayer *metronomePlayer;

@end


#pragma mark - SEPadsVC Implementation

@implementation SEPadsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create the Metronome player
        NSString *samplePath = [[NSBundle mainBundle]pathForResource:@"drumstick" ofType:@"wav"];
        NSURL *sampleURL = [NSURL fileURLWithPath:samplePath];
        _metronomePlayer = [SEAudioController playerWithContentsOfURL:sampleURL];

        _workspaceVC = [[PadsWorkspaceVC alloc]init];
        _playbackVC = [[PlaybackVC alloc]init];
        _statusBarVC = [[StatusBarVC alloc]init];
        _metronomeVC = [[MetronomeVC alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor rhythmusBackgroundColor];
    //
    //          [self addChildViewController:childVC];
    //          [childVC didMoveToParentViewController:self];
    //          [self.view addSubview:childVC.view];
    //
    
    self.workspaceVC.delegate = self;
    self.workspaceVC.view.frame = padsWorkspaceLayout;
    [self addChildViewController:self.workspaceVC];
    [self.workspaceVC didMoveToParentViewController:self];
    
    self.playbackVC.view.frame = padsPlaybackLayout;
    [self addChildViewController:self.playbackVC];
    [self.playbackVC didMoveToParentViewController:self];
    
    self.statusBarVC.view.frame = padsStatusBarLayout;
    [self addChildViewController:self.statusBarVC];
    [self.statusBarVC didMoveToParentViewController:self];
    
    self.metronomeVC.view.frame = padsMetronomeLayout;
    [self addChildViewController:self.metronomeVC];
    [self.metronomeVC didMoveToParentViewController:self];
    
    [self.view addSubview:self.workspaceVC.view];
    [self.view addSubview:self.playbackVC.view];
    [self.view addSubview:self.statusBarVC.view];
    [self.view addSubview:self.metronomeVC.view];
}

- (void)setSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    [self.playbackVC setSequencer:sequencer];
    [self.statusBarVC setSequencer:sequencer];
    [self.metronomeVC setSequencer:sequencer];
    sequencer.metronomeSyncOutput.delegate = self.metronomeVC;
    [sequencer.metronomeOutput setDelegate:self.metronomePlayer];
}

- (void) setCurrentPattern:(SERhythmusPattern *)currentPattern
{
    _currentPattern = currentPattern;
    self.sequencer.tempo = currentPattern.tempo;
    self.sequencer.timeSignature = currentPattern.timeSignature;
    [self.workspaceVC tuneForSequencer:self.sequencer withContentsOfPattern:currentPattern];
    [self.statusBarVC setCurrentPattern:currentPattern];
    
}

#pragma mark PadsWorkspaceProtocol Implementation
- (void) workspaceDidFinishPatternRecording:(PadsWorkspaceVC *)sender {
    [self.delegate padsDidFinishPatternRecording:self];
}


@end
