//
//  HeroTCP.m
//  CocoaAsyncSocket
//
//  Created by 李潇 on 2019/1/30.
//

#import "HeroTCP.h"
#import "Socks/Socks.h"

@implementation HeroTCP

- (void)on:(NSDictionary *)json {
    if (json[@"shadowsocks"]) {
        NSString *ip = json[@"shadowsocks"][@"ip"];
        NSString *port = json[@"shadowsocks"][@"port"];
        NSString *passowrd = json[@"shadowsocks"][@"password"];
        NSString *method = json[@"shadowsocks"][@"method"];
        EVSocksClient *client = [[EVSocksClient alloc] initWithHost:ip port:[port integerValue]];
        [client setSocksServerPassword:passowrd method:method];
        [client startWithLocalPort:1086];
    }
}

@end
