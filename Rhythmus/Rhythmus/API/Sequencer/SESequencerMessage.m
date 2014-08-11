
#import "SESequencerMessage.h"

@implementation SESequencerMessage

#pragma mark -
#pragma mark Initializers

+ (instancetype)defaultMessage
{
    return ([[SESequencerMessage alloc]init]);
}

+ (instancetype) messageWithType:(MessageType)type parameters:(NSDictionary *)parameters
{
    double empty_time_interval = SEQUENCE_MESSAGE_NULL_TIMESTAMP;
    return [[SESequencerMessage alloc]initWithRawTimestamp:empty_time_interval
        type:type parameters:parameters];
}

- (instancetype) init
{
    double empty_time_interval = SEQUENCE_MESSAGE_NULL_TIMESTAMP;
    return [self initWithRawTimestamp:empty_time_interval type:messageTypeDefault parameters:nil];
}

// Designated initializer
- (instancetype) initWithRawTimestamp:(NSTimeInterval)rawTimestamp
    type:(MessageType)type parameters:(NSDictionary *)parameters
{
    if (self=[super init]) {
        _type = type;
        _data = nil;
        _PPQNTimeStamp = SEQUENCE_MESSAGE_PPQN_NO_INTERVAL;
        _rawTimestamp = rawTimestamp;
        _initialDuration = SEQUENCE_MESSAGE_NULL_DURATION;
        _parameters = parameters;
    }
    return self;
}

#pragma mark NSCopying Protocol Methods

- (id)copyWithZone:(NSZone *)zone
{
    SESequencerMessage *newMessage = [[[self class]allocWithZone:zone]init];
    newMessage.type = self.type;
    newMessage.PPQNTimeStamp = self.PPQNTimeStamp;
    newMessage.initialDuration = self.initialDuration;
    newMessage.rawTimestamp = self.rawTimestamp;
    newMessage.parameters = [self.parameters copy];
    newMessage.data = [NSData dataWithBytes:[self.data bytes] length:[self.data length]];
    return newMessage;
}


@end
