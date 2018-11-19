//
//  HeroQRCoder.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeroQRCoder : NSObject

+ (UIImage *)qrImageWithString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
