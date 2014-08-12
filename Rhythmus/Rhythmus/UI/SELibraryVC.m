
#import "SELibraryVC.h"
#import "UIColor+iOS7Colors.h"

@interface SELibraryVC ()

@end

@implementation SELibraryVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor rhythmusBackgroundColor];
}


@end
