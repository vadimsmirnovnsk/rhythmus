
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

@interface SEPadsVC ()

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
        
        _workspaceVC = [[PadsWorkspaceVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        _workspaceVC.view.frame = padsWorkspaceLayout;
        [self addChildViewController:_workspaceVC];
        [_workspaceVC didMoveToParentViewController:self];
        
        _playbackVC = [[PlaybackVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        _playbackVC.view.frame = padsPlaybackLayout;
        [self addChildViewController:_playbackVC];
        [_playbackVC didMoveToParentViewController:self];
            
        _statusBarVC = [[StatusBarVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        _statusBarVC.view.frame = padsStatusBarLayout;
        [self addChildViewController:_statusBarVC];
        [_statusBarVC didMoveToParentViewController:self];
        
        
        _metronomeVC = [[MetronomeVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        _metronomeVC.view.frame = padsMetronomeLayout;
        [self addChildViewController:_metronomeVC];
        [_metronomeVC didMoveToParentViewController:self];
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
    [self.view addSubview:_workspaceVC.view];
    [self.view addSubview:_playbackVC.view];
    [self.view addSubview:_statusBarVC.view];
    [self.view addSubview:_metronomeVC.view];
}

- (void)setSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    [self.playbackVC setSequencer:sequencer];
    [self.statusBarVC setSequencer:sequencer];
    [self.metronomeVC setSequencer:sequencer];
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


@end
