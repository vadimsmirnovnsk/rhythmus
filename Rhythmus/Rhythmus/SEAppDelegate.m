//
//  SEAppDelegate.m
//  Rhythmus
//
//  Created by Wadim on 7/28/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SEAppDelegate.h"
#import "SEAudioController.h"
#import "UIColor+ColorFromHexString.h"
#import "SELibraryVC.h"
#import "SEPadsVC.h"
#import "SERedactorVC.h"

@interface SEAppDelegate ()

// CR: I'd create a dedicated VC to handle all this stuff.
@property (nonatomic, strong) SEAudioController *audioController;
@property (nonatomic, strong) SESamplePlayer *player;
@property (nonatomic, strong) UITabBarController *rootTabBarController;
@property (nonatomic, strong) UINavigationController *libraryNC;
@property (nonatomic, strong) SELibraryVC *libraryVC;
@property (nonatomic, strong) SEPadsVC *padsVC;
@property (nonatomic, strong) SERedactorVC *redactorVC;

@end

@implementation SEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.rootTabBarController = [[UITabBarController alloc]init];
    [self.window setRootViewController:_rootTabBarController];
    
    [self.rootTabBarController.tabBar setBackgroundImage:
        [UIImage imageNamed:@"tapBarBackground"]];
    
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
//    NSString *samplePath = [[NSBundle mainBundle]pathForResource:@"snare" ofType:@"aif"];
//    NSURL *sampleURL = [NSURL fileURLWithPath:samplePath];
//    self.player = [SEAudioController playerWithSample:sampleURL];
//    [self.player play];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
