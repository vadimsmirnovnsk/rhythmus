
#import "PadsWorkspaceVC.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"
#import "SEReceiverDelegate.h"
#import "SESequencerMessage.h"
#import "PadOptionsVC.h"

const CGFloat pwActivePadAlpha =  0.75;
const CGFloat pwNormalPadAlpha =  1.0;
const CGFloat pwDisabledPadAlpha =  0.3;

const CGRect pwShieldViewRect = (CGRect){0, - 150, 310, 400};



#pragma mark - SEPad Extension

@interface SEPad ()

@property (nonatomic, strong) id<NSCopying> identifier;

@end


#pragma mark - PadsWorkspaceVC Extension

@interface PadsWorkspaceVC () <SEReceiverDelegate, PadOptionsVCDelegate>

@property (nonatomic, strong) NSMutableDictionary *inputs;
@property (nonatomic, strong) NSMutableDictionary *outputs;
@property (nonatomic, strong) NSMutableDictionary *players;
@property (nonatomic, strong) NSMutableDictionary *pads;

@property (nonatomic,strong) UIView *preparingView;
@property (nonatomic, strong) PadOptionsVC *padOptionsVC;

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
    self.sequencer = sequencer;
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
        [self.sequencer registerInput:newInput forTrackIdentifier:identifier];
        
        SESequencerOutput *newOutput = [[SESequencerOutput alloc]
            initWithIdentifier:identifier];
        [self.sequencer registerOutput:newOutput
            forTrackIdentifier:identifier];
        
        samplePath = [[NSBundle mainBundle]pathForResource:@"hihat" ofType:@"aif"];
        sampleURL = [NSURL fileURLWithPath:samplePath];
        SESamplePlayer *newPlayer = [SEAudioController playerWithContentsOfURL:sampleURL];
        [newOutput setDelegate: newPlayer];
        message = [UIColor sharedColorNames][arc4random() % [[UIColor sharedColorNames] count]];
        s = NSSelectorFromString(message);
        SEPad *newPad = [[SEPad alloc]initWithFrame:
            [[PadsWorkspaceVC sharedPadsLayouts][i]CGRectValue]];
            
        // Send message to UIColor
        newPad.backgroundColor = objc_msgSend([UIColor class], s);
        newPad.identifier = identifier;
        newPad.alpha = pwNormalPadAlpha;
        [newPad addTarget:self action:@selector(userDidTapPad:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:newPad];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(longPressTap:)];
        longPress.minimumPressDuration = (CFTimeInterval)1.0;
        [newPad addGestureRecognizer:longPress];
        
        [self.inputs setObject:newInput forKey:identifier];
        [self.outputs setObject:newOutput forKey:identifier];
        [self.players setObject:newPlayer forKey:identifier];
        [self.pads setObject:newPad forKey:identifier];
        [self.sequencer.padsFeedbackOutput setDelegate:self];
        
        self.preparingView = [[UIView alloc]init];
        self.preparingView.backgroundColor = [UIColor iOS7BlackColor];
        self.preparingView.frame = (CGRect){
            5,
            -4,
            310,
            0
        };
        self.preparingView.alpha = (CGFloat)0.7;
        [self.view addSubview:self.preparingView];
    }
}

- (void) tuneForSequencer:(SESequencer *)sequencer
    withContentsOfPattern:(SERhythmusPattern *)currentPattern
{
    self.sequencer = sequencer;
    self.currentPattern = currentPattern;
    NSString *identifier = nil;
    NSString *message = nil;
    SEL s = NULL;
    // Create 4 tracks, 4 Inputs and 4 Outputs
    for (int i = 0; i<4; i++) {
        identifier = [NSString stringWithFormat:@"%i",i];
        SESequencerInput *newInput = [[SESequencerInput alloc]initWithIdentifier:
            identifier];
        [self.sequencer registerInput:newInput forTrackIdentifier:identifier];
        
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
        [newPad addTarget:self action:@selector(userDidTapPad:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:newPad];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(longPressTap:)];
        longPress.minimumPressDuration = (CFTimeInterval)1.0;
        [newPad addGestureRecognizer:longPress];
        
        [self.inputs setObject:newInput forKey:identifier];
        [self.outputs setObject:newOutput forKey:identifier];
        [self.players setObject:newPlayer forKey:identifier];
        [self.pads setObject:newPad forKey:identifier];
        [self.sequencer.padsFeedbackOutput setDelegate:self];
        
        self.preparingView = [[UIView alloc]init];
        self.preparingView.backgroundColor = [UIColor iOS7BlackColor];
        self.preparingView.frame = (CGRect){
            5,
            -4,
            310,
            0
        };
        self.preparingView.alpha = (CGFloat)0.7;
        [self.view addSubview:self.preparingView];
    }
}

- (void)longPressTap:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Create Options View
        self.padOptionsVC = [[PadOptionsVC alloc]init];
        self.padOptionsVC.view.backgroundColor = [UIColor mineShaftColor];
        self.padOptionsVC.view.alpha = 0;
        self.padOptionsVC.view.frame = recognizer.view.frame;
        self.padOptionsVC.delegate = self;
        self.padOptionsVC.pad = (SEPad *)recognizer.view;
        
        CGRect finishLayout = self.view.bounds;
        finishLayout.origin.x = finishLayout.origin.x + 5;
        finishLayout.origin.y = finishLayout.origin.y;
        finishLayout.size.height = finishLayout.size.height;
        finishLayout.size.width = finishLayout.size.width - 10;
        [self addChildViewController:self.padOptionsVC];
        [self.view addSubview:self.padOptionsVC.view];
    
        __typeof (self) __weak blockSelf = self;
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.4
            initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionFlipFromTop
            animations:^{
                [blockSelf.padOptionsVC.view setAlpha:0.9];
                [blockSelf.padOptionsVC.view setFrame:finishLayout];
            } completion:^(BOOL finished) {
                [blockSelf.padOptionsVC.view setAlpha:0.9];
                [blockSelf.padOptionsVC.view setFrame:finishLayout];
        }];
    }
}

- (void) cancelOptionsView
{
    [UIView animateWithDuration:0.3 delay:0.1
        options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.padOptionsVC.view.alpha = 0.0;
            self.padOptionsVC.view.frame = (CGRect){
                5,
                568,
                310,
                310
            };
        } completion:^(BOOL finished) {
            [self.padOptionsVC.view removeFromSuperview];
            [self.padOptionsVC removeFromParentViewController];
    }];
}

- (void)userDidTapPad:(SEPad *)sender
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
            self.preparingView.frame = (CGRect){
                5,
                -4,
                310,
                0
            };
            self.preparingView.alpha = (CGFloat)0.7;
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
            [self.delegate workspaceDidFinishPatternRecording:self];
        }
        else {
            NSInteger padIndex = [message.parameters[kSequencerPadsFeedbackParameter]integerValue];
            SEPad *animatingPad = 
                self.pads[message.parameters[kSequencerPadsFeedbackParameter]];
            CGRect animatingPadInitialFrame = [[PadsWorkspaceVC sharedPadsLayouts][padIndex]CGRectValue];

            if (animatingPad.frame.size.width == animatingPadInitialFrame.size.width) {
                [self.pads[message.parameters[kSequencerPadsFeedbackParameter]] animatePad];
            }
            
        }
    }
    else if (message.type == messageTypeSystemPrepare) {
        if (message.parameters[kSequencerPrepareWillStartParameter]) {
            [self showPrepareSubview];
        }
        else if (message.parameters[kSequencerRecordWillStartParameter] ||
                 message.parameters[kSequencerPrepareWillAbortParameter]) {
            [self hidePrepareSubview];
        }
        else if (message.parameters[kSequencerPrepareDidClickWithTeil]) {
        }
    }
}

#pragma mark PadOptionsVCDelegate Methods
- (void)optionsControllerDidCanceled:(PadOptionsVC *)sender
{
    [self cancelOptionsView];
    
}

@end
