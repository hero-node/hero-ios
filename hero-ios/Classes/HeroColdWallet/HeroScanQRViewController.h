//
//  HeroScanQRViewController.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeroScanQRViewController : UIViewController

- (instancetype)initWithCompletion:(void(^)(NSString *result))completion;

@end

NS_ASSUME_NONNULL_END
