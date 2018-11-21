//
//  HeroSignature.m
//  hero-ios
//
//  Created by Liu Guoping on 2018/10/26.
//

#import "HeroSignature.h"
#import "HeroAccount.h"
#import "HeroWallet.h"
#import "HeroColdWallet/HeroWalletListViewController.h"
#import "HeroColdWallet/HeroSignView.h"


@interface HeroSignature ()

@end

@implementation HeroSignature {

}

-(void)on:(NSDictionary *)json{
    [super on:json];
    self.hidden = true;
    [[HeroWallet sharedInstance] loadAccounts];
    __weak HeroSignature *weakSelf = self;
    if (json[@"accounts"]) {
        NSArray *accs = [HeroWallet sharedInstance].accounts;
        NSMutableDictionary *result = [@{@"value": @[@""]} mutableCopy];
        NSMutableArray *addresses = [NSMutableArray array];
        [accs enumerateObjectsUsingBlock:^(HeroAccount *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [addresses addObject:obj.address];
        }];
        result[@"value"] = addresses;
        
        if (json[@"isNpc"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:addresses options:NSJSONWritingPrettyPrinted error:nil];
                NSString *js = [NSString stringWithFormat:@"window['%@callback'](%@)",[self class],[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                [self.controller.webview stringByEvaluatingJavaScriptFromString:js];
            });
        }else{
            [self.controller on:result];
        }
    }
    
    if (json[@"message"]) {
        if ([[HeroWallet sharedInstance] defaultAccount]) {
            // message sign
            [self signMessage:json[@"message"] then:^(NSDictionary *sig) {
                [weakSelf completeSignType:0 sig:sig isNpc:json[@"isNpc"]];
            }];
        }else{
            //
            [[HeroWallet sharedInstance] importAccountThen:^{
                [weakSelf signMessage:json[@"message"] then:^(NSDictionary *sig) {
                    [weakSelf completeSignType:0 sig:sig isNpc:json[@"isNpc"]];
                }];
            }];
        }
    }
    
    if (json[@"transaction"]) {
        Transaction *tran = [Transaction transactionWithJSON:json[@"transaction"]];
        
        if ([[HeroWallet sharedInstance] defaultAccount]) {
            [self signTx:tran then:^(NSDictionary *sig) {
                [weakSelf completeSignType:1 sig:sig isNpc:json[@"isNpc"]];
            }];
        } else {
            [[HeroWallet sharedInstance] importAccountThen:^{
                [weakSelf signTx:tran then:^(NSDictionary *sig) {
                    [weakSelf completeSignType:1 sig:sig isNpc:json[@"isNpc"]];
                }];
            }];
        }
    }
    
    if (json[@"wallet"]) {
        HeroWalletListViewController *list = [[HeroWalletListViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
        list.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:list action:@selector(exitWallet)];
        [APP.keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)completeSignType:(NSInteger)type sig:(NSDictionary *)sig isNpc:(BOOL)isNpc {
    if (type == 0) {
        // message. TO BE VERIFIED:
        if (isNpc) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *js = [NSString stringWithFormat:@"window['%@callback']('%@')",[self class], sig];
                [self.controller.webview stringByEvaluatingJavaScriptFromString:js];
            });
        } else {
            [self.controller on:sig];
        }
    } else {
        // transaction
        if (isNpc) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *js = [NSString stringWithFormat:@"window['%@callback']('%@')",[self class], sig[@"raw"]];
                [self.controller.webview stringByEvaluatingJavaScriptFromString:js];
            });
        } else {
            [self.controller on:sig];
        }
    }
}

- (void)signMessage:(NSString *)message then:(void(^)(NSDictionary *sig))done {
    [[[HeroWallet sharedInstance] defaultAccount] validatePasswordThen:^{
        done([[[HeroWallet sharedInstance] defaultAccount] sign:message]);
    }];
}

- (void)signTx:(Transaction *)tx then:(void(^)(NSDictionary *sig))done {
    HeroSignView *signView = [[HeroSignView alloc] initWithTransaction:tx];
    [signView show];
    signView.done = done;
}

@end

