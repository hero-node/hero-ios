//
//  HeroWalletListViewController.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/14.
//

#import "HeroWalletListViewController.h"
#import "UIView+Hero.h"
#import "UIImage+color.h"
#import "HeroWallet.h"
#import "WalletListCell.h"
#import "HeroWalletDetailViewController.h"
#import "HeroImportWalletViewController.h"

@interface HeroWalletListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@end

@implementation HeroWalletListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的钱包";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H-90) style:UITableViewStylePlain];
    _tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    
    UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importButton.frame = CGRectMake(25, SCREEN_H-30-50, SCREEN_W-2*25, 50);
    [importButton setTitle:@"导入钱包" forState:UIControlStateNormal];
    [importButton setBackgroundImage:[UIImage fromColor:UIColorFromRGB(0x39adf9)] forState:UIControlStateNormal];
    importButton.clipsToBounds = YES;
    importButton.layer.cornerRadius = 4;
    [importButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:importButton];
    [importButton addTarget:self action:@selector(onImportTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x39adf9);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)onImportTapped {
    HeroImportWalletViewController *import = [[HeroImportWalletViewController alloc] init];
    [self.navigationController pushViewController:import animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HeroWallet sharedInstance].accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WalletListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletList"];
    if (!cell) {
        cell = [[WalletListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WalletList"];
    }
    
    [cell setAccount:[HeroWallet sharedInstance].accounts[indexPath.row]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HeroAccount *acc = [HeroWallet sharedInstance].accounts[indexPath.row];
    HeroWalletDetailViewController *detail = [[HeroWalletDetailViewController alloc] initWithAccount:acc];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)exitWallet {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
