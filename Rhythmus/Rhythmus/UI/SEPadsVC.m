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

@property (nonatomic, strong) SESequencer *sequencer;
@property (nonatomic, strong) SESequencerInput *input0;
@property (nonatomic, strong) SESequencerOutput *output0;
@property (nonatomic, strong) SESamplePlayer *samplePlayer;

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
            forTrackWithIdentifier:self.output0.identifier];
        // Create the Sample Player and connect it to output 0
        NSString *samplePath = [[NSBundle mainBundle]pathForResource:@"snare" ofType:@"aif"];
        NSURL *sampleURL = [NSURL fileURLWithPath:samplePath];
        self.samplePlayer = [SEAudioController playerWithSample:sampleURL];
        [self.output0 linkWith:self.samplePlayer];
    }
    return self;
}

- (IBAction)pad0:(id)sender
{
    [self.input0 generateMessage];
}

- (IBAction)record:(id)sender
{
    if ([self.sequencer isRecording]) {
        [self.sequencer stopRecording];
    }
    else {
        [self.sequencer startRecording];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
