//
//  SESequencerInput.h
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SESequencerInput : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readwrite, getter = isMuted) BOOL mute;

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier;

// Generate messages methods
- (void) generateMessage;
- (void) generateMessageWithParameters:(NSDictionary *)parameters;

@end
