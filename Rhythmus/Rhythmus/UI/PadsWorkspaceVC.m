
#import "PadsWorkspaceVC.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "SEReceiverDelegate.h"
#import "SESequencerMessage.h"

const CGFloat pwActivePadAlpha =  0.75;
const CGFloat pwNormalPadAlpha =  1.0;
const CGFloat pwDisabledPadAlpha =  0.3;


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

@property (nonatomic,strong) UIView *preparingView;

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
    [UIView animateWithDuration:0.05 delay:0.0
        options:UIViewAnimationOptionAutoreverse animations:^{
            [blockSelf setAlpha:pwActivePadAlpha];
            [blockSelf setFrame:finishLayout];
        } completion:^(BOOL finished) {
            [blockSelf setAlpha:pwNormalPadAlpha];
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
        newPad.alpha = pwNormalPadAlpha;
        [newPad addTarget:self action:@selector(didTapped:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:newPad];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(longPressTap:)];
        longPress.minimumPressDuration = (CFTimeInterval)1.0;
        [newPad addGestureRecognizer:longPress];
        
        [_inputs setObject:newInput forKey:identifier];
        [_outputs setObject:newOutput forKey:identifier];
        [_players setObject:newPlayer forKey:identifier];
        [_pads setObject:newPad forKey:identifier];
        [_sequencer.padsFeedbackOutput setDelegate:self];
        
        _preparingView = [[UIView alloc]init];
        _preparingView.backgroundColor = [UIColor iOS7BlackColor];
        _preparingView.frame = (CGRect){
            5,
            -4,
            310,
            0
        };
        _preparingView.alpha = (CGFloat)0.7;
        [self.view addSubview:_preparingView];
    }
}

- (void) tuneForSequencer:(SESequencer *)sequencer
    withContentsOfPattern:(SERhythmusPattern *)currentPattern
{
    _sequencer = sequencer;
    _currentPattern = currentPattern;
    NSString *identifier = nil;
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
        
        SESamplePlayer *newPlayer = [SEAudioController
            playerWithContentsOfURL:[currentPattern.padSettings[i] sampleURL]];
        [newOutput setDelegate: newPlayer];
        
        // Prapare message for UIColor class
        message = [currentPattern.padSettings[i] colorName];
        s = NSSelectorFromString(message);
        SEPad *newPad = [[SEPad alloc]initWithFrame:
            [[PadsWorkspaceVC sharedPadsLayouts][i]CGRectValue]];
        // Send message to UIColor
        newPad.backgroundColor = objc_msgSend([UIColor class], s);
        newPad.identifier = identifier;
        newPad.alpha = pwNormalPadAlpha;
        [newPad addTarget:self action:@selector(didTapped:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:newPad];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(longPressTap:)];
        longPress.minimumPressDuration = (CFTimeInterval)1.0;
        [newPad addGestureRecognizer:longPress];
        
        [_inputs setObject:newInput forKey:identifier];
        [_outputs setObject:newOutput forKey:identifier];
        [_players setObject:newPlayer forKey:identifier];
        [_pads setObject:newPad forKey:identifier];
        [_sequencer.padsFeedbackOutput setDelegate:self];
        
        _preparingView = [[UIView alloc]init];
        _preparingView.backgroundColor = [UIColor iOS7BlackColor];
        _preparingView.frame = (CGRect){
            5,
            -4,
            310,
            0
        };
        _preparingView.alpha = (CGFloat)0.7;
        [self.view addSubview:_preparingView];
    }
}

- (void)longPressTap:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long gesture recognized for view: %@", recognizer.view);
        UIView *padOptionsView = [[UIView alloc]init];
        padOptionsView.backgroundColor = [UIColor mineShaftColor];
        padOptionsView.alpha = 0;
        padOptionsView.frame = recognizer.view.frame;
        CGRect finishLayout = self.view.bounds;
        finishLayout.origin.x = finishLayout.origin.x + 5;
        finishLayout.origin.y = finishLayout.origin.y;
        finishLayout.size.height = finishLayout.size.height;
        finishLayout.size.width = finishLayout.size.width - 10;
        [self.view addSubview:padOptionsView];
    
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.4
            initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionFlipFromTop
            animations:^{
                [padOptionsView setAlpha:0.9];
                [padOptionsView setFrame:finishLayout];
            } completion:^(BOOL finished) {
                [padOptionsView setAlpha:0.9];
                [padOptionsView setFrame:finishLayout];
        }];
        // Animation without spring
//        [UIView animateWithDuration:0.3 delay:0.0
//            options:UIViewAnimationOptionAllowAnimatedContent animations:^{
//                [padOptionsView setAlpha:0.9];
//                [padOptionsView setFrame:finishLayout];
//            } completion:^(BOOL finished) {
//                [padOptionsView setAlpha:0.9];
//                [padOptionsView setFrame:finishLayout];
//            }];
    }
}

- (void)didTapped:(SEPad *)sender
{
    [self.inputs[sender.identifier]generateMessage];
    [sender animatePad];
}

- (void)showPrepareSubview
{
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.4
            initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionFlipFromTop
            animations:^{
                self.preparingView.frame = (CGRect){
                    5,
                    -2,
                    310,
                    310
                };
            } completion:^(BOOL finished) {
                self.preparingView.frame = (CGRect){
                    5,
                    -2,
                    310,
                    314
                };
        }];
}

- (void)hidePrepareSubview
{
    [UIView animateWithDuration:0.3 delay:0.1
        options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.preparingView.alpha = 0.0;
            self.preparingView.frame = (CGRect){
                160,
                160,
                0,
                0
            };
        } completion:^(BOOL finished) {
            _preparingView.frame = (CGRect){
                5,
                -4,
                310,
                0
            };
            _preparingView.alpha = (CGFloat)0.7;
    }];
     
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark SEReceiverDelegate Protocol Methods
- (void)output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message
{
    if (message.type == messageTypeWorkspaceFeedback) {
        if (message.parameters[kSequencerDidFifnishRecordingWithLastBar]) {
            [self.currentPattern setBars:
                [message.parameters[kSequencerDidFifnishRecordingWithLastBar]intValue]];
            NSLog(@"Bars = %i", self.currentPattern.bars);
            NSLog(@"Message bars = %i",[message.parameters[kSequencerDidFifnishRecordingWithLastBar]intValue]);
        }
        else {
            [self.pads[message.parameters[kSequencerPadsFeedbackParameter]] animatePad];
        }
    }
    else if (message.type == messageTypeSystemPrepare) {
        if (message.parameters[kSequencerPrepareWillStartParameter]) {
            [self showPrepareSubview];
        }
        else if (message.parameters[kSequencerRecordWillStartParameter] ||
                 message.parameters[kSequencerPrepareWillAbortParameter]) {
            [self hidePrepareSubview];
            NSLog(@"Go!");
        }
        else if (message.parameters[kSequencerPrepareDidClickWithTeil]) {
            NSLog(@"Prepare did click: %i",
                [message.parameters[kSequencerPrepareDidClickWithTeil]intValue]);
        }
    }
}

@end
