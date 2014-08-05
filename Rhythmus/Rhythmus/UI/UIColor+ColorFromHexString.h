//
//  UIColor+ColorFromHexString.h
//  homework-5
//
//  Created by Wadim on 7/31/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorFromHexString)

+ (UIColor *) colorWithHexString:(NSString *)string;

// CR:  The methods below has to be defined in a separate category.
//
//      It's OK to use such names though I'd recommend you 1) using
//      http://chir.ag/projects/name-that-color/ to name the colors
//      and 2) only then creating aliases for them. Thus your code
//      may look like:
//
//          .h
//              ...
//          + (instancetype)crimsonColor;
//          + (isntancetype)rhythmusBackgroundColor;
//              ...
//
//          .m
//              ...
//          + (isntancetype)rhythmusBackgroundColor
//          {
//              return [self crimsonColor];
//          }
//
//
+ (UIColor *) rhythmusBackgroundColor;
+ (UIColor *) rhythmusTapBarColor;
+ (UIColor *) rhythmusNavBarColor;

@end
