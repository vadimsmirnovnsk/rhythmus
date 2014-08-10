
#import "SERhythmusPattern.h"
#import "UIColor+iOS7Colors.h"


#pragma mark - SEPadSetting Implementation
@implementation SEPadSetting
@end


#pragma mark - SERhythmusPattern Implementation

@implementation SERhythmusPattern

+ (SERhythmusPattern *) defaultPattern
{
    NSString *samplePath = nil;
    NSURL *sampleURL = nil;
    
    SERhythmusPattern *defaultPattern = [[SERhythmusPattern alloc]init];
    defaultPattern.name = @"F#cking Awesome Pattern";
    defaultPattern.bpm = 100;
    defaultPattern.timeSignature = (SETimeSignature) {4, noteDividerQuarter};
    
    // Customization of first pad
    SEPadSetting *firstPadSetting = [[SEPadSetting alloc]init];
    firstPadSetting.colorName = [UIColor sharedColorNames][1];
    samplePath = [[NSBundle mainBundle]pathForResource:@"hihat" ofType:@"aif"];
    sampleURL = [NSURL fileURLWithPath:samplePath];
    firstPadSetting.sampleURL = sampleURL;
    firstPadSetting.track = @[];
    
    // Customization of second pad
    SEPadSetting *secondPadSetting = [[SEPadSetting alloc]init];
    secondPadSetting.colorName = [UIColor sharedColorNames][3];
    samplePath = [[NSBundle mainBundle]pathForResource:@"clap" ofType:@"aif"];
    sampleURL = [NSURL fileURLWithPath:samplePath];
    secondPadSetting.sampleURL = sampleURL;
    secondPadSetting.track = @[];
    
    // Customization of third pad
    SEPadSetting *thirdPadSetting = [[SEPadSetting alloc]init];
    thirdPadSetting.colorName = [UIColor sharedColorNames][5];
    samplePath = [[NSBundle mainBundle]pathForResource:@"snare" ofType:@"aif"];
    sampleURL = [NSURL fileURLWithPath:samplePath];
    thirdPadSetting.sampleURL = sampleURL;
    thirdPadSetting.track = @[];
    
    // Customization of fourth pad
    SEPadSetting *fourthPadSetting = [[SEPadSetting alloc]init];
    fourthPadSetting.colorName = [UIColor sharedColorNames][7];
    samplePath = [[NSBundle mainBundle]pathForResource:@"bassdrum" ofType:@"aif"];
    sampleURL = [NSURL fileURLWithPath:samplePath];
    fourthPadSetting.sampleURL = sampleURL;
    fourthPadSetting.track = @[];
    
    defaultPattern.padSettings = @[firstPadSetting, secondPadSetting,
        thirdPadSetting, fourthPadSetting];
    
    return defaultPattern;
}

@end
