//
//  HeroSignature.m
//  hero-ios
//
//  Created by Liu Guoping on 2018/10/26.
//

#import "HeroSignature.h"
@interface HeroSignatureInportController : HeroViewController
@end

@implementation HeroSignature{
    BOOL hasKey;
    UIView *signView;
    HeroSignatureInportController *importViewController;
}
-(void)importFail {
    [importViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)on:(NSDictionary *)json{
    [super on:json];
    if (json[@"message"]) {
        if (hasKey) {
            
        }else{
            [self initInportViewController];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:importViewController];
            nav.navigationBar.translucent = false;
            importViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:self action:@selector(importFail)];
            [APP.keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
        }
    }
}
-(void)initSignView{
    if (!signView) {
        signView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        signView.backgroundColor = [UIColor clearColor];
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_H/2, SCREEN_W, SCREEN_H/2)];
        contentView.backgroundColor = [UIColor whiteColor];
        [signView addSubview:contentView];
        
    }
}
-(void)initInportViewController{
    if (!importViewController) {
        importViewController = [[HeroSignatureInportController alloc]init];
    }
}

@end

@implementation HeroSignatureInportController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"导入钱包";
    UILabel *keystoreDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 35, SCREEN_W-40, 66)];
    keystoreDesLabel.text = @"直接复制粘贴以太坊官方钱包keystore文件内容到下面输入框。或者通过扫描二维码方式录入";
    keystoreDesLabel.numberOfLines = 3;
    keystoreDesLabel.textColor = [UIColor lightGrayColor];
    keystoreDesLabel.font  = [UIFont systemFontOfSize:12];
    [self.view addSubview:keystoreDesLabel];
    
    UITextView *keystoreTextView = [[UITextView alloc]initWithFrame:CGRectMake(20, 100, SCREEN_W-40, 150)];
    keystoreTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    keystoreTextView.layer.borderWidth = 0.5f;
    [self.view addSubview:keystoreTextView];
    UITextField *keystorePWField = [[UITextField alloc]initWithFrame:CGRectMake(20, 260, SCREEN_W-40, 44)];
    keystorePWField.placeholder = @"keystore 密码";
    [self.view addSubview:keystorePWField];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20, 304, SCREEN_W-40, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    
    UILabel *policyLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 310, SCREEN_W-40, 40)];
    policyLabel.text = @"我已经仔细阅读并同意以太坊白皮书，理解区块链的核心思想";
    policyLabel.textColor = self.view.tintColor;
    policyLabel.font  = [UIFont systemFontOfSize:12];
    [self.view addSubview:policyLabel];

    UIButton *importBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 350, SCREEN_W-40, 44)];
    [importBtn setTitle:@"开始导入" forState:(UIControlStateNormal)];
    importBtn.backgroundColor = self.view.tintColor;
    importBtn.layer.cornerRadius = 5;
    [self.view addSubview:importBtn];
}

@end
