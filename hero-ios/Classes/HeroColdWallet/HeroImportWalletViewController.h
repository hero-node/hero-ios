//
//  HeroImportWalletViewController.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeroImportWalletViewController : UIViewController

- (void)importThen:(void(^)(void))done;

@end

NS_ASSUME_NONNULL_END
