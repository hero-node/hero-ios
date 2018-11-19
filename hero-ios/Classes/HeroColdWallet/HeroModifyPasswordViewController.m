//
//  HeroModifyPasswordViewController.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/18.
//

#import "HeroModifyPasswordViewController.h"
#import "UIView+Addition.h"
#import "UIAlertView+blockDelegate.h"

@interface HeroModifyPasswordViewController ()

@property (nonatomic) HeroAccount *account;

@property (nonatomic) UITextField *currentTextField;
@property (nonatomic) UITextField *passwordTextField;
@property (nonatomic) UITextField *repeatTextField;

@end

@implementation HeroModifyPasswordViewController

- (instancetype)initWithAccount:(HeroAccount *)account {
    if (self = [self init]) {
        self.account = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改密码";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _currentTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, NavigationHeight + 40, SCREEN_W-80, 45)];
    _currentTextField.placeholder = @"当前密码";
    _currentTextField.secureTextEntry = YES;
    _currentTextField.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_currentTextField];
    _currentTextField.borderStyle = UITextBorderStyleNone;
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(0xe2e2e2);
    [self.view addSubview:line1];
    line1.frame = CGRectMake(40, _currentTextField.bottom, _currentTextField.width, 1);
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, _currentTextField.bottom + 6, _currentTextField.width, 45)];
    _passwordTextField.placeholder = @"新密码";
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.font = [UIFont systemFontOfSize:15];
    _passwordTextField.borderStyle = UITextBorderStyleNone;
    [self.view addSubview:_passwordTextField];
    UIView *line2 = [UIView new];
    line2.backgroundColor = line1.backgroundColor;
    [self.view addSubview:line2];
    line2.frame = CGRectMake(40, _passwordTextField.bottom, _passwordTextField.width, 1);
    
    _repeatTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, _passwordTextField.bottom + 6,  _passwordTextField.width, 45)];
    _repeatTextField.placeholder = @"重复密码";
    _repeatTextField.font = [UIFont systemFontOfSize:15];
    _repeatTextField.secureTextEntry = YES;
    _repeatTextField.borderStyle = UITextBorderStyleNone;
    [self.view addSubview:_repeatTextField];
    UIView *line3 = [UIView new];
    line3.backgroundColor = line1.backgroundColor;
    [self.view addSubview:line3];
    line3.frame = CGRectMake(40, _repeatTextField.bottom, _passwordTextField.width, 1);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onDoneTapped)];
    
}

- (void)onDoneTapped {
    if (_currentTextField.text.length > 0 && _passwordTextField.text.length > 0 && _repeatTextField.text.length > 0) {
        if ([self.account.password isEqualToString:_currentTextField.text]) {
            if ([_passwordTextField.text isEqualToString:_repeatTextField.text]) {
                self.account.password = _passwordTextField.text;
                [self.account save];
                [UIAlertView showAlertViewWithTitle:@"" message:@"密码修改成功！" cancelButtonTitle:@"确认" otherButtonTitles:nil onDismiss:nil onCancel:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码输入不一致" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"原密码不正确" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入完整" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}


@end
