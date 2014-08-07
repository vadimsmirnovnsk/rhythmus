
#import "UIColor+iOS7Colors.h"

@implementation UIColor (iOS7Colors)


#pragma mark Clear Colors

+ (UIColor *)silverColor
{
    return [UIColor colorWithRed:(CGFloat){184.0/255.0} green:(CGFloat){184.0/255.0}
            blue:(CGFloat){184.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)altoColor
{
    return [UIColor colorWithRed:(CGFloat){220.0/255.0} green:(CGFloat){220.0/255.0}
            blue:(CGFloat){220.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)manateeColor
{
    return [UIColor colorWithRed:(CGFloat){145.0/255.0} green:(CGFloat){145.0/255.0}
            blue:(CGFloat){147.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)radicalRedColor
{
    return [UIColor colorWithRed:(CGFloat){255.0/255.0} green:(CGFloat){45.0/255.0}
            blue:(CGFloat){85.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)redOrangeColor
{
    return [UIColor colorWithRed:(CGFloat){255.0/255.0} green:(CGFloat){59.0/255.0}
            blue:(CGFloat){48.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)pizazzColor
{
    return [UIColor colorWithRed:(CGFloat){255.0/255.0} green:(CGFloat){149.0/255.0}
            blue:(CGFloat){0.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)supernovaColor
{
    return [UIColor colorWithRed:(CGFloat){255.0/255.0} green:(CGFloat){204.0/255.0}
            blue:(CGFloat){0.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)emeraldColor
{
    return [UIColor colorWithRed:(CGFloat){76.0/255.0} green:(CGFloat){217.0/255.0}
            blue:(CGFloat){100.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)malibuColor
{
    return [UIColor colorWithRed:(CGFloat){90.0/255.0} green:(CGFloat){200.0/255.0}
            blue:(CGFloat){250.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)curiousBlueColor
{
    return [UIColor colorWithRed:(CGFloat){52.0/255.0} green:(CGFloat){170.0/255.0}
            blue:(CGFloat){220.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)azureRadianceColor
{
    return [UIColor colorWithRed:(CGFloat){0.0/255.0} green:(CGFloat){122.0/255.0}
            blue:(CGFloat){255.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)indigoColor
{
    return [UIColor colorWithRed:(CGFloat){88.0/255.0} green:(CGFloat){86.0/255.0}
            blue:(CGFloat){214.0/255.0} alpha:(CGFloat){1.0}];
}

+ (UIColor *)mineShaftColor
{
    return [UIColor colorWithRed:(CGFloat){45.0/255.0} green:(CGFloat){45.0/255.0}
            blue:(CGFloat){45.0/255.0} alpha:(CGFloat){1.0}];
}



#pragma mark Aliaces

+ (UIColor *)iOS7BlackColor
{
    return [UIColor mineShaftColor];
}

+ (UIColor *)iOS7PurpleColor
{
    return [UIColor indigoColor];
}

+ (UIColor *)iOS7DarkBlueColor
{
    return [UIColor azureRadianceColor];
}

+ (UIColor *)iOS7MarineBlueColor
{
    return [UIColor curiousBlueColor];
}

+ (UIColor *)iOS7LightBlueColor
{
    return [UIColor malibuColor];
}

+ (UIColor *)iOS7GreenColor
{
    return [UIColor emeraldColor];
}

+ (UIColor *)iOS7YellowColor
{
    return [UIColor supernovaColor];
}

+ (UIColor *)iOS7OrangeColor
{
    return [UIColor pizazzColor];
}

+ (UIColor *)iOS7RedColor
{
    return [UIColor redOrangeColor];
}

+ (UIColor *)iOS7PinkColor
{
    return [UIColor radicalRedColor];
}

+ (UIColor *)iOS7GrayColor
{
    return [UIColor manateeColor];
}

+ (UIColor *)rhythmusNavBarColor
{
    return [UIColor silverColor];
}

+ (UIColor *)rhythmusTapBarColor
{
    return [UIColor silverColor];
}

+ (UIColor *)rhythmusBackgroundColor
{
    return [UIColor altoColor];
}

@end
