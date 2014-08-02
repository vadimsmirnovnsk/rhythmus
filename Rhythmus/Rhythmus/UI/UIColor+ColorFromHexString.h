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
+ (UIColor *) rhythmusBackgroundColor;
+ (UIColor *) rhythmusTapBarColor;
+ (UIColor *) rhythmusNavBarColor;

@end
