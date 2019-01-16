//
//  MyHttpConnection.m
//  hero-ios_Example
//
//  Created by 李潇 on 2019/1/16.
//  Copyright © 2019 刘国平. All rights reserved.
//

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <KTVCocoaHTTPServer/HTTPLogging.h>
#import "MyHttpConnection.h"

@implementation MyHttpConnection

- (BOOL)isSecureServer {
    
    // Create an HTTPS server (all connections will be secured via SSL/TLS)
    return YES;
}

- (NSArray *)sslIdentityAndCertificates {
    SecIdentityRef identityRef = NULL;
    SecCertificateRef certificateRef = NULL;
    SecTrustRef trustRef = NULL;
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"hero-home/server" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(PKCS12Data);
    CFStringRef password = CFSTR("hero2019");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = errSecSuccess;
    securityError =  SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        identityRef = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        trustRef = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return nil;
    }
    
    SecIdentityCopyCertificate(identityRef, &certificateRef);
    NSArray *result = [[NSArray alloc] initWithObjects:(id)CFBridgingRelease(identityRef),   (id)CFBridgingRelease(certificateRef), nil];
    
    return result;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    // do something
    return [super httpResponseForMethod:method URI:path];
}

- (void)startConnection
{
    // Override me to do any custom work before the connection starts.
    //
    // Be sure to invoke [super startConnection] when you're done.
    
//    HTTPLogTrace();
    
    if ([self isSecureServer])
    {
        // We are configured to be an HTTPS server.
        // That is, we secure via SSL/TLS the connection prior to any communication.
        
        NSArray *certificates = [self sslIdentityAndCertificates];
        
        if ([certificates count] > 0)
        {
            // All connections are assumed to be secure. Only secure connections are allowed on this server.
            NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
            
            // Configure this connection as the server
            [settings setObject:[NSNumber numberWithBool:YES]
                         forKey:(NSString *)kCFStreamSSLIsServer];
            
            [settings setObject:certificates
                         forKey:(NSString *)kCFStreamSSLCertificates];
            
            // Configure this connection to use the highest possible SSL level
            //            [settings setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
            //                         forKey:(NSString *)kCFStreamSSLLevel];
            
            [asyncSocket startTLS:settings];
        }
    }
    
    [self performSelector:@selector(startReadingRequest)];
}

@end
