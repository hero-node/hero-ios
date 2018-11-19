//
//  HeroQRCoder.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/18.
//

#import "HeroQRCoder.h"

@implementation HeroQRCoder

+ (UIImage *)qrImageWithString:(NSString *)str {
    NSData *stringData = [str dataUsingEncoding: NSISOLatin1StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    UIImage *image = [UIImage imageWithCIImage:qrFilter.outputImage];
    
    return image;
}

@end
