//
//  HeroExportKeystoreViewController.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/18.
//

#import "HeroExportKeystoreViewController.h"
#import "UIView+Addition.h"
#import "UIImage+color.h"
#import "HeroQRCoder.h"

@interface HeroExportKeystoreViewController ()

@property (nonatomic) HeroAccount *account;

@property (nonatomic) UIButton *currentBtn;
@property (nonatomic) UIButton *fileBtn;
@property (nonatomic) UIButton *qrcodeBtn;

@property (nonatomic) UIView *boldLine;

@property (nonatomic) UIView *fileView;
@property (nonatomic) UIView *qrView;

@property (nonatomic) UITextView *textView;

@property (nonatomic) UIActivityIndicatorView *loading;

@end

@implementation HeroExportKeystoreViewController

- (instancetype)initWithAccount:(HeroAccount *)account {
    if (self = [self init]) {
        self.account = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"导出Keystore";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.loading];
    self.loading.center = self.view.center;
    [self.loading startAnimating];
    
    UIView *top = [UIView new];
    top.frame = CGRectMake(0, NavigationHeight, SCREEN_W, 50);
    [self.view addSubview:top];
    
    _fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fileBtn setTitle:@"Keystore 文件" forState:UIControlStateNormal];
    [_fileBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [_fileBtn setTitleColor:UIColorFromRGB(0x39adf9) forState:UIControlStateSelected];
    _fileBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_fileBtn addTarget:self action:@selector(onKeystoreFileTapped) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:_fileBtn];
    _fileBtn.frame = CGRectMake(0, 0, SCREEN_W/2, top.height);
    _currentBtn = _fileBtn;
    
    _qrcodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _qrcodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_qrcodeBtn setTitle:@"二维码" forState:UIControlStateNormal];
    [_qrcodeBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [_qrcodeBtn setTitleColor:UIColorFromRGB(0x39adf9) forState:UIControlStateSelected];
    [_qrcodeBtn addTarget:self action:@selector(onQRCodeTapped) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:_qrcodeBtn];
    _qrcodeBtn.frame = CGRectMake(SCREEN_W/2, 0, SCREEN_W/2, top.height);
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xe2e2e2);
    [top addSubview:line];
    line.frame = CGRectMake(0, top.height-1, SCREEN_W, 1);
    
    _boldLine = [UIView new];
    _boldLine.backgroundColor = UIColorFromRGB(0x39adf9);
    [top addSubview:_boldLine];
    _boldLine.frame = CGRectMake(0, top.height-3, SCREEN_W/2, 3);
    
    _fileView = [UIView new];
    _fileView.frame = CGRectMake(0, top.bottom, SCREEN_W, SCREEN_H-top.bottom);
    [self.view addSubview:_fileView];
    
    UILabel *key1 = [UILabel new];
    key1.text = @"离线保存";
    key1.font = [UIFont systemFontOfSize:16];
    key1.textColor = UIColorFromRGB(0x39adf9);
    key1.frame = CGRectMake(40, 25, 200, 23);
    [_fileView addSubview:key1];
    
    UILabel *value1 = [UILabel new];
    value1.text = @"请复制黏贴 Keystore 文件导安全、离线的地方保存。切勿保存至邮箱、记事本、网盘、聊天工具等，非常危险。";
    value1.numberOfLines = 0;
    value1.font = [UIFont systemFontOfSize:15];
    value1.textColor = UIColorFromRGB(0x999999);
    value1.frame = CGRectMake(key1.left, key1.bottom + 4, SCREEN_W-80, 0);
    [value1 sizeToFit];
    [_fileView addSubview:value1];
    
    UILabel *key2 = [UILabel new];
    key2.text = @"请勿使用网络传输";
    key2.textColor = UIColorFromRGB(0x39adf9);
    key2.font = [UIFont systemFontOfSize:16];
    key2.frame = CGRectMake(value1.left, value1.bottom + 25, 300, 23);
    [_fileView addSubview:key2];
    
    UILabel *value2 = [UILabel new];
    value2.text = @"请勿通过网络工具传输 Keystore 文件，一旦被黑客获取将造成不可挽回的资产损失。建议离线设备通过扫描二维码的方式传输。";
    value2.numberOfLines = 0;
    value2.font = [UIFont systemFontOfSize:15];
    value2.textColor = UIColorFromRGB(0x999999);
    value2.frame = CGRectMake(key2.left, key2.bottom + 4, SCREEN_W-80, 0);
    [value2 sizeToFit];
    [_fileView addSubview:value2];
    
    UILabel *key3 = [UILabel new];
    key3.text = @"密码保险箱保存";
    key3.textColor = UIColorFromRGB(0x39adf9);
    key3.font = [UIFont systemFontOfSize:16];
    key3.frame = CGRectMake(value1.left, value2.bottom + 25, 300, 23);
    [_fileView addSubview:key3];
    
    UILabel *value3 = [UILabel new];
    value3.text = @"如需在线保存，则建议使用安全等级更高的 1Password 等";
    value3.numberOfLines = 0;
    value3.font = [UIFont systemFontOfSize:15];
    value3.textColor = UIColorFromRGB(0x999999);
    value3.frame = CGRectMake(key3.left, key3.bottom + 4, SCREEN_W-80, 0);
    [value3 sizeToFit];
    [_fileView addSubview:value3];
    
    _textView = [[UITextView alloc] init];
    _textView.frame = CGRectMake(40, value3.bottom + 25, SCREEN_W - 80, 184);
    _textView.backgroundColor = UIColorFromRGB(0xfafafa);
    _textView.layer.borderColor = UIColorFromRGB(0xcecece).CGColor;
    _textView.layer.borderWidth = 1;
    _textView.editable = NO;
    _textView.textColor = UIColorFromRGB(0x666666);
    __weak HeroExportKeystoreViewController *weakSelf = self;
    [_fileView addSubview:_textView];
    [self.account.ethAccount encryptSecretStorageJSON:self.account.password callback:^(NSString *json) {
        [weakSelf.loading stopAnimating];
        weakSelf.textView.text = json;
    }];
    
    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyButton addTarget:self action:@selector(onCopyTapped) forControlEvents:UIControlEventTouchUpInside];
    [copyButton setTitle:@"复制 Keystore" forState:UIControlStateNormal];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton setBackgroundImage:[UIImage fromColor:UIColorFromRGB(0x39adf9)] forState:UIControlStateNormal];
    copyButton.frame = CGRectMake(40, _textView.bottom+30, SCREEN_W-80, 50);
    [_fileView addSubview:copyButton];
    
    
    _qrView = [UIView new];
    _qrView.frame = CGRectMake(0, top.bottom, SCREEN_W, SCREEN_H-top.bottom);
    
    UILabel *qrKey1 = [UILabel new];
    qrKey1.text = @"仅供直接扫描";
    qrKey1.textColor = UIColorFromRGB(0x39adf9);
    qrKey1.font = [UIFont systemFontOfSize:16];
    [_qrView addSubview:qrKey1];
    qrKey1.frame = CGRectMake(40, 25, 200, 23);
    
    UILabel *qrValue1 = [UILabel new];
    qrValue1.text = @"二维码禁止保存、截图、以及拍照。仅供用户在安全环境下直接扫描来方便的导入钱包。";
    qrValue1.textColor = UIColorFromRGB(0x999999);
    qrValue1.numberOfLines = 0;
    qrValue1.font = [UIFont systemFontOfSize:15];
    qrValue1.left = qrKey1.left;
    qrValue1.top = qrKey1.bottom + 4;
    qrValue1.width = SCREEN_W-80;
    [qrValue1 sizeToFit];
    [_qrView addSubview:qrValue1];
    
    UILabel *qrKey2 = [UILabel new];
    qrKey2.text = @"在安全环境下使用";
    qrKey2.textColor = UIColorFromRGB(0x39adf9);
    qrKey2.font = [UIFont systemFontOfSize:16];
    [_qrView addSubview:qrKey2];
    qrKey2.frame = CGRectMake(40, qrValue1.bottom+25, 200, 23);
    
    UILabel *qrValue2 = [UILabel new];
    qrValue2.text = @"请在确保四周无人及无摄像头的情况下使用。二维码一旦泄漏被他人获取将造成不可挽回的资产损失。";
    qrValue2.textColor = UIColorFromRGB(0x999999);
    qrValue2.numberOfLines = 0;
    qrValue2.font = [UIFont systemFontOfSize:15];
    qrValue2.left = qrKey2.left;
    qrValue2.top = qrKey2.bottom + 4;
    qrValue2.width = SCREEN_W-80;
    [qrValue2 sizeToFit];
    [_qrView addSubview:qrValue2];
    
    UIView *contentView = [UIView new];
    contentView.layer.borderColor = UIColorFromRGB(0xe2e2e2).CGColor;
    contentView.layer.borderWidth = 1;
    contentView.top = qrValue2.bottom + 60;
    contentView.size = CGSizeMake(280, 280);
    contentView.left = SCREEN_W/2-contentView.width/2;
     [_qrView addSubview:contentView];
    UIImageView *qrImageView = [[UIImageView alloc] initWithImage:nil];
    [contentView addSubview:qrImageView];
    qrImageView.top = 16;
    qrImageView.left = 16;
    qrImageView.width = contentView.width-32;
    qrImageView.height = contentView.height-32;
    [self.account.ethAccount encryptSecretStorageJSON:self.account.password callback:^(NSString *json) {
        qrImageView.image = [HeroQRCoder createQRImageString:json sizeWidth:300 fillColor:nil];
    }];
}

- (void)onCopyTapped {
    [[UIPasteboard generalPasteboard] setString:self.textView.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"已复制到剪贴板" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)onKeystoreFileTapped {
    if (self.currentBtn != self.fileBtn) {
        self.currentBtn.selected = NO;
        self.currentBtn = self.fileBtn;
        self.currentBtn.selected = YES;
        [UIView animateWithDuration:.3 animations:^{
            self.boldLine.left = 0;
        }];
        [self.qrView removeFromSuperview];
        [self.view addSubview:self.fileView];
    }
}

- (void)onQRCodeTapped {
    if (self.currentBtn != self.qrcodeBtn) {
        self.currentBtn.selected = NO;
        self.currentBtn = self.qrcodeBtn;
        self.currentBtn.selected = YES;
        [UIView animateWithDuration:.3 animations:^{
            self.boldLine.left = SCREEN_W/2;
        }];
        [self.fileView removeFromSuperview];
        [self.view addSubview:self.qrView];
    }
}

@end
