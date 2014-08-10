
#import <Foundation/Foundation.h>
#import "SEMusicTimebase.h"


#pragma mark SEPadSetting Inteface

@interface SEPadSetting : NSObject

@property (nonatomic, copy) NSString *colorName;
@property (nonatomic, copy) NSURL *sampleURL;
@property (nonatomic, strong) NSArray *track;

@end


#pragma mark SERhythmusPattern Interface

@interface SERhythmusPattern : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readwrite) NSInteger tempo;
@property (nonatomic, readwrite) SETimeSignature timeSignature;
@property (nonatomic, readwrite) NSInteger bars;
@property (nonatomic, strong) NSArray /*of SEPadSetting's*/ *padSettings;

@property (nonatomic, copy, readonly) NSString *patternDescription;

+ (SERhythmusPattern *)defaultPattern;

@end
