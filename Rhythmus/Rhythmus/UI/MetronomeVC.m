
#import "MetronomeVC.h"
#import "UIColor+iOS7Colors.h"
#import "SESequencerMessage.h"

#define METRONOME_FPS 25.0;
#define METRONOME_MAX_TEMPO 280;
#define METRONOME_MIN_TEMPO 40;

static const float mFPS = METRONOME_FPS;
static const NSInteger mMaxTempo = METRONOME_MAX_TEMPO;
static const NSInteger mMinTempo = METRONOME_MIN_TEMPO;

static const NSInteger diodesCount = 14;
static const NSInteger diodeMaxHeight = 50;
static const NSInteger diodeWidth = (310 - 68)/14;

static CGRect const backgroundButtonFrame = (CGRect){0, 0, 310, 65};
static CGRect const tempoLabelFrame = (CGRect){0, 20, 310, 51};


#pragma mark - MetronomeDelegate Protocol

@class Metronome;
@protocol MetronomeDelegate <NSObject>

-(void)metronome:(Metronome*)metronome didChangeDeflection:(CGFloat)deflection;
-(void)metronome:(Metronome*)metronome didSetNewTempo:(NSInteger)currentTempo;

@end


#pragma mark - Metronome Interface

@interface Metronome : NSObject

@property (nonatomic, readwrite) CGFloat period;
@property (nonatomic, readwrite) NSInteger tempo;
@property (nonatomic, readwrite) BOOL isMetronomeActivate;
// CR:  Why the metronomes know about the sequencers?
@property (nonatomic, weak) SESequencer* sequencer;
@property (nonatomic, weak) id<MetronomeDelegate> delegate;

- (void)start;
- (void)stop;
- (void)synchronize:(NSInteger)part;
- (void)tapTempoButtonDidTapped:(id)sender;

@end


#pragma mark - Metronome Extension

@interface Metronome ()

@property (nonatomic, readwrite) CGFloat deflection;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSTimer *metronomeTimer;
@property (nonatomic, strong) NSTimer *tapTempoTimer;
@property (nonatomic, readwrite) NSInteger times;
// CR:  You'd better use 'copy' instead of 'strong'.
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, readwrite) NSInteger currentTempo;
@property (nonatomic, readwrite) CGFloat elementaryDeflection;

- (void)changeDeflection;

@end


#pragma mark - MetronomeVC Extension

@interface MetronomeVC () <MetronomeDelegate, SEReceiverDelegate>

@property (strong, nonatomic) NSMutableArray *diodes;
@property (nonatomic, weak) UIButton *backgroundButton;
@property (nonatomic, weak) UILabel *tempoLabel;
@property (nonatomic, strong) Metronome *metronome;

@end


#pragma mark - Metronome Implementation

@implementation Metronome

- (instancetype)init
{
    if(self = [super init]){
        self.deflection = 0;
    }
    return self;
}

- (void)setDelegate:(id<MetronomeDelegate>)delegate
{
    _delegate = delegate;
    self.period = 1;
    self.elementaryDeflection = (1/mFPS)/self.period;
}

- (void)setTempo:(NSInteger)tempo
{
    _tempo = tempo;
    self.elementaryDeflection = 0.08*tempo/60;
}

- (void)start
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1/mFPS
        target:self selector:@selector(changeDeflection) userInfo:nil repeats:YES];
     [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    self.deflection = 0;
}

- (void)synchronize:(NSInteger)part
{
    if(part%2){
        self.deflection = 1;
        self.elementaryDeflection  = -ABS(self.elementaryDeflection);
    } else {
        self.deflection = -1;
        self.elementaryDeflection  = ABS(self.elementaryDeflection);
    }
    if([self.timer isValid]){
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1/mFPS
        target:self selector:@selector(changeDeflection) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.delegate metronome:self didChangeDeflection: self.deflection];
}

- (void)changeDeflection
{
    if(self.deflection > 1){
        self.elementaryDeflection *= -1;
        self.deflection = 2-self.deflection;
    } else if(self.deflection < -1){
        self.elementaryDeflection *= -1;
        self.deflection = -2 -self.deflection;
    }
    [self.delegate metronome:self didChangeDeflection: self.deflection];
    self.deflection += self.elementaryDeflection;
}

- (void)tapTempoButtonDidTapped:(id)sender {
    if (self.times>0) {
        if ([self.tapTempoTimer isValid]) {
            [self.tapTempoTimer invalidate];
            self.tapTempoTimer = [NSTimer scheduledTimerWithTimeInterval:2 
                target:self selector:@selector(resetTapTempo) userInfo:self repeats:NO];
        }
        NSTimeInterval currentInterval = [[NSDate date] timeIntervalSinceDate:self.lastDate];
        self.currentTempo = (int)(60*self.times/currentInterval);
        // NSLog(@"%@",[NSString stringWithFormat:@"Tempo is: %i bpm",self.currentTempo]);
        self.times += 1;
    }
    else {
        self.lastDate = [NSDate date];
        self.times += 1;
        self.tapTempoTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(resetTapTempo) userInfo:self repeats:NO];
    }
    if ((self.currentTempo <= mMaxTempo) && (self.currentTempo >= mMinTempo)) {
        self.tempo = self.currentTempo;
    }
    else if (self.currentTempo <= mMaxTempo) {
        self.currentTempo = mMinTempo;
    }
    else {
        self.currentTempo = mMaxTempo;
    }
    if (self.times > 1) {
        [self.delegate metronome:self didSetNewTempo:self.tempo];
    }
}

- (void) resetTapTempo {
    self.times = 0;
}

@end


#pragma mark - MetronomeVC Implementation

@implementation MetronomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _diodes = [[NSMutableArray alloc]init];
        _metronome = [[Metronome alloc]init];
        self.metronome.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self drawDiodes];
    self.view.backgroundColor = [UIColor rhythmusMetronomeBackgroundColor];
    self.backgroundButton = [[UIButton alloc]initWithFrame:backgroundButtonFrame];
    self.backgroundButton.backgroundColor = [UIColor clearColor];
    [self.backgroundButton addTarget:self
        action:@selector(backgroundButtonDidTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundButton];
    
    self.tempoLabel = [[UILabel alloc]init];
    self.tempoLabel.frame = tempoLabelFrame;
    self.tempoLabel.font = [UIFont fontWithName:@"Open 24 Display St" size:25];
    self.tempoLabel.textColor = [UIColor rhythmusLedOnColor];
    self.tempoLabel.textAlignment = NSTextAlignmentCenter;
    self.tempoLabel.text = @"<< TEMPO: 100 BPM >>";
    [self.view addSubview:self.tempoLabel];
}

- (void) drawDiodes
{
    for (int i = 0; i<diodesCount; i++) {
        CGFloat res = MAX(0.3, ABS((float)i/2-3.25)-2.25);
        UIView* diode = [[UIView alloc]initWithFrame:
            (CGRect){8+(diodeWidth+4)*i,8,diodeWidth,diodeMaxHeight*res}];
        diode.backgroundColor = [UIColor rhythmusLedOffColor];
        [self.diodes addObject:diode];
        [self.view addSubview:diode];
    }
}

- (void)backgroundButtonDidTapped:(UIButton *)sender
{
    [self.metronome tapTempoButtonDidTapped:sender];
}

- (void)highlight:(NSInteger)index
{
    for(int i=0; i<diodesCount; i++){
        ((UIView*)[self.diodes objectAtIndex:i]).backgroundColor =
            [UIColor colorWithWhite:MAX(pow(1.8, -ABS(i-index)), 0.15) alpha:1];
    }
}

- (void)switchOffDiodes {
    for(int i=0; i<diodesCount; i++){
        ((UIView *)[self.diodes objectAtIndex:i]).backgroundColor =
        [UIColor rhythmusLedOffColor];
    }
}

- (void)setSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    self.metronome.tempo = sequencer.tempo;
    sequencer.metronomeSyncOutput.delegate = self;
}

#pragma mark MetronomeDelegate Protocol Implemetation
-(void)metronome:(Metronome*)metronome didChangeDeflection:(CGFloat)deflection
{
    // CR:  What are the magic number below?
    [self highlight:((NSInteger)(6.5*deflection)+6.5)];
}

-(void)metronome:(Metronome*)metronome didSetNewTempo:(NSInteger)currentTempo
{
    self.tempoLabel.text = [NSString stringWithFormat:@"<< TEMPO: %i BPM >>",currentTempo];
    self.sequencer.tempo = currentTempo;
}

#pragma mark SEReceiverDelegate Protocol Implementation
- (void) output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message
{
    if (message.type == messageTypeMetronomeSync) {
        if (message.parameters[@"Teil"]) {
            if ([self.metronome isMetronomeActivate]) {
                [self.metronome synchronize:[message.parameters[@"Teil"]intValue]];
            }
        }
        else if (message.parameters[kMetronomeWillStartParameter]) {
            [self.metronome start];
            self.metronome.deflection = 0;
        }
        else if (message.parameters[kMetronomeWillStopParameter]) {
            [self.metronome stop];
            [self switchOffDiodes];
        }
    }
}

@end
