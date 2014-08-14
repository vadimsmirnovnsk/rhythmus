//
//  SEPatternSaver.h
//  Rhythmus
//
//  Created by Admin on 13/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SERhythmusPattern;

@protocol SEPatternSaver <NSObject>

-(void)savePattern:(SERhythmusPattern*)pattern;

@end
