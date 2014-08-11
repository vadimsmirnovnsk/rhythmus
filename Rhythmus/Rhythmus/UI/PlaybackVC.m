
#import "PlaybackVC.h"
#import "UIColor+iOS7Colors.h"

@interface PlaybackVC ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *recButton;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation PlaybackVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) handleRecButton:(UIButton *)sender
{
    if ([self.sequencer isPlaying]) {
        return;
    }
    if ([self.sequencer isRecording] || [self.sequencer isPreparing]) {
        [self.recButton setImage:[UIImage imageNamed:@"recButtonActive"]
            forState:UIControlStateNormal];
        [self.sequencer stopRecording];
    }
    else {
        [self.sequencer startRecordingWithPrepare];
        [self.recButton setImage:[UIImage imageNamed:@"recButtonRecording"]
            forState:UIControlStateNormal];
    }
}

- (void) handlePlayButton:(UIButton *)sender
{
    if ([self.sequencer isPlaying]) {
        [self.playButton setImage:[UIImage imageNamed:@"playButtonActive"]
            forState:UIControlStateNormal];
        [self.recButton setImage:[UIImage imageNamed:@"recButtonActive"]
            forState:UIControlStateNormal];
        [self.sequencer stop];
    }
    else if ([self.sequencer isRecording] || [self.sequencer isPreparing]) {
        [self.recButton setImage:[UIImage imageNamed:@"recButtonActive"]
            forState:UIControlStateNormal];
        [self.sequencer stopRecording];
    }
    else {
            if ([self.sequencer playAllStreams]) {
                [self.playButton setImage:[UIImage imageNamed:@"playButtonPlaying"]
                    forState:UIControlStateNormal];
                [self.recButton setImage:[UIImage imageNamed:@"recButtonDisactive"]
                    forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor rhythmusPlaybackPanelColor];
        // Add line
        UIView *lineView = [[UIView alloc]init];
        lineView.frame = (CGRect){
            154,
            10,
            2,
            55
        };
        lineView.backgroundColor = [UIColor rhythmusDividerColor];
        [self.view addSubview:lineView];
        
        self.recButton = [[UIButton alloc]init];
        self.recButton.frame = (CGRect){
            5,
            10,
            145,
            60
        };
        [self.recButton setImage:[UIImage imageNamed:@"recButtonActive"] forState:UIControlStateNormal];
        [self.recButton setImage:[UIImage imageNamed:@"recButtonDisactive"] forState:UIControlStateDisabled];
        [self.view addSubview:self.recButton];
        [self.recButton addTarget:self action:@selector(handleRecButton:)
            forControlEvents:UIControlEventTouchUpInside];
        
        self.playButton = [[UIButton alloc]init];
        self.playButton.frame = (CGRect){
            160,
            10,
            145,
            60
        };
        [self.playButton setImage:[UIImage imageNamed:@"playButtonActive"]
            forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"playButtonDisactive"]
            forState:UIControlStateDisabled];
        [self.view addSubview:self.playButton];
        [self.playButton addTarget:self action:@selector(handlePlayButton:)
            forControlEvents:UIControlEventTouchUpInside];
}


@end
