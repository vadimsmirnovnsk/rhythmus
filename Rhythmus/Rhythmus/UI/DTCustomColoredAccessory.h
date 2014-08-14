//
//  DTCustomColoredAccessory.h
//  Rhythmus
//
//  Created by Admin on 14/08/14.
//  Copyright (c) 2014 Smirnov Electronics. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DTCustomColoredAccessoryTypeRight = 0,
    DTCustomColoredAccessoryTypeUp,
    DTCustomColoredAccessoryTypeDown
} DTCustomColoredAccessoryType;

@interface DTCustomColoredAccessory : UIControl
{
	UIColor *_accessoryColor;
	UIColor *_highlightedColor;
    
    DTCustomColoredAccessoryType _type;
}

@property (nonatomic, retain) UIColor *accessoryColor;
@property (nonatomic, retain) UIColor *highlightedColor;

@property (nonatomic, assign)  DTCustomColoredAccessoryType type;

+ (DTCustomColoredAccessory *)accessoryWithColor:(UIColor *)color type:(DTCustomColoredAccessoryType)type;

@end
