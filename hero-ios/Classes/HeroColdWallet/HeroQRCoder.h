//
//  HeroQRCoder.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeroQRCoder : NSObject

+ (UIImage *)createQRImageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth fillColor:(UIColor *)color;

+ (NSString *)readQRCodeFromImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
