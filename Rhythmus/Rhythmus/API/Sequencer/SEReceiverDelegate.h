//
//  SEReceiverDelegate.h
//  Rhythmus_new
//
//  Created by Wadim on 7/30/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SEReceiverDelegate <NSObject>

- (BOOL) receiveMessage:(SESequencerMessage *)message;

@end
