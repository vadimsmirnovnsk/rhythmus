
#import "RootVC.h"
#import "SEAudioController.h"
#import "SELibraryVC.h"
#import "SEPadsVC.h"
#import "SERedactorVC.h"
#import "UIColor+iOS7Colors.h"


#pragma mark - RootVC Extension

@interface RootVC ()

@property (nonatomic, strong) SEAudioController *audioController;
@property (nonatomic, strong) SESamplePlayer *player;
@property (nonatomic, strong) UITabBarController *rootTabBarController;
@property (nonatomic, strong) UINavigationController *libraryNC;
@property (nonatomic, strong) SELibraryVC *libraryVC;
@property (nonatomic, strong) SEPadsVC *padsVC;
@property (nonatomic, strong) SERedactorVC *redactorVC;

@property (nonatomic, strong) SERhythmusPattern *currentPattern;
@property (nonatomic, strong) SESequencer *sequencer;

@end


#pragma mark - RootVC Implementation

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    // Create common pattern and sequencer
        _currentPattern = [SERhythmusPattern defaultPattern];
        _sequencer = [[SESequencer alloc]init];
        _sequencer.tempo = _currentPattern.tempo;
        _sequencer.timeSignature = _currentPattern.timeSignature;
        
    // Create view controllers
        _rootTabBarController = [[UITabBarController alloc]init];
        [_rootTabBarController.tabBar setBackgroundImage:
            [UIImage imageNamed:@"tapBarBackground"]];
        [self addChildViewController:_rootTabBarController];
        [self.view addSubview:_rootTabBarController.view];
        
        _libraryVC = [[SELibraryVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        _libraryNC = [[UINavigationController alloc]initWithRootViewController:self.libraryVC];
        [_libraryNC.navigationBar setBackgroundColor:[UIColor rhythmusNavBarColor]];
        [_libraryNC.tabBarItem setImage:[UIImage imageNamed:@"fileCabinet"]];
        _libraryNC.tabBarItem.imageInsets = (UIEdgeInsets) {
            5, 0, -5, 0
        };
        
        _padsVC = [[SEPadsVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        [_padsVC.tabBarItem setImage:[UIImage imageNamed:@"padViewTabIcon"]];
        _padsVC.tabBarItem.imageInsets = (UIEdgeInsets) {
        5, 0, -5, 0
        };
        _padsVC.sequencer = _sequencer;
        _padsVC.currentPattern = _currentPattern;

        
        _redactorVC = [[SERedactorVC alloc]
            initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        [_redactorVC.tabBarItem setImage:[UIImage imageNamed:@"pencil"]];
        _redactorVC.tabBarItem.imageInsets = (UIEdgeInsets) {
            5, 0, -5, 0
        };
        _redactorVC.sequencer = _sequencer;
        _redactorVC.currentPattern = _currentPattern;
        
        
        [_rootTabBarController setViewControllers:@[_libraryNC, _padsVC,
            _redactorVC]];
        [_rootTabBarController setSelectedIndex:1];
        
        _audioController = [[SEAudioController alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
