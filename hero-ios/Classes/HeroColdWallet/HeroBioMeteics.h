//
//  HeroBioMeteics.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HeroBioNone,
    HeroBioTouchID,
    HeroBioFaceID,
} HeroBioType;

@interface HeroBioMeteics : NSObject

+ (HeroBioType)type;

+ (void)evaluate:(NSString *)title reply:(void (^)(BOOL success, NSError *error))reply;

@end

NS_ASSUME_NONNULL_END
