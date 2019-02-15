//
//  HeroTCP.m
//  CocoaAsyncSocket
//
//  Created by 李潇 on 2019/1/30.
//

#import "HeroTCP.h"
#import <NetworkExtension/NetworkExtension.h>

@interface HeroTCP ()

@property (nonatomic) NETunnelProviderManager *manager;
    
@end

@implementation HeroTCP

- (void)on:(NSDictionary *)json {
    [super on:json];
    if (json[@"shadowsocks"]) {
        if ([json[@"shadowsocks"][@"config"] boolValue]) {
            NSString *ip = json[@"shadowsocks"][@"ip"];
            NSNumber *port = json[@"shadowsocks"][@"port"];
            NSString *passowrd = json[@"shadowsocks"][@"password"];
            NSString *method = json[@"shadowsocks"][@"method"];
            
            [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
                if (managers.count == 0) {
                    [self createVPN:ip port:port password:passowrd method:method];
                } else {
                    self.manager = managers[0];
                }
                
                [self.manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnStausChanged) name:NEVPNStatusDidChangeNotification object:nil];
            }];
        }
        
        if (json[@"shadowsocks"][@"start"]) {
            [self.manager.connection startVPNTunnelWithOptions:nil andReturnError:nil];
        }
        if (json[@"shadowsocks"][@"stop"]) {
            [self.manager.connection stopVPNTunnel];
        }
    }
}
    
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createVPN:(NSString *)ip port:(NSNumber *)port password:(NSString *)password method:(NSString *)method {
    self.manager = [NETunnelProviderManager new];
    NETunnelProviderProtocol *config = [NETunnelProviderProtocol new];
    config.serverAddress = @"HeroTCP";
    NSDictionary *conf = @{@"ss_addr": ip, @"ss_port": port, @"ss_method": method, @"ss_password": password};
    config.providerConfiguration = conf;
    
    self.manager.protocolConfiguration = config;
    self.manager.localizedDescription = @"HeroNode TCP";
    self.manager.enabled = YES;
}
    
- (void)vpnStausChanged {
    switch (self.manager.connection.status) {
        case NEVPNStatusInvalid:
        NSLog(@"invalid");
        break;
        
        case NEVPNStatusConnecting:
        NSLog(@"connecting");
        break;
        
        case NEVPNStatusConnected:
        NSLog(@"connected");
        break;
        
        case NEVPNStatusReasserting:
        NSLog(@"reasserting");
        break;
        
        case NEVPNStatusDisconnected:
        NSLog(@"disconnected");
        break;
        
        case NEVPNStatusDisconnecting:
        NSLog(@"disconnecting");
        break;
        
        default:
        break;
    }
}


@end
