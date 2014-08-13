
#import "EditorViewController.h"
#import "SelectDurationViewController.h"
#import "SelectDurationViewControllerDelegate.h"
#import "SoundDurationView.h"
#import "UIColor+iOS7Colors.h"
#import "SERhythmusPattern.h"

static const NSInteger editorViewTopAsset = 4;
static const NSInteger editorViewBulbHeight = 75;
static const NSInteger editorViewBulbTopAsset = 4;
static const NSInteger editorViewBulbWidthAsset = 2;
static const NSInteger singleDurationWidth = 200;

static const CGFloat bulbDisactiveAlpha = 0.3;
static const CGFloat bulbActiveAlpha = 0.9;

@interface EditorViewController () <SelectDurationViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray* streams;
@property (strong, nonatomic) IBOutlet UIScrollView *editField;

@end

@implementation EditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *message = nil;
    SEL s = NULL;
    self.view.backgroundColor = [UIColor rhythmusBackgroundColor];
    self.streams = [[NSMutableArray alloc]init];
    for(int i = 0; i < 4; i++){
        NSMutableArray* newStream = [[NSMutableArray alloc]init];
        for(int j=0; j<10; j++){
            SoundDurationView* button =
            [[SoundDurationView alloc]initWithFrame:(CGRect){
                j * (singleDurationWidth + editorViewBulbWidthAsset),
                i * (editorViewBulbHeight + editorViewBulbTopAsset) + editorViewTopAsset,
                singleDurationWidth,
                editorViewBulbHeight
            }];
            button.singleDurationWidth = singleDurationWidth;
            button.duration = 1;
            button.layer.cornerRadius = 8;
            button.layer.borderWidth = 1;
            
            message = [self.delegate.currentPattern.padSettings[i] colorName];
            s = NSSelectorFromString(message);
            
            button.backgroundColor = objc_msgSend([UIColor class], s);
            [button addTarget:self
                       action:@selector(selectDuration:)
             forControlEvents:UIControlEventTouchUpInside];
            button.alpha = 0.3;
            
            button.layer.borderColor = (__bridge CGColorRef)(button.backgroundColor);
            
            [self.editField addSubview:button];
            [newStream addObject:button];
        }
        [self.streams addObject:newStream];
    }
    
    _editField.contentSize = (CGSize){10*singleDurationWidth,300};
}

-(void)selectDuration:(SoundDurationView*)sender
{
    SelectDurationViewController *const rootViewController = [[SelectDurationViewController alloc]init];
    rootViewController.currentDuration = sender;
    rootViewController.delegate = self;
    
    UINavigationController *const navigationController =
    [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

-(void)selectDurationViewController:(SelectDurationViewController *)sender
      finishedWithSoundDurationView:(SoundDurationView *)soundDurationView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    for(NSMutableArray* stream in self.streams){
        if([stream containsObject:soundDurationView]){
            __block NSInteger index = [stream indexOfObject:soundDurationView];
            NSInteger widthChange = soundDurationView.frame.size.width -
                            soundDurationView.duration * soundDurationView.singleDurationWidth;
            [UIView animateWithDuration:0.5 animations:^{
                soundDurationView.frame = (CGRect){soundDurationView.frame.origin,
                                            soundDurationView.frame.size.width-widthChange,
                                            soundDurationView.frame.size.height};
                for(index++;index<[stream count];index++){
                    SoundDurationView* durationView = stream[index];
                    durationView.frame = (CGRect){durationView.frame.origin.x-widthChange,
                                                    durationView.frame.origin.y,
                                                    durationView.frame.size};
                }
            }];
            break;
        }
    }
    
}

@end
