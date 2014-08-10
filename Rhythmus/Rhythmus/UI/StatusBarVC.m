
#import "StatusBarVC.h"
#import "UIColor+iOS7Colors.h"


@interface StatusBarVC ()

@property (nonatomic, weak) IBOutlet UILabel *currentPatternLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *barLabel;
@property (nonatomic, weak) IBOutlet UILabel *teilLabel;

@end


@implementation StatusBarVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor rhythmusTapBarColor];
        self.currentPatternLabel.textColor = [UIColor mineShaftColor];
        self.currentPatternLabel.text = @"F#cking Awesome Pattern";
        self.descriptionLabel.textColor = [UIColor darkGrayColor];
        self.barLabel.textColor = [UIColor blueColor];
        self.teilLabel.textColor = [UIColor blueColor];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



@end
