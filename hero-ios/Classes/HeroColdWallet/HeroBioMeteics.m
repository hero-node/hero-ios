//
//  HeroBioMeteics.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/19.
//

#import "HeroBioMeteics.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation HeroBioMeteics

static LAContext *_context;

+ (HeroBioType)type {
    _context = [[LAContext alloc] init];
    if (@available(iOS 8.0, *)) {
        NSError *err;
        BOOL isCanEvaluatePolicy = [_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&err];
        if (err) {
            return HeroBioNone;
        } else {
            if (isCanEvaluatePolicy) {
                if (@available(iOS 11.0, *)) {
                    switch (_context.biometryType) {
                        case LABiometryNone:
                            return HeroBioNone;
                        case LABiometryTypeTouchID:
                            return HeroBioTouchID;
                        case LABiometryTypeFaceID:
                            return HeroBioFaceID;
                        default:
                            break;
                    }
                }
            } else {
                return HeroBioNone;
            }
        }
    } else {
        return HeroBioTouchID;
    }
    return HeroBioNone;
}

+ (void)evaluate:(NSString *)title reply:(void (^)(BOOL, NSError * _Nonnull))reply {
    if (_context) {
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:title reply:reply];
    }
}

@end
