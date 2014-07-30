//
//  SESequencerInput.m
//  Rhythmus_new
//
//  Created by Wadim on 7/29/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import "SESequencerInput.h"
#import "SESequencerTrack.h"
#import "SESequencer.h"

@interface SESequencerInput ()

@property (nonatomic, weak) SESequencerTrack *track;
@property (nonatomic, weak) SESequencer *delegate;

@end


@implementation SESequencerInput

#pragma mark -
#pragma mark Initializers

- (instancetype) init
{
    return [self initWithIdentifier:nil];
}

// Designated initializer
- (instancetype) initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
    _identifier = identifier;
    }
    return self;
}

#pragma mark Generate Messages Methods
- (void) generateMessage
{
    [self.delegate receiveMessage:[SESequencerMessage defaultMessage] forTrack:self.track];
}

- (void)generateMessageWithParameters:(NSDictionary *)parameters
{
    
}




@end
