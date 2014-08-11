
#import <Foundation/Foundation.h>

typedef enum noteDividerValue {
  noteDividerWhole = 1,
  noteDividerHalf = 2,
  noteDividerQuarter = 4,
  noteDividerQuarterTriplet = 6,
  noteDividerEighth = 8,
  noteDividerEighthTriplet = 12,
  noteDividerSexteenth = 16,
  noteDividerSexteenthTriplet = 24,
  noteDividerThyrtySecond = 32
} SENoteDividerValue;

struct SETimeSignature {
  NSInteger upperPart;
  SENoteDividerValue lowerPart;
};
typedef struct SETimeSignature SETimeSignature;


@interface SEMusicTimebase : NSObject

+ (NSInteger)ticksPerDuration:(SENoteDividerValue)noteDivider withPPQN:(NSInteger)ppqn;

@end
