
#import "SEMusicTimebase.h"

@implementation SEMusicTimebase

+ (NSInteger)ticksPerDuration:(SENoteDividerValue)noteDivider withPPQN:(NSInteger)ppqn
{
    return (ppqn*4/noteDivider);
}

@end
