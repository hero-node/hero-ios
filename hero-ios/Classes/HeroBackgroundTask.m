//
//  HeroBackgroundTask.m
//  hero-ios
//
//  Created by Liu Guoping on 2018/11/23.
//

#import "HeroBackgroundTask.h"
#import "UIAlertView+blockDelegate.h"
#import "HeroViewController.h"
#import "NSString+Additions.h"
#import <objc/runtime.h>

static NSString *backgroundTaskUrl;

typedef void (^CompletionHandler)(UIBackgroundFetchResult);
@interface UIApplication(HeroBackgroundTask)
@end


@implementation UIApplication(HeroBackgroundTask)


@end

@implementation HeroBackgroundTask
{
    NSString *url;
    int *interval;
    id backgroundTaskBlock;
}
-(void)on:(NSDictionary *)json {
    [super on:json];
    self.hidden = true;
    
    if (json[@"interval"]) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:[json[@"interval"] integerValue]];
    }
    if (json[@"url"]) {
        id backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if (!backgroundModes) {
            [UIAlertView showAlertViewWithTitle:@"" message:@"Set info.plist with UIBackgroundModes first" cancelButtonTitle:@"cancel" otherButtonTitles:@[@"Ok"] onDismiss:nil onCancel:nil];
        }
        backgroundTaskUrl = json[@"url"];
        __weak __typeof(self) weakSelf = self;
        backgroundTaskBlock =  ^(UIApplication * application, CompletionHandler completionHandler) {
            if (backgroundTaskUrl != NULL) {
                [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:backgroundTaskUrl] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (!error && location) {
                        NSData *data = [NSData dataWithContentsOfURL:location];
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        [weakSelf.controller on:json];
                        completionHandler(UIBackgroundFetchResultNewData);
                    }else{
                        completionHandler(UIBackgroundFetchResultNoData);
                    }
                }];
            }
        };
        class_addMethod([APP.delegate class], @selector(application:performFetchWithCompletionHandler:), imp_implementationWithBlock(backgroundTaskBlock), "@:@");
    }

}
@end
