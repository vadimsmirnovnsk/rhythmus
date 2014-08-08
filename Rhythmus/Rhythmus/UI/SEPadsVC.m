//
//  SEPadsVC.m
//  Rhythmus
//
//  Created by Wadim on 8/2/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SEPadsVC.h"
#import "SESequencer.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "PadsWorkspaceVC.h"
#import "PlaybackVC.h"

@interface SEPadsVC ()

// CR:  You'd better make up a more generic solution to deal with the inputs & outputs.
@property (nonatomic, strong) SESequencer *sequencer;
@property (nonatomic, strong) SESequencerInput *input0;
@property (nonatomic, strong) SESequencerOutput *output0;
@property (nonatomic, strong) SESamplePlayer *samplePlayer;
@property (nonatomic, strong) SESequencerInput *input1;
@property (nonatomic, strong) SESequencerOutput *output1;
@property (nonatomic, strong) SESamplePlayer *samplePlayer1;

@property (nonatomic, weak) IBOutlet UILabel *tempoLabel;

@end

@implementation SEPadsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        // Custom initialization
//        // Creating the Sequencer with Input and Output Model
        _sequencer = [[SESequencer alloc]init];
    
        PadsWorkspaceVC *newWorkspaceVC = [[PadsWorkspaceVC alloc]init];
        newWorkspaceVC.view.frame = (CGRect){
            0,
            205,
            320,
            360
        };
        [self addChildViewController:newWorkspaceVC];
        [self.view addSubview:newWorkspaceVC.view];
        [newWorkspaceVC tuneForSequencer:_sequencer];
        
        PlaybackVC *newPlaybackVC = [[PlaybackVC alloc]init];
        newPlaybackVC.view.frame = (CGRect){
            5,
            125,
            310,
            125
        };
        [self addChildViewController:newPlaybackVC];
        [self.view addSubview:newPlaybackVC.view];
        [newPlaybackVC setSequencer:_sequencer];
        NSString *samplePath = [[NSBundle mainBundle]pathForResource:@"drumstick" ofType:@"wav"];
        NSURL *sampleURL = [NSURL fileURLWithPath:samplePath];
        _samplePlayer = [SEAudioController playerWithContentsOfURL:sampleURL];
        [_sequencer.metronomeOutput setDelegate:_samplePlayer];
    }
    return self;
}

- (IBAction)pad0:(id)sender
{
    [self.input0 generateMessage];
}

- (IBAction)pad1:(id)sender
{
    [self.input1 generateMessage];
}

- (IBAction)tempoMinus:(id)sender
{
    self.sequencer.tempo = self.sequencer.tempo - 10;
    self.tempoLabel.text = [NSString stringWithFormat:@"Tempo: %i bpm", self.sequencer.tempo];
}

- (IBAction)tempoPlus:(id)sender
{
    self.sequencer.tempo = self.sequencer.tempo + 10;
    self.tempoLabel.text = [NSString stringWithFormat:@"Tempo: %i bpm", self.sequencer.tempo];
}

- (IBAction)record:(id)sender
{
    if ([self.sequencer isRecording]) {
        [self.sequencer stopRecording];
    }
    else {
        [self.sequencer startRecordingWithPrepare];
    }
}

- (IBAction)play:(id)sender
{
    if ([self.sequencer isPlaying]) {
        [self.sequencer stop];
    }
    else {
        [self.sequencer playAllStreams];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tempoLabel.text = [NSString stringWithFormat:@"Tempo: %i bpm",self.sequencer.tempo];
    self.view.backgroundColor = [UIColor rhythmusBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
