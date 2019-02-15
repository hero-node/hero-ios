//
//  HeroTCP.m
//  CocoaAsyncSocket
//
//  Created by 李潇 on 2019/1/30.
//

#import "HeroTCP.h"

@implementation HeroTCP

- (void)on:(NSDictionary *)json {
    if (json[@"shadowsocks"]) {
        NSString *ip = json[@"shadowsocks"][@"ip"];
        NSString *port = json[@"shadowsocks"][@"port"];
        NSString *passowrd = json[@"shadowsocks"][@"password"];
        NSString *method = json[@"shadowsocks"][@"method"];
        
    }
}

@end
