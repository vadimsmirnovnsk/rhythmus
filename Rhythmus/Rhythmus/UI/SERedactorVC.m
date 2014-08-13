
#import "SERedactorVC.h"
#import "SESequencer.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "PlaybackVC.h"
#import "StatusBarVC.h"
#import "MetronomeVC.h"
#import "EditorViewController.h"

static CGRect const padsPlaybackLayout = (CGRect){5, 134, 310, 115};
static CGRect const padsStatusBarLayout = (CGRect){0, 21, 320, 90};
static CGRect const padsMetronomeLayout = (CGRect){5, 65, 310, 114};
static CGRect const redactorEditorLayout = (CGRect){5, 200, 310, 400};

@interface SERedactorVC ()

@property (nonatomic, strong) PlaybackVC *playbackVC;
@property (nonatomic, strong) StatusBarVC *statusBarVC;
@property (nonatomic, strong) MetronomeVC *metronomeVC;
@property (nonatomic, strong) EditorViewController *editorVC;

@end

@implementation SERedactorVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.editorVC = [[EditorViewController alloc]init];
        self.editorVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor rhythmusBackgroundColor];
    
    self.playbackVC = [[PlaybackVC alloc]init];
    self.playbackVC.view.frame = padsPlaybackLayout;
    [self addChildViewController:self.playbackVC];
    [self.playbackVC didMoveToParentViewController:self];
    
    self.statusBarVC = [[StatusBarVC alloc]init];
    self.statusBarVC.view.frame = padsStatusBarLayout;
    [self addChildViewController:self.statusBarVC];
    [self.statusBarVC didMoveToParentViewController:self];
    
    self.metronomeVC = [[MetronomeVC alloc]init];
    self.metronomeVC.view.frame = padsMetronomeLayout;
    [self addChildViewController:self.metronomeVC];
    [self.metronomeVC didMoveToParentViewController:self];
    
    self.editorVC.view.frame = redactorEditorLayout;
    [self addChildViewController:self.editorVC];
    [self.editorVC didMoveToParentViewController:self];

    [self.view addSubview:_playbackVC.view];
    [self.view addSubview:_statusBarVC.view];
    [self.view addSubview:_metronomeVC.view];
    [self.view addSubview:_editorVC.view];
    

}

- (void)setCurrentPattern:(SERhythmusPattern *)currentPattern
{
    _currentPattern = currentPattern;
    self.sequencer.tempo = currentPattern.tempo;
    self.sequencer.timeSignature = currentPattern.timeSignature;
    self.statusBarVC.currentPattern = currentPattern;
    self.editorVC.currentPattern = currentPattern;
}

- (void)setSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    [self.playbackVC setSequencer:sequencer];
    [self.statusBarVC setSequencer:sequencer];
    [self.metronomeVC setSequencer:sequencer];
}

- (void)redrawEditor
{
    [self.editorVC redraw];
}



@end
