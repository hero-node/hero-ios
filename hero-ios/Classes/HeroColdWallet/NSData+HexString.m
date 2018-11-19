//
//  NSData+HexString.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/9.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)

// Not efficent
+(id)dataWithHexString:(NSString *)hex {
    if ([hex rangeOfString:@"0x"].length > 0) {
        hex = [hex stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }
    char buf[3];
    buf[2] = '\0';
    NSAssert(0 == [hex length] % 2, @"Hex strings should have an even number of digits (%@)", hex);
    unsigned char *bytes = malloc([hex length]/2);
    unsigned char *bp = bytes;
    for (CFIndex i = 0; i < [hex length]; i += 2) {
        buf[0] = [hex characterAtIndex:i];
        buf[1] = [hex characterAtIndex:i+1];
        char *b2 = NULL;
        *bp++ = strtol(buf, &b2, 16);
        NSAssert(b2 == buf + 2, @"String should be all hex digits: %@ (bad digit around %d)", hex, i);
    }
    
    return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
}

- (NSString *)hexString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
