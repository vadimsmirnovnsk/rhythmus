
#import "SEPadsVC.h"
#import "SESequencer.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "PadsWorkspaceVC.h"
#import "PlaybackVC.h"
#import "StatusBarVC.h"

static CGRect const padsWorkspaceLayout = (CGRect){0, 205, 320, 360};
static CGRect const padsPlaybackLayout = (CGRect){5, 124, 310, 125};
static CGRect const padsStatusBarLayout = (CGRect){0, 21, 320, 90};


#pragma mark - SEPadsVC Extension

@interface SEPadsVC ()

@property (nonatomic, strong) SESequencer *sequencer;
@property (nonatomic, strong) SESamplePlayer *metronomePlayer;

@end


#pragma mark - SEPadsVC Implementation

@implementation SEPadsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentPattern = [SERhythmusPattern defaultPattern];
        _sequencer = [[SESequencer alloc]init];
        _sequencer.tempo = _currentPattern.tempo;
        _sequencer.timeSignature = _currentPattern.timeSignature;
        
        // Create the Metronome player
        NSString *samplePath = [[NSBundle mainBundle]pathForResource:@"drumstick" ofType:@"wav"];
        NSURL *sampleURL = [NSURL fileURLWithPath:samplePath];
        _metronomePlayer = [SEAudioController playerWithContentsOfURL:sampleURL];
        [_sequencer.metronomeOutput setDelegate:_metronomePlayer];
        
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
    PadsWorkspaceVC *newWorkspaceVC = [[PadsWorkspaceVC alloc]init];
    newWorkspaceVC.view.frame = padsWorkspaceLayout;
    [self addChildViewController:newWorkspaceVC];
    [newWorkspaceVC didMoveToParentViewController:self];
    [self.view addSubview:newWorkspaceVC.view];
    [newWorkspaceVC tuneForSequencer:_sequencer withContentsOfPattern:_currentPattern];
    
    PlaybackVC *newPlaybackVC = [[PlaybackVC alloc]init];
    newPlaybackVC.view.frame = padsPlaybackLayout;
    [self addChildViewController:newPlaybackVC];
    [newPlaybackVC didMoveToParentViewController:self];
    [self.view addSubview:newPlaybackVC.view];
    [newPlaybackVC setSequencer:_sequencer];
    
    StatusBarVC *newStatusBarVC = [[StatusBarVC alloc]init];
    newStatusBarVC.view.frame = padsStatusBarLayout;
    [self addChildViewController:newStatusBarVC];
    [newStatusBarVC didMoveToParentViewController:self];
    [self.view addSubview:newStatusBarVC.view];
    newStatusBarVC.sequencer = self.sequencer;
    newStatusBarVC.currentPattern = self.currentPattern;

}


@end
