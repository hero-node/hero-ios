//
//  HeroWalletDerailViewController.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/15.
//

#import "HeroWalletDetailViewController.h"
#import "UIView+hero.h"
#import "UIImage+color.h"
#import "HeroWallet.h"
#import "UIAlertView+blockDelegate.h"

@interface HeroWalletDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) HeroAccount *account;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) UIView *exportPrivateView;

@end

@implementation HeroWalletDetailViewController

- (instancetype)initWithAccount:(HeroAccount *)account {
    if (self = [self init]) {
        self.account = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.account.name;
    self.view.backgroundColor = [UIColor whiteColor];
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"hero-ios" withExtension:@"bundle"]];
    UIImage *logo = [UIImage imageNamed:@"avatar" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
    logoView.clipsToBounds = YES;
    logoView.layer.cornerRadius = 45;
    logoView.frame = CGRectMake(SCREEN_W/2-45, 109 + (isIPhoneXSeries() ? 24 : 0), 90, 90);
    [self.view addSubview:logoView];
    
    UILabel *addressLabel = [UILabel new];
    addressLabel.text = self.account.address;
    addressLabel.textColor = UIColorFromRGB(0x999999);
    addressLabel.font = [UIFont systemFontOfSize:14];
    addressLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.view addSubview:addressLabel];
    addressLabel.frame = CGRectMake(30, 229 + (isIPhoneXSeries() ? 24 : 0), SCREEN_W-60, 20);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 334 + (isIPhoneXSeries() ? 24 : 0), SCREEN_W, 150) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.rowHeight = 50;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setTitle:@"删除钱包" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage fromColor:UIColorFromRGB(0x39adf9)] forState:UIControlStateNormal];
    deleteBtn.clipsToBounds = YES;
    deleteBtn.layer.cornerRadius = 4;
    [self.view addSubview:deleteBtn];
    deleteBtn.frame = CGRectMake(25, SCREEN_H-30-50, SCREEN_W-2*25, 50);
    [deleteBtn addTarget:self action:@selector(onDeleteTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onDeleteTapped {
    [UIAlertView showAlertViewWithTitle:@"" message:@"是否删除钱包" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] onDismiss:^(NSInteger buttonIndex) {
        __weak HeroWalletDetailViewController *weakSelf = self;
        [[[HeroWallet sharedInstance] defaultAccount] validatePasswordThen:^{
            [[HeroWallet sharedInstance] removeAccount:self.account];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    } onCancel:^{
        
    }];
}

- (void)onExportPrivateTapped {
    UIView *exportPrivateView = [UIView new];
    _exportPrivateView = exportPrivateView;
    exportPrivateView.frame = self.view.bounds;
    
    UIView *contentView = [UIView new];
    [exportPrivateView addSubview:contentView];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.frame = CGRectMake(0, SCREEN_H-386, SCREEN_W, 386);
    
    UILabel *titleLbl = [UILabel new];
    titleLbl.text = @"导出私钥";
    titleLbl.textColor = UIColorFromRGB(0x333333);
    titleLbl.font = [UIFont systemFontOfSize:16];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.frame = CGRectMake(SCREEN_W/2-50, 30, 100, 25);
    [contentView addSubview:titleLbl];
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xdfdfdf);
    [contentView addSubview:line];
    line.frame = CGRectMake(25, 65, SCREEN_W-50, 1);
    
    UILabel *warnLbl = [UILabel new];
    warnLbl.text = @"安全警告：私钥未经加密，导出存在风险，建议使用助记词和 Keystore 进行备份。";
    warnLbl.textColor = UIColorFromRGB(0x9d2929);
    warnLbl.numberOfLines = 2;
    warnLbl.font = [UIFont systemFontOfSize:14];
    [contentView addSubview:warnLbl];
    warnLbl.frame = CGRectMake(40, 100, SCREEN_W-80, 40);
    
    UITextView *txView = [UITextView new];
    txView.editable = NO;
    txView.scrollEnabled = NO;
    txView.backgroundColor = UIColorFromRGB(0xf3f3f3);
    txView.textColor = UIColorFromRGB(0x333333);
    txView.font = [UIFont systemFontOfSize:14];
    txView.contentInset = UIEdgeInsetsMake(30, 15, 15, 15);
    [contentView addSubview:txView];
    txView.frame = CGRectMake(40, 160, SCREEN_W-80, 75);
    txView.text = self.account.privateString;
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyBtn setTitle:@"复制私钥" forState:UIControlStateNormal];
    [copyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyBtn setBackgroundImage:[UIImage fromColor:UIColorFromRGB(0x39adf9)] forState:UIControlStateNormal];
    copyBtn.clipsToBounds = YES;
    copyBtn.layer.cornerRadius = 4;
    [copyBtn addTarget:self action:@selector(onCopyPrivateTapped) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:copyBtn];
    copyBtn.frame = CGRectMake(40, 260, SCREEN_W-80, 50);
    
    UIView *top = [UIView new];
    top.backgroundColor = UIColorFromRGBA(0x605f5f, 0.5);
    [exportPrivateView addSubview:top];
    top.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H - contentView.frame.size.height);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissExportPrivate)];
    [top addGestureRecognizer:tap];
    
    [self.view addSubview:exportPrivateView];
}

- (void)dismissExportPrivate {
    [self.exportPrivateView removeFromSuperview];
    self.exportPrivateView = nil;
}

- (void)onCopyPrivateTapped {
    [[UIPasteboard generalPasteboard] setString:[self.account privateString]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"私钥已拷贝到剪贴板" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSString *title;
    if (indexPath.row == 0) {
        title = @"修改密码";
    }
    if (indexPath.row == 1) {
        title = @"导出私钥";
    }
    if (indexPath.row == 2) {
        title = @"导出Keystore";
    }
    cell.textLabel.text = title;
    cell.textLabel.textColor = UIColorFromRGB(0x999999);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // 修改密码
    } else if (indexPath.row == 1) {
        // 导出私钥
        [self onExportPrivateTapped];
    } else if (indexPath.row == 2) {
        // 导出Keystore
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

@end
