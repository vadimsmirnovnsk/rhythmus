
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
        // Create background view
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
        
        _recButton = [[UIButton alloc]init];
        _recButton.frame = (CGRect){
            5,
            10,
            145,
            60
        };
        [_recButton setImage:[UIImage imageNamed:@"recButtonActive"] forState:UIControlStateNormal];
        [_recButton setImage:[UIImage imageNamed:@"recButtonDisactive"] forState:UIControlStateDisabled];
        [self.view addSubview:_recButton];
        [_recButton addTarget:self action:@selector(handleRecButton:)
            forControlEvents:UIControlEventTouchUpInside];
        
        _playButton = [[UIButton alloc]init];
        _playButton.frame = (CGRect){
            160,
            10,
            145,
            60
        };
        [_playButton setImage:[UIImage imageNamed:@"playButtonActive"]
            forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"playButtonDisactive"]
            forState:UIControlStateDisabled];
        [self.view addSubview:_playButton];
        [_playButton addTarget:self action:@selector(handlePlayButton:)
            forControlEvents:UIControlEventTouchUpInside];
        
//        _recButton.backgroundColor = [UIColor redOrangeColor];
//        _playButton.backgroundColor = [UIColor manateeColor];
    }
    return self;
}

- (void) handleRecButton:(UIButton *)sender
{
    if ([_sequencer isPlaying]) {
        return;
    }
    if ([_sequencer isRecording] || [_sequencer isPreparing]) {
        [_recButton setImage:[UIImage imageNamed:@"recButtonActive"]
            forState:UIControlStateNormal];
        [_sequencer stopRecording];
    }
    else {
        [_sequencer startRecordingWithPrepare];
        [_recButton setImage:[UIImage imageNamed:@"recButtonRecording"]
            forState:UIControlStateNormal];
    }
}

- (void) handlePlayButton:(UIButton *)sender
{
    if ([_sequencer isPlaying]) {
        [_playButton setImage:[UIImage imageNamed:@"playButtonActive"]
            forState:UIControlStateNormal];
        [_recButton setImage:[UIImage imageNamed:@"recButtonActive"]
            forState:UIControlStateNormal];
        [_sequencer stop];
    }
    else if ([_sequencer isRecording] || [_sequencer isPreparing]) {
        [_recButton setImage:[UIImage imageNamed:@"recButtonActive"]
            forState:UIControlStateNormal];
        [_sequencer stopRecording];
    }
    else {
            if ([_sequencer playAllStreams]) {
                [_playButton setImage:[UIImage imageNamed:@"playButtonPlaying"]
                    forState:UIControlStateNormal];
                [_recButton setImage:[UIImage imageNamed:@"recButtonDisactive"]
                    forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
