//
//  HeroAccount.h
//  hero-ios
//
//  Created by 李潇 on 2018/11/8.
//

#import <Foundation/Foundation.h>
#import <ethers/ethers.h>

NS_ASSUME_NONNULL_BEGIN

    
@interface HeroAccount : NSObject

@property (nonatomic) Account *ethAccount;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *logo;
@property (nonatomic) NSString *aID;
@property (nonatomic) NSString *password;

- (instancetype)initWithName:(NSString *)name logo:(NSString *)logo ethAccount:(Account *)ethAccount password:(NSString *)password;

- (instancetype)initWithName:(NSString *)name logo:(NSString *)logo seed:(NSString *)seed password:(NSString *)password;

- (instancetype)initWithName:(NSString *)name logo:(NSString *)logo privateKey:(NSString *)privateKey password:(NSString *)password;

- (NSString *)privateString;

- (NSString *)address;

+ (HeroAccount *)loadWithID:(NSString *)aID;

- (void)deleteAccount;

- (void)save;

- (NSDictionary *)sign:(NSString *)message;

- (NSDictionary *)signTx:(Transaction *)tx;

- (void)validatePasswordThen:(void(^)(void))then;
    
@end

NS_ASSUME_NONNULL_END
