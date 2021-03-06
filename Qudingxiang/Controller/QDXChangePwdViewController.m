//
//  QDXChangePwdViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXChangePwdViewController.h"
//#import "TabbarController.h"
#import "Customer.h"
#import "CheckDataTool.h"

@interface QDXChangePwdViewController ()<UITextFieldDelegate>
{

    UITextField *pwdText;
    UITextField *pwdsureText;
    UIButton *showPW;
    UIButton *showPWSure;
}
@end

@implementation QDXChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupChangePwd];

    self.navigationItem.title = @"修改密码";
}

-(void)setupChangePwd
{
    //4 添加一个密码输入框
    pwdText = [[UITextField alloc]init];
    CGFloat pwdTextCenterX = QdxWidth * 0.5;
    CGFloat pwdTextCenterY = 10 + 40/2;
    pwdText.center = CGPointMake(pwdTextCenterX, pwdTextCenterY);
    pwdText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    pwdText.borderStyle = UITextBorderStyleNone;
    pwdText.placeholder = @"请输入密码";
    pwdText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    pwdText.textColor = QDXGray;
    pwdText.clearButtonMode = UITextFieldViewModeNever;
    pwdText.keyboardType = UIKeyboardTypeDefault;
    pwdText.secureTextEntry = YES;
    pwdText.tag = 2;
    pwdText.backgroundColor = [UIColor whiteColor];
    pwdText.delegate = self;
    [self.view addSubview:pwdText];
    UIView *pwdLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdTextCenterY - 40/2, 20/2, 40)];
    pwdLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdLeftView];
    UIView *pwdRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, pwdTextCenterY - 40/2, 20/2, 40)];
    pwdRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdRightView];
    UIView *pwdTextView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdTextCenterY+25, QdxWidth, 1)];
    pwdTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:pwdTextView];
    showPW = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-20), pwdTextCenterY - 12/2, 20, 12)];
    [showPW setBackgroundImage:[UIImage imageNamed:@"sign_hide"] forState:UIControlStateNormal];
    [showPW addTarget:self action:@selector(hide_show:) forControlEvents:UIControlEventTouchUpInside];
    showPW.selected = NO;
    [self.view addSubview:showPW];
    
    //添加一个label
//    UILabel *info = [[UILabel alloc] init];
//    CGFloat infoCenterX = QdxWidth * 0.4;
//    CGFloat infoCenterY = QdxHeight * 0.25;
//    info.center = CGPointMake(infoCenterX, infoCenterY);
//    info.bounds = CGRectMake(0, 0, 240, 20);
//    info.text = @"密码由6-20位英文字母，数字或符号组成";
//    info.textColor = [UIColor grayColor];
//    info.font = [UIFont fontWithName:@"Arial" size:13];
//    [bkImg addSubview:info];
    
    //4 添加一个确认密码输入框
    pwdsureText = [[UITextField alloc]init];
    CGFloat pwdsureTextCenterX = pwdTextCenterX;
    CGFloat pwdsureTextCenterY = pwdTextCenterY + 20 + 20 + 1;
    pwdsureText.center = CGPointMake(pwdsureTextCenterX, pwdsureTextCenterY);
    pwdsureText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    pwdsureText.borderStyle = UITextBorderStyleNone;
    pwdsureText.placeholder = @"请确认密码";
    pwdsureText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    pwdsureText.textColor = QDXGray;
    pwdsureText.clearButtonMode = UITextFieldViewModeNever;
    pwdsureText.keyboardType = UIKeyboardTypeDefault;
    pwdsureText.secureTextEntry = YES;
    pwdsureText.backgroundColor = [UIColor whiteColor];
    pwdsureText.tag = 3;
    pwdsureText.delegate = self;
    [self.view addSubview: pwdsureText];
    UIView *pwdsureLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdsureTextCenterY - 40/2, 20/2, 40)];
    pwdsureLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdsureLeftView];
    UIView *pwdsureRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, pwdsureTextCenterY - 40/2, 20/2, 40)];
    pwdsureRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdsureRightView];
    UIView *pwdsureTextView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdsureTextCenterY+20, QdxWidth, 1)];
    pwdsureTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:pwdsureTextView];
    showPWSure = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-20), pwdsureTextCenterY - 12/2, 20, 12)];
    [showPWSure setBackgroundImage:[UIImage imageNamed:@"sign_hide"] forState:UIControlStateNormal];
    [showPWSure addTarget:self action:@selector(hide_show_two:) forControlEvents:UIControlEventTouchUpInside];
    showPWSure.selected = NO;
    [self.view addSubview:showPWSure];
    
    //6 添加提交按钮
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"完成" forState:UIControlStateNormal];
    CGFloat loginBtnCenterX = QdxWidth* 0.5;
    CGFloat loginBtnCenterY = pwdsureTextCenterY + 20 + 1 + 35/2 + 25;
    loginBtn.center = CGPointMake(loginBtnCenterX, loginBtnCenterY);
    loginBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:QDXGray forState:UIControlStateHighlighted];
    //    [loginBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:132/255.0 blue:250/255.0 alpha:1]];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}

-(void)hide_show:(UIButton *)show
{
    showPW.selected = !showPW.isSelected;
    if (showPW.isSelected) {
        pwdText.secureTextEntry = NO;
    }else{
        pwdText.secureTextEntry = YES;
    }
}

-(void)hide_show_two:(UIButton *)show
{
    showPWSure.selected = !showPWSure.isSelected;
    if (showPWSure.isSelected) {
        pwdsureText.secureTextEntry = NO;
    }else{
        pwdsureText.secureTextEntry = YES;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)commitBtnClick
{
    [self.view endEditing:YES];
    
    NSString *password = pwdText.text;
    NSString *passwordsure = pwdsureText.text;
    
    if (![password isEqualToString:passwordsure]) {
        [MBProgressHUD showError:@"密码不一致"];
        return;
    }else if(![CheckDataTool checkForPasswordWithShortest:6 longest:16 password:pwdText.text]){
        [MBProgressHUD showError:@"密码在6到16位之间"];
        return;
    }
    
    NSString *url = [newHostUrl stringByAppendingString:modifyUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"customer_pwd"] = [NSString stringWithFormat:@"%@", password];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        int ret = [responseObject[@"Code"] intValue];
        if (ret==1) {
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
            Customer *customer = [[Customer alloc] initWithDic:responseObject[@"Msg"]];
            [NSKeyedArchiver archiveRootObject:customer.customer_token toFile:XWLAccountFile];
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
