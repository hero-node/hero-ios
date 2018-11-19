//
//  HeroModifyPasswordViewController.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/18.
//

#import <UIKit/UIKit.h>
#import "HeroAccount.h"
#import "UIView+Hero.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeroModifyPasswordViewController : UIViewController

- (instancetype)initWithAccount:(HeroAccount *)account;

@end

NS_ASSUME_NONNULL_END
