//
//  ActivityController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "ActivityController.h"
#import "QDXLineDetailViewController.h"
#import "ActCell.h"
#import "ActModel.h"
#import "HomeModel.h"
#import "ActivityService.h"
#import "QDXNavigationController.h"
#import "QDXLoginViewController.h"
//#import "DTScrollStatusView.h"
#import "MCLeftSliderManager.h"

@interface ActivityController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    NSInteger _curNumber;
    NSInteger _currNum;
    NSInteger _countNum;
    NSString *_goodsId;
    NSString *_status_id;
    UIButton *_button;
}
//@property (strong , nonatomic) DTScrollStatusView *scrollTapViw;
@end

@implementation ActivityController

- (void)viewDidLoad {
    [super viewDidLoad];
    _curNumber = 1;
    self.view.backgroundColor = QDXBGColor;
    self.navigationItem.title = @"活动";
    
//    _scrollTapViw = [[DTScrollStatusView alloc]initWithTitleArr:@[@"进行中",@"已完成"] andType:ScrollTapTypeWithNavigation];
//    _scrollTapViw.scrollStatusDelegate = self;
//    [self.view addSubview:_scrollTapViw];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    [self createTableView];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void) openOrCloseLeftList
{
    
    if ([MCLeftSliderManager sharedInstance].LeftSlideVC.closed)
    {
        [[MCLeftSliderManager sharedInstance].LeftSlideVC openLeftView];
    }
    else
    {
        [[MCLeftSliderManager sharedInstance].LeftSlideVC closeLeftView];
    }
}

- (void)loadData
{
    [self performSelectorInBackground:@selector(loadDataWith:isRemoveAll:) withObject:nil];
}

- (void)createTableView
{
    _dataArr = [NSMutableArray arrayWithCapacity:0];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-60)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = QDXBGColor;
    [self.view addSubview:_tableView];
    [self loadDataWith:@"1" isRemoveAll:NO];
    [self refreshView];
}

- (void)setClick
{
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }else{
//        [self.sideMenuViewController presentLeftMenuViewController];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if(buttonIndex == 1){
        
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        regi.hidesBottomBarWhenPushed = YES;
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
    }
}

- (void)refreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [_tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
//    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
//    // 忽略掉底部inset
//    _tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;

}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    _curNumber = 1;
    //刷新
    [self loadDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:YES];
    // 刷新表格
    [_tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    _curNumber ++;
    if(_countNum/20+1 == _currNum){
        // 刷新表格
        [_tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [_tableView.mj_footer endRefreshingWithNoMoreData];
       
    }else{
        [self loadDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:NO];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)loadDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll
{
    [self showProgessMsg:@"正在加载"];
    [ActivityService cellDataBlock:^(NSDictionary *dict) {
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        _currNum = [dict[@"Msg"][@"curr"] integerValue];
        _countNum = [dict[@"Msg"][@"count"] integerValue];
        if (isRemoveAll) {
            [_dataArr removeAllObjects];
        }
        for(NSDictionary *dict in dataDict){
            ActModel *model = [[ActModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            _goodsId = model.goods_id;
            _status_id = model.good_st;
            [_dataArr addObject:model];
        }
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshing];
        [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
    } FailBlock:^(NSMutableArray *array) {
        
    } andWithToken:save andWithCurr:cur];
}

- (void)sussRes
{
    [self hideProgess];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActCell *cell = [ActCell actCellWithTableView:_tableView];
    cell.model = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    ActModel *md = (ActModel*)_dataArr[indexPath.row];
    HomeModel *homeModel = [[HomeModel alloc] init];
    homeModel.goods_id = md.goods_id;
    homeModel.goods_price = md.goods_price;
    homeModel.good_st = md.good_st;
    homeModel.goods_name = md.goods_name;
    homeModel.line = md.line;
    lineVC.homeModel = homeModel;
    lineVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:lineVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QdxWidth*0.59+32+10;
}
@end
