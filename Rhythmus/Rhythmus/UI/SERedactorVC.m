
#import "SERedactorVC.h"
#import "SESequencer.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "PlaybackVC.h"
#import "StatusBarVC.h"
#import "MetronomeVC.h"

static CGRect const padsPlaybackLayout = (CGRect){5, 134, 310, 115};
static CGRect const padsStatusBarLayout = (CGRect){0, 21, 320, 90};
static CGRect const padsMetronomeLayout = (CGRect){5, 65, 310, 114};

@interface SERedactorVC ()

@property (nonatomic, strong) PlaybackVC *playbackVC;
@property (nonatomic, strong) StatusBarVC *statusBarVC;
@property (nonatomic, strong) MetronomeVC *metronomeVC;

@end

@implementation SERedactorVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        // CR:  A very rude mistake! Never ever access a view controller's view
        //      form within an intializer; it's not time yet! Your view controller
        //      may appear on the screen much later while it has already consumed
        //      an extra memory.
        //
        //      Move this stuff into the -viewDidLoad.
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
    
    [self.view addSubview:_playbackVC.view];
    [self.view addSubview:_statusBarVC.view];
    [self.view addSubview:_metronomeVC.view];

}

- (void)setCurrentPattern:(SERhythmusPattern *)currentPattern
{
    _currentPattern = currentPattern;
    self.sequencer.tempo = currentPattern.tempo;
    self.sequencer.timeSignature = currentPattern.timeSignature;
    self.statusBarVC.currentPattern = currentPattern;
}

- (void)setSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    [self.playbackVC setSequencer:sequencer];
    [self.statusBarVC setSequencer:sequencer];
    [self.metronomeVC setSequencer:sequencer];
}



@end
