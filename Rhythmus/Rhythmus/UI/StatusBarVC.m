
#import "StatusBarVC.h"
#import "UIColor+iOS7Colors.h"

static void *const statusBarContext = (void *)&statusBarContext;

#pragma mark - StatusBarVC Extension

@interface StatusBarVC ()

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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor rhythmusTapBarColor];
    self.patternNameLabel.textColor = [UIColor mineShaftColor];
    self.patternNameLabel.text = @"Pattern";
    self.patternDescriptionLabel.textColor = [UIColor darkGrayColor];
    self.sequencerTimestampLabel.textColor = [UIColor darkGrayColor];
}

- (void)setSequencer:(SESequencer *)sequencer
{
    [_sequencer removeObserver:self
        forKeyPath:NSStringFromSelector(@selector(timeStampStringValue))];
    _sequencer = sequencer;
    [_sequencer addObserver:self
        forKeyPath:NSStringFromSelector(@selector(timeStampStringValue))
        options:0
        context:statusBarContext];
}

- (void)setCurrentPattern:(SERhythmusPattern *)currentPattern
{
    [self.currentPattern removeObserver:self
        forKeyPath:NSStringFromSelector(@selector(name))];
    _currentPattern = currentPattern;
    self.patternNameLabel.text = self.currentPattern.name;
    self.patternDescriptionLabel.text = self.currentPattern.patternDescription;
    [self.currentPattern addObserver:self
        forKeyPath:NSStringFromSelector(@selector(patternDescription))
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
