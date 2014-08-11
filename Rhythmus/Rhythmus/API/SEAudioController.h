
#import <Foundation/Foundation.h>
#import "SEReceiverDelegate.h"


#pragma mark SESamplePlayer Inteface

@interface SESamplePlayer : NSObject <SEReceiverDelegate>

@property (nonatomic, readwrite) NSInteger playersPoolCapacity;

- (void) play;

@end


#pragma mark - SEAudioController Interface

@interface SEAudioController : NSObject

+ (SESamplePlayer *)playerWithContentsOfURL:(NSURL *)fileURL;

@end
