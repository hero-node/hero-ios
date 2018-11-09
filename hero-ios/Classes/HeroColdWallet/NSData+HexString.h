//
//  NSData+HexString.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HexString)

+(id)dataWithHexString:(NSString *)hex;

- (NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
