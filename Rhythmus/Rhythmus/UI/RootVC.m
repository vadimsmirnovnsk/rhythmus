
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
        _audioController = [[SEAudioController alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rootTabBarController = [[UITabBarController alloc]init];
    [self.rootTabBarController.tabBar setBackgroundImage:
     [UIImage imageNamed:@"tapBarBackground"]];
    [self addChildViewController:self.rootTabBarController];
    [self.view addSubview:self.rootTabBarController.view];
    
    self.libraryVC = [[SELibraryVC alloc]init];
    self.libraryNC = [[UINavigationController alloc]initWithRootViewController:self.libraryVC];
    [self.libraryNC.navigationBar setBackgroundColor:[UIColor rhythmusNavBarColor]];
    [self.libraryNC.tabBarItem setImage:[UIImage imageNamed:@"fileCabinet"]];
    self.libraryNC.tabBarItem.imageInsets = (UIEdgeInsets) {
        5, 0, -5, 0
    };
    
    self.padsVC = [[SEPadsVC alloc]init];
    [self.padsVC.tabBarItem setImage:[UIImage imageNamed:@"padViewTabIcon"]];
    self.padsVC.tabBarItem.imageInsets = (UIEdgeInsets) {
        5, 0, -5, 0
    };
    self.padsVC.sequencer = self.sequencer;
    self.padsVC.currentPattern = self.currentPattern;
    
    
    self.redactorVC = [[SERedactorVC alloc]init];
    [self.redactorVC.tabBarItem setImage:[UIImage imageNamed:@"pencil"]];
    self.redactorVC.tabBarItem.imageInsets = (UIEdgeInsets) {
        5, 0, -5, 0
    };
    self.redactorVC.sequencer = self.sequencer;
    self.redactorVC.currentPattern = self.currentPattern;
    
    
    [self.rootTabBarController setViewControllers:@[self.libraryNC, self.padsVC,
                                                self.redactorVC]];
    [self.rootTabBarController setSelectedIndex:1];
}


@end
