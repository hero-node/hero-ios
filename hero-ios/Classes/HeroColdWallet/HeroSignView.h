//
//  HeroSignView.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/19.
//

#import <UIKit/UIKit.h>
#import "HeroWallet.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeroSignView : UIView

@property (nonatomic, copy) void (^done)(NSDictionary *sig);

- (instancetype)initWithTransaction:(Transaction *)tran;
- (void)show;

@end

NS_ASSUME_NONNULL_END
