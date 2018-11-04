//
//  UIWindow+UIWindow_Hero.m
//  hero-ios
//
//  Created by Liu Guoping on 2018/11/4.
//

#import "UIWindow+Hero.h"
#import <objc/runtime.h>

@implementation UIWindow (Hero)
+(void)load {
    Method original = class_getInstanceMethod([self class], @selector(motionEnded:withEvent:));
    Method dhcPrefixed = class_getInstanceMethod([self class],@selector(hero_motionEnded:withEvent:));
    method_exchangeImplementations(original, dhcPrefixed);
}
- (void)hero_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"HeroShakeNotification" object:nil]];
    }
    if ([UIWindow instancesRespondToSelector:@selector(hero_motionEnded:withEvent:)]) {
        [self hero_motionEnded:motion withEvent:event];
    }
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

@end
