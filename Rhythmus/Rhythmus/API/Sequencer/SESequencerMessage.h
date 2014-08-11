
#import <Foundation/Foundation.h>

// Workspace Feedback Parameters
static NSString *const kSequencerPadsFeedbackParameter = @"Identifier";
static NSString *const kSequencerDidFifnishRecordingWithLastBar = @"Bar";

// SystemPrepare Paramaters
static NSString *const kSequencerPrepareWillStartParameter = @"Prepare will start";
static NSString *const kSequencerPrepareWillAbortParameter = @"Prepare will abort";
static NSString *const kSequencerPrepareDidClickWithTeil = @"Prepare did click with teil";
static NSString *const kSequencerRecordWillStartParameter = @"Record will start";


@interface SESequencerMessage : NSObject <NSCopying>

#define SEQUENCE_MESSAGE_PPQN_NO_INTERVAL -1;
#define SEQUENCE_MESSAGE_NULL_TIMESTAMP -1;
#define SEQUENCE_MESSAGE_NULL_DURATION -1;

typedef enum {
    messageTypeDefault = 0,
    messageTypeTrigger = 0,
    messageTypePause = 1,
    messageTypeSample = 2,
    messageTypeWorkspaceFeedback = 3,
    messageTypeSystemPrepare = 4,
    messageTypeMetronomeClick = 5
} MessageType;

@property (nonatomic, readwrite) MessageType type;
@property (nonatomic, copy) NSData /*with raw MIDI message data*/ *data;
@property (nonatomic, readwrite) unsigned long PPQNTimeStamp;
@property (nonatomic, readwrite) NSInteger initialDuration; // Non-music-quantized duration - in PPQN.
@property (nonatomic, readwrite) NSTimeInterval rawTimestamp;
@property (nonatomic, copy) NSDictionary *parameters;

#pragma mark Class Methods
+ (instancetype) defaultMessage;
+ (instancetype) messageWithType:(MessageType)type parameters:(NSDictionary *)parameters;

#pragma mark - Initializers
- (instancetype) initWithRawTimestamp:(NSTimeInterval)rawTimestamp
    type:(MessageType)type parameters:(NSDictionary *)parameters;


@end
