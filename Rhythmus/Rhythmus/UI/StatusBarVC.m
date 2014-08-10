
#import "StatusBarVC.h"
#import "UIColor+iOS7Colors.h"

static void *const statusBarContext = (void *)&statusBarContext;

#pragma mark - StatusBarVC Extension

@interface StatusBarVC ()

@property (nonatomic, strong) SESequencer *sequencer;
@property (nonatomic, strong) SERhythmusPattern *currentPattern;

@property (nonatomic, weak) IBOutlet UILabel *patternNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *patternDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *sequencerTimestampLabel;

@end


#pragma mark - StatusBarVC Implementation

@implementation StatusBarVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor rhythmusTapBarColor];
        self.patternNameLabel.textColor = [UIColor mineShaftColor];
        self.patternNameLabel.text = @"Pattern";
        self.patternDescriptionLabel.textColor = [UIColor darkGrayColor];
        self.sequencerTimestampLabel.textColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self.currentPattern removeObserver:self
        forKeyPath:NSStringFromSelector(@selector(name))];
    [self.sequencer removeObserver:self
        forKeyPath:NSStringFromSelector(@selector(timeStampStringValue))];
}

- (void) tuneForSequencer:(SESequencer *)sequencer withPattern:(SERhythmusPattern *)pattern
{
    self.sequencer = sequencer;
    self.currentPattern = pattern;
    self.patternNameLabel.text = self.currentPattern.name;
    self.patternDescriptionLabel.text = self.currentPattern.patternDescription;
    // Create observer for currentPattern.patternDescription
    [self.currentPattern addObserver:self
        forKeyPath:NSStringFromSelector(@selector(patternDescription))
        options:0
        context:statusBarContext];
    // Create observer for sequencer.timeStampStringValue
    [self.sequencer addObserver:self
        forKeyPath:NSStringFromSelector(@selector(timeStampStringValue))
        options:0
        context:statusBarContext];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
    change:(NSDictionary *)change context:(void *)context
{
    if (context == statusBarContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(patternDescription))]) {
            self.patternDescriptionLabel.text = self.currentPattern.patternDescription;
        }
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(timeStampStringValue))]) {
            self.sequencerTimestampLabel.text = self.sequencer.timeStampStringValue;
        }
    }
    else{
        [super observeValueForKeyPath:keyPath
            ofObject:object
            change:change
            context:context];
    }
}



@end
