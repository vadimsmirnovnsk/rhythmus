
#import "MetronomeVC.h"
#import "UIColor+iOS7Colors.h"

#define METRONOME_FPS 25.0;
#define METRONOME_MAX_TEMPO 280;
#define METRONOME_MIN_TEMPO 40;

static const float piNumber = 3.14;

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

@interface Metronome : NSObject <SEReceiverDelegate>

@property (nonatomic, readwrite) NSInteger tempo;
@property (nonatomic, readwrite) BOOL isMetronomeActivate;
@property (nonatomic, weak) SESequencer* sequencer;
@property (nonatomic, weak) id<MetronomeDelegate> delegate;

- (void)start;
- (void)stop;
- (void)synchronize:(NSInteger)part;
- (void)tapTempoButtonDidTapped:(id)sender;

@end


#pragma mark - Metronome Extension

@interface Metronome ()

@property (nonatomic, readwrite) CGFloat cyclicFrequency;
@property (nonatomic) CGFloat timeline;
@property (nonatomic, readwrite) CGFloat deflection;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSTimer *metronomeTimer;
@property (nonatomic, strong) NSTimer *tapTempoTimer;
@property (nonatomic, readwrite) NSInteger times;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, readwrite) NSInteger currentTempo;

- (void)changeDeflection;

@end


#pragma mark - MetronomeVC Extension

@interface MetronomeVC () <MetronomeDelegate>

@property (strong, nonatomic) NSMutableArray *diodes;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UILabel *tempoLabel;
@property (nonatomic, strong) Metronome *metronome;

@end


#pragma mark - Metronome Implementation

@implementation Metronome

- (instancetype)init
{
    if(self = [super init]){
        _deflection = 1;
        _cyclicFrequency = 1;
        _timeline = 0;
    }
    return self;
}

- (void)setDelegate:(id<MetronomeDelegate>)delegate
{
    _delegate = delegate;
    self.cyclicFrequency = 1;
}

- (void)setTempo:(NSInteger)tempo
{
    _tempo = tempo;
    self.cyclicFrequency = (float)tempo/60*piNumber;
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
}

- (void)synchronize:(NSInteger)part
{
    if(part%2){
        self.deflection = 1;
        self.timeline = 0;
    } else {
        self.deflection = -1;
        self.timeline = piNumber/self.cyclicFrequency;
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
    self.deflection = cos(self.cyclicFrequency*self.timeline);
    self.timeline += 1/mFPS;
    [self.delegate metronome:self didChangeDeflection: self.deflection];
}

- (void)tapTempoButtonDidTapped:(id)sender {
    if (self.times>0) {
        if ([self.tapTempoTimer isValid]) {
            [self.tapTempoTimer invalidate];
            self.tapTempoTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(resetTapTempo) userInfo:self repeats:NO];
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

-(void)tapTempoButtonDidSlided:(UIPanGestureRecognizer*)recognizer
{
    if(ABS([recognizer translationInView:recognizer.view].x) > 10){
        CGPoint translation = [recognizer translationInView:recognizer.view];
        self.tempo = MIN(mMaxTempo,MAX(mMinTempo, self.tempo+(NSInteger)(translation.x/10)));
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
        [self.delegate metronome:self didSetNewTempo:self.tempo];
    }
}

- (void) resetTapTempo {
    self.times = 0;
}



- (void) output:(SESequencerOutput *)sender didGenerateMessage:(SESequencerMessage *)message
{
    NSLog(@"I'm corn captain");
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
    
    [self.metronome start];
    
    self.view.backgroundColor = [UIColor rhythmusMetronomeBackgroundColor];
    self.backgroundButton = [[UIButton alloc]initWithFrame:backgroundButtonFrame];
    self.backgroundButton.backgroundColor = [UIColor clearColor];
    [self.backgroundButton addTarget:self
        action:@selector(backgroundButtonDidTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundButtonDidSlided:)];
    [self.backgroundButton addGestureRecognizer:recognizer];
    
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

-(void)backgroundButtonDidSlided:(UIPanGestureRecognizer*)recognizer
{
    [self.metronome tapTempoButtonDidSlided:recognizer];
}

- (void)highlight:(NSInteger)index
{
    for(int i=0; i<14; i++){
        ((UIView*)[self.diodes objectAtIndex:i]).backgroundColor =
            [UIColor colorWithWhite:MAX(pow(1.8, -ABS(i-index)), 0.15) alpha:1];
    }
}

- (void)setSequencer:(SESequencer *)sequencer
{
    _sequencer = sequencer;
    self.metronome.tempo = sequencer.tempo;
}

-(void)metronome:(Metronome*)metronome didChangeDeflection:(CGFloat)deflection
{
    // CR:  What are the magic number below?
    CGFloat index = 6.5*deflection+6.5;
    NSInteger roundIndex = index;
    if(index > roundIndex+0.5){
        roundIndex += 1;
    }
    [self highlight:roundIndex];
}

-(void)metronome:(Metronome*)metronome didSetNewTempo:(NSInteger)currentTempo
{
    self.tempoLabel.text = [NSString stringWithFormat:@"<< TEMPO: %i BPM >>",currentTempo];
    self.sequencer.tempo = currentTempo;
}

@end
