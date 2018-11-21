//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name Facebook nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//
//  Created by atman on 15/1/7.
//  Copyright (c) 2015年 GPLIU. All rights reserved.
//

#import "HeroWebView.h"
#import "UIView+Hero.h"
#import <JavaScriptCore/JSContext.h>
#import <MobileCoreServices/UTType.h>
#import "NSString+Additions.h"
#import "hero.h"
#import <AVFoundation/AVAssetDownloadTask.h>

static NSString* INJECTJS = @"heroSignature = {init:function(){if(window.Web3){Object.keys(window).forEach(function(k) {if(window[k]&& window[k].eth){var eth = window[k].eth;eth.accounts=function(){return new Promise(function (resolve,reject){window.heroSignature.npc('HeroSignature','acounts',function(res){resolve(JSON.parse(res));});});};eth.getAccounts = async function(){return eth.accounts();};};});}},npc:function(module,fun,callback){window[module+fun+'callback'] = callback;var npcStr = 'heronpc://' +module+'::'+fun ;if (window.npc) {window.npc(npcStr)}else{var iframe = document.createElement('iframe');iframe.setAttribute('src', npcStr);document.documentElement.appendChild(iframe);iframe.parentNode.removeChild(iframe);iframe = null;}}}heroSignature.init();";

@interface HeroWebView()<UIWebViewDelegate>

@end

@implementation HeroWebView
{
    NSString *_urlStr;
    BOOL _isGetRequest;
    id _postData;
    NSArray *_hijackURLs;
    NSMutableDictionary * modules;
}

-(void)on:(NSDictionary *)json
{
    [super on:json];
    self.backgroundColor = UIColorFromRGB(0xf6f6f6);
    self.delegate = self;
    if (json[@"hijackURLs"]) {
        _hijackURLs = json[@"hijackURLs"];
    }
    if (json[@"url"]) {
        _isGetRequest = YES;
        if ([json[@"url"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)json[@"url"];
            NSString *method = dic[@"method"];
            _urlStr = dic[@"url"];
            _postData = dic[@"data"];
            if (_postData) {
                _isGetRequest = NO;
            }
            if (method) {
                if ([method isEqualToString:@"POST"]) {
                    _isGetRequest = NO;
                } else {
                    _isGetRequest = YES;
                }
            }
        } else {
            _urlStr = json[@"url"];
        }
        if (_isGetRequest) {
#ifdef DEBUG
            if ([_urlStr componentsSeparatedByString:@"?"].count > 1) {
                _urlStr = [NSString stringWithFormat:@"%@%@",_urlStr,@"&test=true" ];
            }else{
                _urlStr = [NSString stringWithFormat:@"%@%@",_urlStr,@"?test=true" ];
            }
#endif
            NSURL *url = [NSURL URLWithString:_urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"]) {
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"];
                for (NSString *key in [dic allKeys]) {
                    [request setValue:dic[key] forHTTPHeaderField:key];
                }
            }
            [self loadRequest:request];
        } else {
            NSURL *url = [NSURL URLWithString:_urlStr];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];
            if (_postData) {
                [request setHTTPBody:[_postData dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [self loadRequest:request];
        }
    }
    if (json[@"innerHtml"]) {
        [self loadHTMLString:json[@"innerHtml"] baseURL:NULL];
    }
    if (json[@"contentSize"]) {
        NSString *x = json[@"contentSize"][@"x"];
        NSString *y = json[@"contentSize"][@"y"];
        CGSize size = CGSizeMake(x.floatValue, y.floatValue);
        if ([x hasSuffix:@"x"]) {
            size.width = SCREEN_W*x.floatValue;
        }
        if ([y hasSuffix:@"x"]) {
            size.width = SCREEN_H*x.floatValue;
        }
        self.scrollView.contentSize = size;
    }
    if (json[@"contentOffset"]) {
        NSString *x = json[@"contentOffset"][@"x"];
        NSString *y = json[@"contentOffset"][@"y"];
        CGPoint point = CGPointMake(x.floatValue, y.floatValue);
        if ([x hasSuffix:@"x"]) {
            point.x = SCREEN_W*x.floatValue;
        }
        if ([y hasSuffix:@"x"]) {
            point.y = SCREEN_H*x.floatValue;
        }
        self.scrollView.contentOffset = CGPointMake(x.floatValue, y.floatValue);
    }
}

- (void)refresh {
    if (!_isGetRequest && [self.request.URL.absoluteString isEqualToString:_urlStr]) {
        NSURL *url = [NSURL URLWithString:_urlStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        if (_postData) {
            [request setHTTPBody:[_postData dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [self loadRequest:request];
    } else {
        [self reload];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title && title.length > 0) {
        self.controller.title = title;
    }
    [webView stringByEvaluatingJavaScriptFromString:@"window.Hero && Hero.viewWillAppear()"];
    [self.controller on:@{@"command":@"webViewDidFinishLoad"}];
    if (self.controller.webview.superview) { //普通web页面
        [self.controller.navigationController setNavigationBarHidden:NO animated:YES];
        self.scrollView.contentInset = UIEdgeInsetsMake(self.controller.navigationController.navigationBar.bounds.size.height, 0, 0, 0);

    }
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.deviceWidth=%f;window.deviceHeight=%f;",SCREEN_W,SCREEN_H]];

}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
    if (self.json[@"didFailLoadWithError"]) {
        [self.controller on:self.json[@"didFailLoadWithError"]];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath: [[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"]]) {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"]]]];
    }else{
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[@"{\"nav\":{\"title\":\"404\",\"navigationBarHidden\":false},\"views\":[{\"class\":\"HeroLabel\",\"text\":\"This is probably a land of nowhere\",\"frame\":{\"w\":\"1x\",\"y\":\"0.5x-80\",\"h\":\"40\"},\"alignment\":\"center\",\"textColor\":\"666666\"},{\"class\":\"HeroButton\",\"frame\":{\"w\":\"120\",\"x\":\"0.5x-50\",\"y\":\"0.5x\",\"h\":\"50\"},\"title\":\"Retry it\",\"titleColor\":\"778899\",\"backgroundColor\":\"eeeeeeee\",\"ripple\":true,\"click\":{\"command\":\"refresh\"},\"cornerRadius\":5}]}" dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        [self.controller on:@{@"ui":json}];
        [self.controller on:@{@"command":@"webViewDidFinishLoad"}];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *path = [request URL].absoluteString;
    for (NSDictionary *item in _hijackURLs) {
        NSString *hackurl = item[@"url"];
        BOOL isLoad = [item[@"isLoad"] boolValue];
        if ([hackurl isEqualToString:path]) {
            [self.controller on:@{@"name":self.name,@"url":hackurl}];
            return isLoad;
        }
    }
    if ([request.URL.absoluteString hasPrefix:@"hero://"]) {
        NSString* str;
        if ([request.URL.absoluteString hasSuffix:@"ready"]) {
            str = [webView stringByEvaluatingJavaScriptFromString:
                   @"Hero.outObjects()"];
        }else{
            str = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"hero://" withString:@""];
            str = [str decodeFromPercentEscapeString];
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (json != nil) {
            [self.controller on:json];
        }
        return NO;
    }else if ([request.URL.absoluteString hasPrefix:@"heronpc://"]) {
        NSString* str = [[request.URL.absoluteString stringByReplacingOccurrencesOfString:@"heronpc://" withString:@""] decodeFromPercentEscapeString];
        NSString *module = [str componentsSeparatedByString:@"?"][0];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[[str componentsSeparatedByString:@"?"][1] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (!modules) {
            modules = [NSMutableDictionary dictionary];
        }
        if (!modules[module]) {
            UIView *moduleObject = [[NSClassFromString(module) alloc]init];
            if (!moduleObject) {
                NSString *js = [NSString stringWithFormat:@"window['%@callback']({npc:'fail'})",module];
                [self stringByEvaluatingJavaScriptFromString:js];
            }
            moduleObject.controller = self.controller;
            modules[module] = moduleObject;
        }
        [modules[module] performSelector:@selector(on:) withObject:json];
        return NO;
    }else{
        return [self.controller shouldLoadFromUrl:path];
    }
}
-(void)dealloc
{
    DLog(@"webview dealloced");
}

@end


static NSString *URLProtocolHandledKey = @"URLProtocolHandledKey";
static NSOperationQueue *netWorkQueue;
//local proxy

@interface HeroLocalhostURLProtocol ()
@end

@implementation HeroLocalhostURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *monitorStr = request.URL.absoluteString;
    DLog(@"loading:%@",monitorStr);
    //if processed,return;
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    //proxy http://localhost:3000
    if ( ([request.URL.absoluteString hasPrefix:@"https://localhost:3000"]))
    {
        return YES;
    }
    return NO;
}
+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return mutableReqeust;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}
- (void)startLoading
{
    NSURL *url = [self request].URL;
    NSData *data;
    NSString *mimeType;
    if ([url.absoluteString hasPrefix:@"https://localhost:3000"]) {
        NSString *resourcePath = url.path;
        resourcePath = [resourcePath substringFromIndex:1];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourcePath ofType:nil];
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        data = [file readDataToEndOfFile];
        mimeType = [self getMIMETypeWithCAPIAtFilePath:path];
        [file closeFile];
        [self sendData:data mimeType:mimeType];
    }
}
         
-(void)sendData:(NSData*) data mimeType:(NSString*)mimeType{
    NSURL *url = [self request].URL;
    NSInteger dataLength = data.length;
    NSString *httpVersion = @"HTTP/1.1";
    NSHTTPURLResponse *response = nil;
    if (dataLength > 0) {
        response = [self jointResponseWithData:data dataLength:dataLength mimeType:mimeType requestUrl:url statusCode:200 httpVersion:httpVersion];
    } else {
        response = [self jointResponseWithData:[@"404" dataUsingEncoding:NSUTF8StringEncoding] dataLength:3 mimeType:mimeType requestUrl:url statusCode:404 httpVersion:httpVersion];
    }
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
 }
-(NSHTTPURLResponse *)jointResponseWithData:(NSData *)data dataLength:(NSInteger)dataLength mimeType:(NSString *)mimeType requestUrl:(NSURL *)requestUrl statusCode:(NSInteger)statusCode httpVersion:(NSString *)httpVersion
{
    NSDictionary *dict = @{@"Content-type":mimeType,
                           @"Access-Control-Allow-Origin":@"*",
                           @"Access-Control-Allow-Methods": @"POST, GET, OPTIONS, DELETE",
                           @"Content-length":[NSString stringWithFormat:@"%ld",dataLength]};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:requestUrl statusCode:statusCode HTTPVersion:httpVersion headerFields:dict];
    return response;
}
-(NSString *)getMIMETypeWithCAPIAtFilePath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return @"text/html";
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}
- (void)stopLoading
{
    [netWorkQueue cancelAllOperations];
}
@end

@interface HeroProviderURLProtocol ()
@end

@implementation HeroProviderURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.URL.absoluteString hasSuffix:@".js"]) {
        return NO;
    }
    if ([request.URL.absoluteString hasSuffix:@".css"]) {
        return NO;
    }
    if ([request.URL.absoluteString hasSuffix:@".jpeg"]) {
        return NO;
    }
    if ([request.URL.absoluteString hasSuffix:@".png"]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    return YES;
}
- (void)startLoading
{
    if(!netWorkQueue){
        netWorkQueue = [[NSOperationQueue alloc]init];
        netWorkQueue.maxConcurrentOperationCount = 10;
    }
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    if ([mutableReqeust.URL.absoluteString hasPrefix:@"https://localhost:3001"]) {
        NSDictionary *dict = @{
                               @"Access-Control-Allow-Origin":@"*",
                               @"Access-Control-Allow-Methods": @"POST, GET, OPTIONS, DELETE",
                               };
        [mutableReqeust setAllHTTPHeaderFields:dict];
//        [mutableReqeust setURL:[NSURL URLWithString:@"http://47.52.172.254:8545"]];
        [mutableReqeust setURL:[NSURL URLWithString:@"https://mainnet.infura.io/33USgHxvCp3UoDItBSRs"]];
    }
    [NSURLConnection sendAsynchronousRequest:mutableReqeust queue:netWorkQueue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if(data && (!connectionError)){
                NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (str && ([str hasPrefix:@"<!"]||[str hasPrefix:@"<html>"])) {
                    str = [str stringByReplacingOccurrencesOfString:@"<head>" withString:@"<head><script src='https://localhost:3000/hero-home/hero-provider.js'></script>"];
                    [self sendData:[str dataUsingEncoding:NSUTF8StringEncoding] mimeType:[response MIMEType]?[response MIMEType]:@"text/html"];
                }else if(data.length > 0){
                    [self sendData:data mimeType:[response MIMEType]?[response MIMEType]:@"application/json"];
                }else{
                    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                    [[self client] URLProtocol:self didLoadData:data];
                    [[self client] URLProtocolDidFinishLoading:self];
                }
            }else{
                [[self client] URLProtocol:self didFailWithError:connectionError];
            }
        }];
}

@end
