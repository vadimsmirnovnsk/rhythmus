//
//  SEAudioController.h
//  Rhythmus
//
//  Created by Wadim on 7/31/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEReceiverDelegate.h"

@interface SESamplePlayer : NSObject <SEReceiverDelegate>

@property (nonatomic, readwrite) NSInteger playersPoolCapacity;

- (void) play;

@end

@interface SEAudioController : NSObject

+ (SESamplePlayer *)playerWithContentsOfURL:(NSURL *)fileURL;

@end
