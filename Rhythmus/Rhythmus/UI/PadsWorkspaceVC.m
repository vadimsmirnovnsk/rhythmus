
#import "PadsWorkspaceVC.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "SEReceiverDelegate.h"
#import "SESequencerMessage.h"

#pragma mark - SEPad Interface


@interface SEPad : UIButton

@end


#pragma mark - SEPad Extension

@interface SEPad ()

@property (nonatomic, strong) id<NSCopying> identifier;

@end


#pragma mark - PadsWorkspaceVC Extension

@interface PadsWorkspaceVC () <SEReceiverDelegate>

@property (nonatomic, strong) NSMutableDictionary *inputs;
@property (nonatomic, strong) NSMutableDictionary *outputs;
@property (nonatomic, strong) NSMutableDictionary *players;
@property (nonatomic, strong) NSMutableDictionary *pads;

@end


#pragma mark - SEPad Implementation

@implementation SEPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) animatePad
{
    CGRect startLayout = self.frame;
    CGRect finishLayout = self.frame;
    finishLayout.origin.x = finishLayout.origin.x + 2.5;
    finishLayout.origin.y = finishLayout.origin.y + 2.5;
    finishLayout.size.height = finishLayout.size.height - 5;
    finishLayout.size.width = finishLayout.size.width - 5;
    
    __weak typeof(self) blockSelf = self;
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionAutoreverse animations:^{
        [blockSelf setAlpha:0.9];
        [blockSelf setFrame:finishLayout];
    } completion:^(BOOL finished) {
        [blockSelf setAlpha:1.0];
        [blockSelf setFrame:startLayout];
    }];
}

@end


#pragma mark - PadsWorkspaceVC Implementation

@implementation PadsWorkspaceVC

+ (NSArray *)sharedPadsLayouts
{
    static NSArray *layouts = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        layouts = @[[NSValue valueWithCGRect:(CGRect){5, 0, 152, 152}],
                    [NSValue valueWithCGRect:(CGRect){163, 0, 152, 152}],
                    [NSValue valueWithCGRect:(CGRect){5, 158, 152, 152}],
                    [NSValue valueWithCGRect:(CGRect){163, 158, 152, 152}]];
    });
    return layouts;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _inputs = [[NSMutableDictionary alloc]initWithCapacity:4];
        _outputs = [[NSMutableDictionary alloc]initWithCapacity:4];
        _pads = [[NSMutableDictionary alloc]initWithCapacity:4];
        _players = [[NSMutableDictionary alloc]initWithCapacity:4];
    }
    return self;
}

- (void)tuneForSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    NSString *samplePath = nil;
    NSString *identifier = nil;
    NSURL *sampleURL = nil;
    NSString *message = nil;
    SEL s = NULL;
    // Create 4 tracks, 4 Inputs and 4 Outputs
    for (int i = 0; i<4; i++) {
        identifier = [NSString stringWithFormat:@"%i",i];
        SESequencerInput *newInput = [[SESequencerInput alloc]initWithIdentifier:
            identifier];
        [_sequencer registerInput:newInput forTrackIdentifier:identifier];
        
        SESequencerOutput *newOutput = [[SESequencerOutput alloc]
            initWithIdentifier:identifier];
        [self.sequencer registerOutput:newOutput
            forTrackIdentifier:identifier];
        
        samplePath = [[NSBundle mainBundle]pathForResource:@"hihat" ofType:@"aif"];
        sampleURL = [NSURL fileURLWithPath:samplePath];
        SESamplePlayer *newPlayer = [SEAudioController playerWithContentsOfURL:sampleURL];
        [newOutput setDelegate: newPlayer];
        
        // Prapare message for UIColor class
        message = [UIColor sharedColorNames][arc4random() % [[UIColor sharedColorNames] count]];
        s = NSSelectorFromString(message);
        SEPad *newPad = [[SEPad alloc]initWithFrame:
            [[PadsWorkspaceVC sharedPadsLayouts][i]CGRectValue]];
        // Send message to UIColor
        newPad.backgroundColor = objc_msgSend([UIColor class], s);
        newPad.identifier = identifier;
        [newPad addTarget:self action:@selector(didTapped:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:newPad];
        
        [_inputs setObject:newInput forKey:identifier];
        [_outputs setObject:newOutput forKey:identifier];
        [_players setObject:newPlayer forKey:identifier];
        [_pads setObject:newPad forKey:identifier];
        [_sequencer.padsFeedbackOutput setDelegate:self];
    }

}

- (void)didTapped:(SEPad *)sender
{
    [self.inputs[sender.identifier]generateMessage];
    [sender animatePad];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark SEReceiverDelegate Protocol Methods
- (void)output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message
{
    if (message.type == messageTypeInputFeedback) {
        [self.pads[message.parameters[kSequencerPadsFeedbackParameter]] animatePad];
    }
}

@end
