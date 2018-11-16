//
//  NSString+Hex.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/14.
//

#import "NSString+Hex.h"

@implementation NSString (Hex)

- (NSString *)hexString {
    NSString * hexStr = [NSString stringWithFormat:@"%@",
                         [NSData dataWithBytes:[self cStringUsingEncoding:NSUTF8StringEncoding]
                                        length:strlen([self cStringUsingEncoding:NSUTF8StringEncoding])]];
    
    for(NSString * toRemove in [NSArray arrayWithObjects:@"<", @">", @" ", nil])
        hexStr = [hexStr stringByReplacingOccurrencesOfString:toRemove withString:@""];
    
    return [@"0x" stringByAppendingString:hexStr];
}

@end
