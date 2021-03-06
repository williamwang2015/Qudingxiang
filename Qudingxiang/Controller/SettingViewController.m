//
//  SettingViewController.m
//  趣定向
//
//  Created by Prince on 16/3/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "SettingViewController.h"
#import "QDXLoginViewController.h"
#import "QDXChangePwdViewController.h"
#import "QDXNavigationController.h"
//#import "TabbarController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    UILabel *_valueDataLabel;
    CGFloat _dataValue;
    CGFloat _folderSize;
}
@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _dataValue = [self folderSizeWithPath:[self getPath]];
    _valueDataLabel.text = [NSString stringWithFormat:@"%.2fMB",_dataValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置";
    [self createTableView];
}


- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    //_tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = QDXBGColor;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
}

-(void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 2;
    }else{
        return 1;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(30), FitRealValue(30), QdxWidth/2, 21)];;
                nameLabel.text = @"清除图片缓存";
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.font = [UIFont systemFontOfSize:15];
                nameLabel.textColor = QDXBlack;
                [cell addSubview:nameLabel];
                _valueDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth*2/3, FitRealValue(30), QdxWidth/3-10, 21)];
                
                _valueDataLabel.text = [NSString stringWithFormat:@"%.2fMB",_dataValue];
                _valueDataLabel.font = [UIFont systemFontOfSize:14];
                _valueDataLabel.textColor = QDXGray;
                _valueDataLabel.textAlignment = NSTextAlignmentRight;
                [cell addSubview:_valueDataLabel];
            }else{
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(30), FitRealValue(30), QdxWidth, 21)];;
                nameLabel.text = @"修改密码";
                nameLabel.font = [UIFont systemFontOfSize:15];
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.textColor = QDXBlack;
                [cell addSubview:nameLabel];
            }
        }else if(indexPath.section == 1){
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, FitRealValue(30), QdxWidth, 21)];;
            nameLabel.text = @"退出当前账号";
            nameLabel.font = [UIFont systemFontOfSize:15];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = QDXBlue;
            [cell addSubview:nameLabel];
        }
        
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            [self deleteFileSize:[self folderSizeWithPath:[self getPath]]];
        }else{
            QDXChangePwdViewController *changePassWord = [[QDXChangePwdViewController alloc] init];
            [self.navigationController pushViewController:changePassWord animated:YES];
        }
    }else if(indexPath.section == 1){

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"退出后不会删除任何历史数据,下次登录依然可以使用本账号" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            
            NSFileManager * fileManager = [[NSFileManager alloc]init];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [fileManager removeItemAtPath:documentDir error:nil];
            
            QDXLoginViewController *login = [[QDXLoginViewController alloc] init];
            [self.navigationController pushViewController:login animated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(100);
}

//首先获取缓存文件的路径
-(NSString *)getPath{
    //沙盒目录下library文件夹下的cache文件夹就是缓存文件夹
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return path;
}

//-(NSString *)gettempPath{
//    NSString * path = NSTemporaryDirectory();
//    return path;
//}

-(CGFloat)folderSizeWithPath:(NSString *)path{
    //初始化文件管理类
    NSFileManager * fileManager = [NSFileManager defaultManager];float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]){
        //如果存在
        //计算文件的大小
        NSArray * fileArray = [fileManager subpathsAtPath:path];
        for (NSString * fileName in fileArray){
            //获取每个文件的路径
            NSString * filePath = [path stringByAppendingPathComponent:fileName];
            //计算每个子文件的大小
            long fileSize = [fileManager attributesOfItemAtPath:filePath error:nil].fileSize;
            //字节数
            folderSize = folderSize + fileSize / 1024.0 / 1024.0;
        }
        //删除缓存文件
        //        [self deleteFileSize:folderSize];
        return folderSize;
    }
    return 0;
}

-(void)deleteFileSize:(CGFloat)folderSize{
    if (folderSize > 0.01){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"缓存大小:%.2fM,是否清除？",folderSize] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            
            //彻底删除文件
            [self clearCacheWith:[self getPath]];
            _valueDataLabel.text = [NSString stringWithFormat:@"%.2fMB",[self folderSizeWithPath:[self getPath]]];
            //        NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            //        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
            //        for (NSString *fileName in enumerator) {
            //            [[NSFileManager defaultManager] removeItemAtPath:[DocumentsPath stringByAppendingPathComponent:fileName] error:nil];
            //        }
            //        [self dismissViewControllerAnimated:YES completion:^{
            //            
            //        }];
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"缓存已全部清理" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)clearCacheWith:(NSString *)path{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        NSArray * fileArray = [fileManager subpathsAtPath:path];
        for (NSString * fileName in fileArray){
            //可以过滤掉特殊格式的文件
            if ([fileName hasSuffix:@".png"]){
//                NSLog(@"不删除");
            }
            else{
                //获取每个子文件的路径
                NSString * filePath = [path stringByAppendingPathComponent:fileName];
                //移除指定路径下的文件
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
