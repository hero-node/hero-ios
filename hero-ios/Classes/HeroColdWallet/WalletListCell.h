//
//  WalletListCell.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/15.
//

#import <UIKit/UIKit.h>
#import "HeroAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletListCell : UITableViewCell

- (void)setAccount:(HeroAccount *)account;

@end

NS_ASSUME_NONNULL_END
