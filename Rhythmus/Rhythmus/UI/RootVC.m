
#import "RootVC.h"
#import "SEAudioController.h"
#import "SELibraryVC.h"
#import "SEPadsVC.h"
#import "SERedactorVC.h"


#pragma mark - RootVC Extension

@interface RootVC ()

@property (nonatomic, strong) SEAudioController *audioController;
@property (nonatomic, strong) SESamplePlayer *player;
@property (nonatomic, strong) UITabBarController *rootTabBarController;
@property (nonatomic, strong) UINavigationController *libraryNC;
@property (nonatomic, strong) SELibraryVC *libraryVC;
@property (nonatomic, strong) SEPadsVC *padsVC;
@property (nonatomic, strong) SERedactorVC *redactorVC;

@end


#pragma mark - RootVC Implementation

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _rootTabBarController = [[UITabBarController alloc]init];
        [_rootTabBarController.tabBar setBackgroundImage:
            [UIImage imageNamed:@"tapBarBackground"]];
        [self addChildViewController:_rootTabBarController];
        [self.view addSubview:_rootTabBarController.view];
        
        self.libraryVC = [[SELibraryVC alloc]init];
        self.libraryNC = [[UINavigationController alloc]initWithRootViewController:self.libraryVC];
        [self.libraryNC.tabBarItem setImage:[UIImage imageNamed:@"fileCabinet"]];
        self.libraryNC.tabBarItem.imageInsets = (UIEdgeInsets) {
            5, 0, -5, 0
        };
        
        self.padsVC = [[SEPadsVC alloc]init];
        [self.padsVC.tabBarItem setImage:[UIImage imageNamed:@"padViewTabIcon"]];
        self.padsVC.tabBarItem.imageInsets = (UIEdgeInsets) {
        5, 0, -5, 0
        };
        self.redactorVC = [[SERedactorVC alloc]init];
        [self.redactorVC.tabBarItem setImage:[UIImage imageNamed:@"pencil"]];
        self.redactorVC.tabBarItem.imageInsets = (UIEdgeInsets) {
            5, 0, -5, 0
        };
        
        [self.rootTabBarController setViewControllers:@[self.libraryNC, self.padsVC,
            self.redactorVC]];
        [self.rootTabBarController setSelectedIndex:1];
        
        self.audioController = [[SEAudioController alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
