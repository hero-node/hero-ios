//
//  HeroWallet.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/8.
//


#import "HeroWallet.h"
#import "HeroImportWalletViewController.h"
#import "NSData+HexString.h"

static HeroWallet *_wallet;
NSString * const HERO_WALLET_LIST = @"HERO_WALLET_LIST";

@implementation HeroWallet

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _wallet = [[HeroWallet alloc] init];
    });
    return _wallet;
}

- (instancetype)init {
    if (self = [super init]) {
        self.accounts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (HeroAccount *)defaultAccount {
    return self.accounts.firstObject;
}
- (void)setDefaultAccount:(NSString *)aId {
    NSMutableArray *idList = [NSMutableArray array];
    [idList addObject:aId];
    [self.accounts enumerateObjectsUsingBlock:^(HeroAccount * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.aID isEqualToString:aId]) {
            [idList addObject:obj.aID];
        }
    }];
    [[NSUserDefaults standardUserDefaults] setValue:idList forKey:HERO_WALLET_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadAccounts];

}

- (void)addAccount:(HeroAccount *)account {
    [self.accounts addObject:account];
    [account save];
    [self sync];
}

- (void)removeAccount:(HeroAccount *)account {
    [self.accounts removeObject:account];
    [account deleteAccount];
    [self sync];
}

- (void)sync {
    NSMutableArray *idList = [NSMutableArray array];
    [self.accounts enumerateObjectsUsingBlock:^(HeroAccount * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [idList addObject:obj.aID];
    }];
    
    [[NSUserDefaults standardUserDefaults] setValue:idList forKey:HERO_WALLET_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadAccounts {
    NSArray *idList = [[NSUserDefaults standardUserDefaults] arrayForKey:HERO_WALLET_LIST];
    NSMutableArray *accounts = [NSMutableArray array];
    [idList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *aID = obj;
        HeroAccount *acc = [HeroAccount loadWithID:aID];
        [accounts addObject:acc];
    }];
    self.accounts = accounts;
}

- (void)importAccountThen:(void (^)(void))then {
    HeroImportWalletViewController *import = [[HeroImportWalletViewController alloc] init];
    [import importThen:then];
}

@end

@implementation Transaction (json)

+ (instancetype)transactionWithJSON:(NSDictionary *)json {
    Transaction *tran = [Transaction transaction];
    tran.toAddress = [Address addressWithString:json[@"to"]];
    tran.gasLimit = [BigNumber bigNumberWithHexString:json[@"gas"]];
    tran.gasPrice = [BigNumber bigNumberWithHexString:json[@"gasPrice"]];
    tran.nonce = [BigNumber bigNumberWithHexString:json[@"nonce"]].integerValue;
    tran.value = json[@"value"] ? [BigNumber bigNumberWithHexString:json[@"value"]] : [BigNumber bigNumberWithInteger:0];
    tran.data = [NSData dataWithHexString:json[@"data"]];
    tran.chainId = 0x01;
    
    return tran;
}

@end
