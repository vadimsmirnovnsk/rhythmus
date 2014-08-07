
#import "PadsWorkspaceVC.h"
#import "SEAudioController.h"
#import "UIColor+iOS7Colors.h"

#pragma mark - SEPad Interface


@interface SEPad : UIButton

@end


#pragma mark - SEPad Extension

@interface SEPad ()

@property (nonatomic, strong) id<NSCopying> identifier;

@end


#pragma mark - PadsWorkspaceVC Extension

@interface PadsWorkspaceVC ()

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

@end


#pragma mark - PadsWorkspaceVC Implementation

@implementation PadsWorkspaceVC

+ (NSArray *)sharedPadsLayouts
{
    static NSArray *layouts = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        layouts = @[[NSValue valueWithCGRect:(CGRect){5, 205, 152, 152}],
                    [NSValue valueWithCGRect:(CGRect){163, 205, 152, 152}],
                    [NSValue valueWithCGRect:(CGRect){5, 363, 152, 152}],
                    [NSValue valueWithCGRect:(CGRect){163, 363, 152, 152}]];
    });
    return layouts;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    // TODO: don't create a Sequencer
    _sequencer = [[SESequencer alloc]init];
    if (self) {
        _inputs = [[NSMutableDictionary alloc]initWithCapacity:4];
        _outputs = [[NSMutableDictionary alloc]initWithCapacity:4];
        NSString *samplePath = nil;
        NSURL *sampleURL = nil;
        // Create 4 tracks, 4 Inputs and 4 Outputs
        for (int i = 0; i<4; i++) {
            SESequencerInput *newInput = [[SESequencerInput alloc]initWithIdentifier:
                [NSString stringWithFormat:@"%i",i]];
            [_sequencer registerInput:newInput forTrackIdentifier:newInput.identifier];
            
            SESequencerOutput *newOutput = [[SESequencerOutput alloc]
                initWithIdentifier:newInput.identifier];
            [self.sequencer registerOutput:newOutput
                forTrackIdentifier:newOutput.identifier];
            
            samplePath = [[NSBundle mainBundle]pathForResource:@"hihat" ofType:@"aif"];
            sampleURL = [NSURL fileURLWithPath:samplePath];
            SESamplePlayer *newPlayer = [SEAudioController playerWithContentsOfURL:sampleURL];
            [newOutput setDelegate: newPlayer];
            
            
            SEPad *newPad = [[SEPad alloc]initWithFrame:
                [[PadsWorkspaceVC sharedPadsLayouts][i]CGRectValue]];
            newPad.backgroundColor = [UIColor indigoColor];
            
            [self.view addSubview:newPad];
            
            [_inputs setObject:newInput forKey:newInput.identifier];
            [_outputs setObject:newOutput forKey:newOutput.identifier];
            [_players setObject:newPlayer forKey:newOutput.identifier];
            [_pads setObject:newPad forKey:newOutput.identifier];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark SEReceiverDelegate Protocol Methods
- (void)output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message
{
}

@end
