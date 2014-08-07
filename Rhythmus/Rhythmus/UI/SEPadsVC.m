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

@interface SEPadsVC ()

// CR:  You'd better make up a more generic solution to deal with the inputs & outputs.
@property (nonatomic, strong) SESequencer *sequencer;
@property (nonatomic, strong) SESequencerInput *input0;
@property (nonatomic, strong) SESequencerOutput *output0;
@property (nonatomic, strong) SESamplePlayer *samplePlayer;
@property (nonatomic, strong) SESequencerInput *input1;
@property (nonatomic, strong) SESequencerOutput *output1;
@property (nonatomic, strong) SESamplePlayer *samplePlayer1;

// CR:  Why is the outlet strongly pointed?
@property (nonatomic, strong) IBOutlet UILabel *tempoLabel;

@end

@implementation SEPadsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Creating the Sequencer with Input and Output Model
        self.sequencer = [[SESequencer alloc]init];
        self.input0 = [[SESequencerInput alloc]initWithIdentifier:@"0"];
        [self.sequencer registerInput:self.input0 forTrackIdentifier:self.input0.identifier];
        self.output0 = [[SESequencerOutput alloc]initWithIdentifier:self.input0.identifier];
        [self.sequencer registerOutput:self.output0
            forTrackIdentifier:self.output0.identifier];
        
        self.input1 = [[SESequencerInput alloc]initWithIdentifier:@"1"];
        [self.sequencer registerInput:self.input1 forTrackIdentifier:self.input1.identifier];
        self.output1 = [[SESequencerOutput alloc]initWithIdentifier:self.input1.identifier];
        [self.sequencer registerOutput:self.output1
            forTrackIdentifier:self.output1.identifier];
        
        // Create the Sample Player and connect it to output 0
        NSString *samplePath = [[NSBundle mainBundle]pathForResource:@"snare" ofType:@"aif"];
        NSURL *sampleURL = [NSURL fileURLWithPath:samplePath];
        self.samplePlayer = [SEAudioController playerWithContentsOfURL:sampleURL];
        [self.output0 setDelegate: self.samplePlayer];
        
        samplePath = [[NSBundle mainBundle]pathForResource:@"clap" ofType:@"aif"];
        sampleURL = [NSURL fileURLWithPath:samplePath];
        self.samplePlayer1 = [SEAudioController playerWithContentsOfURL:sampleURL];
        self.output1.delegate = self.samplePlayer1;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
