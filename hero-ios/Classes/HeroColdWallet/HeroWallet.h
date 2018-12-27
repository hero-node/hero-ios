//
//  HeroWallet.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/8.
//

#import <Foundation/Foundation.h>
#import "HeroAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeroWallet : NSObject

@property (nonatomic) NSMutableArray<HeroAccount *> *accounts;

+ (instancetype)sharedInstance;

- (HeroAccount *)defaultAccount;

- (void)addAccount:(HeroAccount *)account;
- (void)setDefaultAccount:(NSString *)aId;
- (void)removeAccount:(HeroAccount *)account;

- (void)loadAccounts;

- (void)importAccountThen:(void(^)(void))then;

@end

@interface Transaction (json)

+ (instancetype)transactionWithJSON:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
