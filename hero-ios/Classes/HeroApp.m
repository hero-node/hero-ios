//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//  Created by gpliu@icloud.com
//
//Redistribution and use in source and binary forms, with or without modification,
//are permitted provided that the following conditions are met:
//
//* Redistributions of source code must retain the above copyright notice, this
//list of conditions and the following disclaimer.
//
//* Redistributions in binary form must reproduce the above copyright notice,
//this list of conditions and the following disclaimer in the documentation
//and/or other materials provided with the distribution.
//
//* Neither the name Facebook nor the names of its contributors may be used to
//endorse or promote products derived from this software without specific
//prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.




#import "HeroApp.h"
#import "UIView+Hero.h"
#import <CoreImage/CoreImage.h>

@interface UITabBar (badge)
- (void)showBadgeOnItemIndex:(int)index;   //显示小红点
- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点
@end


@interface HeroApp()<UITabBarControllerDelegate>
@end
@implementation HeroApp
{
    UIColor *_tintColor;
    UITabBarController *tabCon;
    UINavigationController *nav;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        nav = [[UINavigationController alloc]init];
        [nav setNavigationBarHidden:NO];
        [nav.navigationBar setTranslucent:YES];

        //new app depreated
        [[NSNotificationCenter defaultCenter] addObserverForName:@"newApp" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self on:note.object];
        }];
        //tabSelect depreated
        [[NSNotificationCenter defaultCenter] addObserverForName:@"tabSelect" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self on:@{@"tabSelect":note.object}];
        }];
        //app red dot
        [[NSNotificationCenter defaultCenter] addObserverForName:@"HeroApp" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self on:note.object];
        }];
        
        //app shake
        [[NSNotificationCenter defaultCenter] addObserverForName:@"HeroShakeNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self->nav popViewControllerAnimated:YES];
        }];
    }
    return self;
}

-(void)on:(NSDictionary *)json{
    if (json[@"tintColor"]) {
        _tintColor = UIColorFromStr(json[@"tintColor"]);
    }
    if (json[@"badgeValue"]) {
        int index = [json[@"badgeValue"][@"index"] intValue];
        NSString *badgeValue = json[@"badgeValue"][@"badgeValue"];
        if ([badgeValue isEqualToString:@"red"]) {
            [tabCon.tabBar showBadgeOnItemIndex:index];
        }else if (badgeValue.length > 0){
            tabCon.tabBar.items[index].badgeValue = badgeValue;
        }else{
            [tabCon.tabBar hideBadgeOnItemIndex:index];
            tabCon.tabBar.items[index].badgeValue = nil;
        }
    }
    if (json[@"tabSelect"]) {
        NSInteger selected = [json[@"tabSelect"][@"value"] integerValue];
        tabCon.selectedIndex = selected;
        [self tabBarController:tabCon didSelectViewController:tabCon.selectedViewController];
        [nav popToRootViewControllerAnimated:NO];
    }
    if (json[@"tabs"]) {
        NSArray *arr = json[@"tabs"];
        if (arr.count > 0) {
            tabCon = [[UITabBarController alloc]init];
            if (arr.count == 1) {
                [tabCon.tabBar setHidden:YES];
            }
            tabCon.automaticallyAdjustsScrollViewInsets = NO;
            tabCon.delegate = self;
            for (int i =0;i<arr.count;i++) {
                NSDictionary *dic = arr[i];
                NSString *type = dic[@"class"]?dic[@"class"]:@"HeroViewController";
                HeroViewController *vc = [[NSClassFromString(type) alloc]initWithUrl:dic[@"url"]];
                vc.title = dic[@"title"];
                UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:dic[@"title"] image:[UIImage imageNamed: dic[@"image"]] tag:i];
                [vc setTabBarItem:item];
                [tabCon addChildViewController:vc];
                if (i == 0) {
                    tabCon.title = vc.title;
                    tabCon.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem;
                    tabCon.navigationItem.rightBarButtonItem = vc.navigationItem.rightBarButtonItem;
                    tabCon.navigationItem.titleView = vc.navigationItem.titleView;
                }
            }
            [tabCon.tabBar setTranslucent:YES];
            [nav pushViewController:tabCon animated:YES];
            self.window.rootViewController = nav;
            [self.window makeKeyAndVisible];
        }
        if (_tintColor) {
            [APP.keyWindow setTintColor:_tintColor];
        }
    }
}
#pragma mark tabBarController delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    tabBarController.navigationItem.title = viewController.title;
    tabBarController.navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem;
    tabBarController.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
    tabBarController.navigationItem.titleView = viewController.navigationItem.titleView;
}

@end

@implementation UITabBar (badge)
- (void)showBadgeOnItemIndex:(int)index{
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    //确定小红点的位置
    float percentX = (index +0.6) / self.items.count;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    [self addSubview:badgeView];
}

- (void)hideBadgeOnItemIndex:(int)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(int)index{
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

@end

