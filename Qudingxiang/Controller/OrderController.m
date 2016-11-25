//
//  OrderController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "OrderController.h"

#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"
#import "QDXOrderTableViewCell.h"
#import "QDXOrderDetailTableViewController.h"
#import "OrderService.h"
#import "QDXIsConnect.h"

#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"

#import "MCLeftSliderManager.h"

#import "QDXSlideView.h"
#import "QDXSlideCollectionViewCell.h"

@interface OrderController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    int curr;
    int page;
    int count;
    UIButton *_button;
    UIImageView *sad_1;
    UILabel *sadButton_1;
    UIView *loginView;
    
    UIView *_tipView;
    UIScrollView *_sliderScrollView;
    UIScrollView *_contentScrollView;
    
    UIView *allOrdersView;
    UIView *willPayView;
    UIView *didPayView;
    UIView *didCompletedView;
}
@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation OrderController

- (NSMutableArray *)orders
{
    if (_orders == nil) {
        _orders = [NSMutableArray array];
    }
    return _orders;
}

- (void)viewDidAppear:(BOOL)animated
{
    curr = 1;
    [loginView removeFromSuperview];
    [sad_1 removeFromSuperview];
    [sadButton_1 removeFromSuperview];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"订单";
    
    self.view.backgroundColor = QDXBGColor;

    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    [self setupUI];
    
    QDXSlideView *qdxslideView = [[QDXSlideView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - FitRealValue(80)) titleAry:@[@"全部订单",@"待支付",@"已支付",@"已完成"]];
    
    [self.view addSubview:qdxslideView];
}

- (void)setupUI {
    // 滑动条
    _sliderScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(80))];
    _sliderScrollView.showsHorizontalScrollIndicator = NO;
    _sliderScrollView.backgroundColor = [UIColor whiteColor];
    _sliderScrollView.contentSize = CGSizeMake(QdxWidth/4 * 4, FitRealValue(80));
    [self.view addSubview:_sliderScrollView];
    
    // 滑动条上的按钮
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(QdxWidth/4 * i, 0, QdxWidth/4, FitRealValue(80));
        
        switch (i) {
            case 0:
                [button setTitle:@"全部订单" forState:UIControlStateNormal];
                break;
            case 1:
                [button setTitle:@"待支付" forState:UIControlStateNormal];
                break;
            case 2:
                [button setTitle:@"已支付" forState:UIControlStateNormal];
                break;
            case 3:
                [button setTitle:@"已完成" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        
        [button setTitleColor:QDXBlack forState:UIControlStateNormal];
        [button setTitleColor:QDXBlue forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderScrollView addSubview:button];
        button.tag = i + 1;
        
        // 设置起始的选中状态
        if (i == 0) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
        
    }
    
    // 滑动条底部线条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(80) - 0.5, QdxWidth, 0.5)];
    line.backgroundColor = QDXLineColor;
    [self.view addSubview:line];
    
    // 按钮下面的标识条
    _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(80) - 3, QdxWidth/4, 3)];
    _tipView.backgroundColor = QDXBlue;
    [_sliderScrollView addSubview:_tipView];
    
    // 内容视图
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, FitRealValue(80), QdxWidth, QdxHeight - FitRealValue(80))];
    _contentScrollView.contentSize = CGSizeMake(QdxWidth * 4, QdxHeight - FitRealValue(80));
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.backgroundColor = QDXBGColor;
    [self.view addSubview:_contentScrollView];
    
    // 每个页面添加一个view
    for (int i = 0; i < 4; i++) {
        
        switch (i) {
            case 0:
                allOrdersView = [[UIView alloc] initWithFrame:CGRectMake(i * QdxWidth, 0, QdxWidth, QdxHeight - FitRealValue(80))];
                [_contentScrollView addSubview:allOrdersView];
                [self createTableView];
                break;
            case 1:
                willPayView = [[UIView alloc] initWithFrame:CGRectMake(i * QdxWidth, 0, QdxWidth, QdxHeight - FitRealValue(80))];
                [_contentScrollView addSubview:willPayView];
                break;
            case 2:
                didPayView = [[UIView alloc] initWithFrame:CGRectMake(i * QdxWidth, 0, QdxWidth, QdxHeight - FitRealValue(80))];
                [_contentScrollView addSubview:didPayView];
                break;
            case 3:
                didCompletedView = [[UIView alloc] initWithFrame:CGRectMake(i * QdxWidth, 0, QdxWidth, QdxHeight - FitRealValue(80))];
                [_contentScrollView addSubview:didCompletedView];
                break;
            default:
                break;
        }
    }
}

// 按钮点击事件
- (void)btnClick:(UIButton *)btn {
    // 1.将标识条移到选中的按钮下
    [self moveTipview:btn];
    
    // 2.将选中的按钮字体变色
    [self changeBtnColor:btn];
    
    // 3.将选中的按钮移到中间
    [self moveSlider:btn];
    
    // 4.将内容视图调整到对应的页面
    [self moveContentScrollView:btn];
}

- (void)moveSlider:(UIButton *)btn {
    CGPoint contentOffset = _sliderScrollView.contentOffset;
    contentOffset.x += (btn.frame.origin.x + (QdxWidth/4) / 2) - _sliderScrollView.contentOffset.x - QdxWidth / 2;
    
    if (contentOffset.x < 0) {
        contentOffset.x = 0;
    }
    
    if (contentOffset.x + QdxWidth > _sliderScrollView.contentSize.width) {
        contentOffset.x = _sliderScrollView.contentSize.width - QdxWidth;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        _sliderScrollView.contentOffset = contentOffset;
    }];
    
}

- (void)changeBtnColor:(UIButton *)btn {
    for (UIView *view in _sliderScrollView.subviews) {
        for (int i = 1; i <= 4; i++) {
            if (view.tag == i) {
                UIButton *elseBtn = (UIButton *)view;
                btn.selected = YES;
                elseBtn.selected = NO;
            }
        }
    }
    
}

- (void)moveTipview:(UIButton *)btn {
    [UIView animateWithDuration:0.1f animations:^{
        CGRect frame = _tipView.frame;
        frame.origin.x = btn.frame.origin.x;
        _tipView.frame = frame;
    }];
}

- (void)moveContentScrollView:(UIButton *)btn {
    CGPoint contentOffset = _contentScrollView.contentOffset;
    contentOffset.x = (btn.tag - 1) * QdxWidth;
    [UIView animateWithDuration:0.1f animations:^{
        _contentScrollView.contentOffset = contentOffset;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / QdxWidth + 1;
    
    for (UIView *view in _sliderScrollView.subviews) {
        if (view.tag == index) {
            UIButton *button = (UIButton *)view;
            
            // 1.将标识条移到选中的按钮下
            [self moveTipview:button];
            
            // 2.将选中的按钮字体变色
            [self changeBtnColor:button];
            
            // 3.将选中的按钮移到中间
            [self moveSlider:button];
        }
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

- (void) createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight - FitRealValue(80)-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = QDXBGColor;
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [allOrdersView addSubview:self.tableview];

//    [willPayView addSubview:self.tableview];
//
//    [didPayView addSubview:self.tableview];
//
//    [didCompletedView addSubview:self.tableview];
    
    [self setupRefreshView];
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

- (void)loadData
{
    [self performSelectorInBackground:@selector(getOrdersListAjax) withObject:nil];
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableview.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    self.tableview.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self getOrdersListAjax];
    
    // 刷新表格
    [self.tableview reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableview.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [self.tableview reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        
        [self.tableview.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self getOrdersListAjax];
    }
}

-(void)getOrdersListAjax
{
    if(save == nil){
        [self createLoginView];
    }else{
    [OrderService cellDataBlock:^(NSMutableDictionary *dict) {
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1)  {
            if (![dict[@"Msg"][@"count"] isEqualToString:@"0"]){
                // 将字典数据转为模型数据
                curr = [dict[@"Msg"][@"curr"] intValue];
                if(curr ==1){
                    self.orders = [[NSMutableArray alloc] init];
                }
                page = [dict[@"Msg"][@"page"] intValue];
                //将字典转模型
                NSArray *dataDict = dict[@"Msg"][@"data"];
                
                for(NSDictionary *dict in dataDict){
                    [self.orders addObject:[QDXOrdermodel OrderWithDict:dict]];
                }
            }else{
                self.orders = [[NSMutableArray alloc] init];
                [self createSadView];
            }
            [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
        }else{
//            [self createLoginView];
        }
        // 刷新表格
        [self.tableview reloadData];
        [self.tableview.mj_footer endRefreshing];
    } FailBlock:^(NSMutableArray *array) {

    } andWithToken:save andWithCurr:[NSString stringWithFormat:@"%d",curr]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 10)];
    headerView.backgroundColor = QDXBGColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)sussRes
{
    [self hideProgess];
}

- (void)createLoginView
{
    loginView = [[UIView alloc] initWithFrame:self.tableview.frame];
    loginView.backgroundColor = QDXBGColor;
    [self.tableview addSubview:loginView];
    
    UIImageView *sad = [[UIImageView alloc] init];
    CGFloat sadCenterX = QdxWidth * 0.5;
    CGFloat sadCenterY = QdxHeight * 0.22;
    sad.center = CGPointMake(sadCenterX, sadCenterY);
    sad.bounds = CGRectMake(0, 0, 40, 43);
    sad.image = [UIImage imageNamed:@"order_logo"];
    [loginView addSubview:sad];
    
    UIButton *sadButton = [[UIButton alloc] init];
    sadButton.center = CGPointMake(sadCenterX, sadCenterY + 30 + 25);
    sadButton.bounds = CGRectMake(0, 0, 135, 30);
    [sadButton setTitle:@"登录查看订单" forState:UIControlStateNormal];
    [sadButton addTarget:self action:@selector(sign_in) forControlEvents:UIControlEventTouchUpInside];
    [sadButton setTitleColor:QDXBlue forState:UIControlStateNormal];
    sadButton.layer.borderColor = QDXBlue.CGColor;
    sadButton.layer.borderWidth = 0.5;
    sadButton.layer.cornerRadius = 4;
    sadButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [loginView addSubview:sadButton];
}

-(void)sign_in
{
    QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
    QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)createSadView
{
    sad_1 = [[UIImageView alloc] init];
    CGFloat sad_1CenterX = QdxWidth * 0.5;
    CGFloat sad_1CenterY = QdxHeight * 0.22;
    sad_1.center = CGPointMake(sad_1CenterX, sad_1CenterY);
    sad_1.bounds = CGRectMake(0, 0,40,43);
    sad_1.image = [UIImage imageNamed:@"order_nothing"];
    [self.tableview addSubview:sad_1];
    
    sadButton_1 = [[UILabel alloc] init];
    sadButton_1.center = CGPointMake(sad_1CenterX, sad_1CenterY + 43/2 + 20);
    sadButton_1.bounds = CGRectMake(0, 0, 120, 100);
    sadButton_1.text = @"您当前没有订单";
    sadButton_1.font = [UIFont systemFontOfSize:12];
    sadButton_1.textAlignment = NSTextAlignmentCenter;
    sadButton_1.textColor = QDXGray;
    [self.tableview addSubview:sadButton_1];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    QDXOrderInfoModel *OrderInfo = self.orders[0];
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    QDXOrderTableViewCell *cell = [QDXOrderTableViewCell cellWithTableView:tableView];
    // 2.给cell传递模型数据
    cell.order = self.orders[indexPath.row];
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QDXOrderDetailTableViewController *ODetailVC = [[QDXOrderDetailTableViewController alloc] init];
    ODetailVC.hidesBottomBarWhenPushed = YES;
    ODetailVC.Order = self.orders[indexPath.row];
    [self.navigationController pushViewController:ODetailVC animated:YES];
}

@end
