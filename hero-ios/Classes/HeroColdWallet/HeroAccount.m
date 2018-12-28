//
//  HeroAccount.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/8.
//

#import "HeroWallet.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "HeroAccount.h"
#import "NSData+HexString.h"

NSString * const HERO_ACCOUNT_SERVICE = @"HERO_ACCOUNT_SERVICE";
JSContext *context;

@interface HeroAccount () <UIAlertViewDelegate>

@property (nonatomic, copy) void (^validatePwd)(void);
@property (nonatomic, copy) void (^changeName)(NSString*);

@end

@implementation HeroAccount

- (instancetype)initWithName:(NSString *)name logo:(nonnull NSString *)logo ethAccount:(nonnull Account *)ethAccount password:(nonnull NSString *)password {
    self = [super init];
    if (self) {
        self.name = name;
        self.logo = logo;
        self.aID = [[NSUUID UUID] UUIDString];
        self.password = password;
        self.ethAccount = ethAccount;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name logo:(nonnull NSString *)logo seed:(nonnull NSString *)seed password:(nonnull NSString *)password {
    self = [super init];
    if (self) {
        self.name = name;
        self.logo = logo;
        self.aID = [[NSUUID UUID] UUIDString];
        self.password = password;
        self.ethAccount = [Account accountWithMnemonicPhrase:seed];
    }
    return self.ethAccount ? self : nil;
}

- (instancetype)initWithName:(NSString *)name logo:(NSString *)logo privateKey:(NSString *)privateKey password:(NSString *)password {
    self = [super init];
    if (self) {
        self.name = name;
        self.logo = logo;
        self.aID = [[NSUUID UUID] UUIDString];
        self.password = password;
        NSData *data = [NSData dataWithHexString:privateKey];
        if (!data) {
            return nil;
        }
        self.ethAccount = [Account accountWithPrivateKey:data];
    }
    return self.ethAccount ? self : nil;
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:self.name forKey:[self.aID stringByAppendingString:@"_name"]];
    [[NSUserDefaults standardUserDefaults] setObject:self.logo forKey:[self.aID stringByAppendingString:@"_logo"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:HERO_ACCOUNT_SERVICE];
    [store setData:self.ethAccount.privateKey forKey:self.aID];
    [store setString:self.password forKey: [self.aID stringByAppendingString:@"_pwd"]];
}

+ (HeroAccount *)loadWithID:(NSString *)aID {
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:[aID stringByAppendingString:@"_name"]];
    NSString *logo = [[NSUserDefaults standardUserDefaults] objectForKey:[aID stringByAppendingString:@"_logo"]];
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:HERO_ACCOUNT_SERVICE];
    NSData *data = [store dataForKey:aID];
    NSString *password = [store stringForKey:[aID stringByAppendingString:@"_pwd"]];
    
    HeroAccount *acc = [[HeroAccount alloc] initWithName:name logo:logo privateKey:[data hexString] password:password];
    acc.aID = aID;
    return acc;
}

- (void)deleteAccount {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self.aID stringByAppendingString:@"_name"]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self.aID stringByAppendingString:@"_logo"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:HERO_ACCOUNT_SERVICE];
    [store removeItemForKey:self.aID];
    [store removeItemForKey:[self.aID stringByAppendingString:@"_pwd"]];
}

- (NSString *)privateString {
    return [self.ethAccount.privateKey hexString];
}

- (NSString *)address {
    return self.ethAccount.address.checksumAddress;
}

- (NSDictionary *)sign:(NSString *)message {
    NSData *messData = [SecureData hexStringToData:message];
    Signature *sig = [self.ethAccount signMessage:messData];
    if (!sig) {
        return nil;
    }
    return @{@"r": [SecureData dataToHexString:sig.r], @"s": [SecureData dataToHexString:sig.s], @"v": [NSString stringWithFormat:@"0x%02x", sig.v]};
}

- (NSDictionary *)signTx:(Transaction *)tx {
    [self.ethAccount sign:tx];
    if (!tx.signature) {
        return nil;
    }
    return @{
             @"raw":[@"0x" stringByAppendingString:[[tx serialize] hexString]],
             @"tx": @{
                     @"nonce": [NSString stringWithFormat:@"0x%02lx", (unsigned long)tx.nonce],
                     @"gasPrice": [tx.gasPrice hexString],
                     @"gas":[tx.gasLimit hexString],
                     @"to": tx.toAddress.checksumAddress,
                     @"value": [tx.value hexString],
                     @"input": [tx.data hexString],
                     @"r": [SecureData dataToHexString:tx.signature.r],
                     @"s": [SecureData dataToHexString:tx.signature.s],
                     @"v":[NSString stringWithFormat:@"0x%02x", tx.signature.v],
                     @"hash": [tx.transactionHash hexString]
                     }
             };
}

- (void)validatePasswordThen:(void (^)(void))then {
    self.validatePwd = then;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"输入钱包密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"确认"];
    alert.tag = 100;
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}
- (void)changeNameThen:(void (^)(NSString *name))then{
    self.changeName = then;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"输入钱包名字" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"确认"];
    alert.tag = 101;
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 100) {
        NSString *pwd = [alertView textFieldAtIndex:0].text;
        if ([pwd isEqualToString:self.password]) {
            self.validatePwd();
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码错误" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
    if (buttonIndex == 1 && alertView.tag == 101) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        self.changeName(name);
    }
}

+ (JSContext *)jsContext {
    if (!context) {
        context = [JSContext new];
        NSString *heroEncryptJS = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://localhost:3000/hero-home/hero-encrypt.js"] encoding:NSUTF8StringEncoding error:nil];
        heroEncryptJS = [@"var window = this;\n" stringByAppendingString:heroEncryptJS];
        [context evaluateScript:heroEncryptJS];
    }
    return context;
}

- (NSString *)publicString {
    JSContext *context = [HeroAccount jsContext];
    JSValue *value = [context[@"getPublicKey"] callWithArguments:@[[self privateString]]];
    return [value toString];
}

- (NSString *)encrypt:(NSString *)pub data:(NSString *)data {
    NSString *randomString = [self randomString:32];
    NSString *iv = [self randomString:16];
    JSContext *context = [HeroAccount jsContext];
    JSValue *value = [context[@"heroencrypt"] callWithArguments:@[pub, data, iv, randomString]];
    return [value toString];
}

- (NSString *)decrypt:(NSString *)data {
    JSContext *context = [HeroAccount jsContext];
    JSValue *value = [context[@"decrypt"] callWithArguments:@[[self privateString], data]];
    return [value toString];
}

//利用CCRandomGenerateBytes实现随机字符串的生成
- (NSString *)randomString:(NSInteger)length {
    uint8_t randomBytes[length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, randomBytes);
    if(result == 0) {
        NSMutableString *uuidStringReplacement = [[NSMutableString alloc] initWithCapacity:length*2];
        for(NSInteger index = 0; index < length; index++)
        {
            [uuidStringReplacement appendFormat: @"%02x", randomBytes[index]];
        }
        NSLog(@"uuidStringReplacement is %@", uuidStringReplacement);
        return uuidStringReplacement;
    } else {
        NSLog(@"SecRandomCopyBytes failed for some reason");
    }
    return nil;
}

@end



