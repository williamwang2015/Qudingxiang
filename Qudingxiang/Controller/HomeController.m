//
//  HomeController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/15.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "HomeController.h"
#import "QDXGameViewController.h"
#import "CellLineController.h"
#import "LineController.h"
#import "HomeModel.h"
#import "ImageModel.h"
#import "BaseCell.h"
#import "QDXProtocolViewController.h"
#import "QDXLineDetailViewController.h"
#import "HomeService.h"
#import "ImagePickerController.h"
//#import "QDXOffLineController.h"
#import "MineViewController.h"
#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"
#import "ImageScrollView.h"
#import "ActivityController.h"
#import "AppDelegate.h"
#import "BaseService.h"
#define NotificaitonChange @"code"

@interface HomeController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,MJRefreshBaseViewDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIImageView *_scrollImageView;
    UIImageView *_imageView;
    UIImageView *_topImageView;
    UIButton *_leftButton;
    UIButton *_rightButton;
    //NSMutableArray *_scrollArr;
    NSMutableArray *_dataArr;
    NSString *_result;
    NSInteger _currentIndex;
    NSTimer *_myTimer;
    NSArray *_topImage;
    NSMutableArray *_modelArr;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    NSInteger _curNumber;
    NSInteger _countNum;
    NSInteger _currNum;
    UIButton *_button;
    BOOL _isLog;
    NSInteger _line;
    NSInteger _code;
    NSString *_msg;
    NSString *_codeMsg;
    UIButton *_scanBtn;
    ImageScrollView *imgScrollView;
    NSMutableArray *arr;
    UIImageView *_promptView;
    UIButton *_leftBtn;
    UIButton *_rightBtn;
    AppDelegate *appdelegate;
    HomeService *homehttp;
}
@end

@implementation HomeController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
     appdelegate = [[UIApplication sharedApplication] delegate];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _scrollArr = [NSMutableArray arrayWithCapacity:0];
    [imgScrollView stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    homehttp = [HomeService sharedInstance];
    _modelArr  = [NSMutableArray arrayWithCapacity:0];
    arr = [[NSMutableArray alloc] initWithCapacity:0];
    self.navigationItem.title = @"趣定向";
    _curNumber = 1;
    [self createTableView];
    [self loadDataCell];
    [self createUI];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
    //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
    //        NSLog(@"第一次启动");
    //    }else{
    //        NSLog(@"不是第一次启动");
    //    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateRefresh) name:@"stateRefresh" object:nil];
//    BaseService *httpRequest = [BaseService sharedInstance];
//    NSString *url = [hostUrl stringByAppendingString:@"Home/util/Dbversion"];
//    [httpRequest POST:url dict:nil succeed:^(id data) {
//        NSLog(@"%@",data[@"goods"]);
//    } failure:^(NSError *error) {
//        
//    }];
}

- (void)stateRefresh
{
    [self state];
    [self loadData];
}

- (void)loadDataCell
{
    _scrollArr = [NSMutableArray arrayWithCapacity:0];
    dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self dbversion];
    });
    dispatch_barrier_async(queue, ^{
        [self cell1];
        [self topViewData];
    });
    

}

- (void)cell1
{
   [self cellDataWith:@"1" isRemoveAll:YES andWithType:@"0"];
}

- (void)loadData
{
    
    if (save) {
        [self state];
        //[self performSelectorInBackground:@selector(state) withObject:nil];
    }else{
        _scanBtn.hidden = NO;
        [self state1];
        
    }
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-72) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = false;
    [self.view addSubview:_tableView];
    [self refreshView];
    
}

- (void)createUI
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59+QdxWidth/5)];
    CGFloat viewMaxY = CGRectGetMaxY(view.frame);
    [view setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    UIView *viewFoot = [[UIView alloc] initWithFrame:CGRectMake(0, viewMaxY, QdxWidth,30)];
    viewFoot.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    [view addSubview:viewFoot];
    view.frame = CGRectMake(0, 0, QdxWidth, viewMaxY+30);
    
    _tableView.tableHeaderView = view;
    //    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59)];
    //    _scrollView.showsHorizontalScrollIndicator = NO;
    //    _scrollView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
    //    _scrollView.pagingEnabled = YES;
    //    _scrollView.userInteractionEnabled = YES;
    //    _scrollView.delegate = self;
    //    _scrollView.contentSize = CGSizeMake(4*QdxWidth, 0);
    //    _scrollView.showsVerticalScrollIndicator = NO;
    //    _scrollView.bounces = YES;
    //    _scrollView.scrollEnabled = YES;
    //    [view addSubview:_scrollView];
    //    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, QdxWidth*0.59-20, QdxWidth, 10)];
    //    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    //    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
    //    _pageControl.numberOfPages = 4;
    //    _pageControl.currentPage = 0;
    //    [view addSubview:_pageControl];
    
    //创建
    imgScrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59)];
    [view addSubview:imgScrollView];
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, QdxWidth*0.59-QdxWidth*0.1, QdxWidth, QdxWidth*0.1)];
    mask.image = [UIImage imageNamed:@"index_mask"];
    [imgScrollView addSubview:mask];
    
    [self createButtonWithView:view];
    [self.view addSubview:_tableView];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_button setImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *btn_left = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_left, nil];
    
    _scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_scanBtn setImage:[UIImage imageNamed:@"index_sweep"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -10;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, btn_right, nil];
    if([promptStr intValue] == 1){
        
        
    }else{
        if (QdxHeight == 736) {
            _promptView = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth/2-125, QdxHeight - 240,250, 110)];
            _leftBtn = [[UIButton alloc] init];
            _leftBtn.frame = CGRectMake(0, 50, 115, 45);
            _rightBtn = [[UIButton alloc] init];
            _rightBtn.frame = CGRectMake(130, 50, 115, 45);
        }else if (QdxHeight == 667){
            _promptView = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth/2-113.5, QdxHeight - 228,227, 100)];
            _leftBtn = [[UIButton alloc] init];
            _leftBtn.frame = CGRectMake(0, 45, 110, 40);
            _rightBtn = [[UIButton alloc] init];
            _rightBtn.frame = CGRectMake(115, 45, 110, 40);
        }else{
            _promptView = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth/2-90, QdxHeight - 205,180, 76)];
            _leftBtn = [[UIButton alloc] init];
            _leftBtn.frame = CGRectMake(0, 36, 85, 30);
            _rightBtn = [[UIButton alloc] init];
            _rightBtn.frame = CGRectMake(93, 36, 85, 30);
            
        }
        _promptView.image = [UIImage imageNamed:@"气泡"];
        _promptView.userInteractionEnabled = YES;
        _promptView.backgroundColor = [UIColor clearColor];
        [self.view bringSubviewToFront:_promptView];
        [self.view addSubview:_promptView];
        [_leftBtn addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
        [_promptView addSubview:_leftBtn];
        [_rightBtn addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        [_promptView addSubview:_rightBtn];
        
    }
    
}

- (void)leftClick
{
    
    [_promptView removeFromSuperview];
}

- (void)rightClick
{
    //yongjiushanchu
    NSString *str = @"1";
    [NSKeyedArchiver archiveRootObject:str toFile:QDXPromptFile];
    [_promptView removeFromSuperview];
}



- (void)createButtonWithView:(UIView *)view
{
    NSArray *titleArr = @[@"亲子",@"交友",@"拓展",@"挑战"];
    NSArray *imageArr = @[@"index_parenting",@"index_makefriends",@"index_expand",@"index_dekaron"];
    CGFloat scrollViewMaxY = CGRectGetMaxY(imgScrollView.frame);
    for(int i=0; i<4; i++){
        UIButton *btn = [ToolView createButtonWithFrame:CGRectMake(i*QdxWidth/4+QdxWidth/17, scrollViewMaxY+20, QdxWidth/8, QdxWidth/8) title:titleArr[i] backGroundImage:imageArr[i] Target:self action:@selector(btnClick:) superView:view];
        btn.titleEdgeInsets = UIEdgeInsetsMake(QdxWidth/5, 0, 0, 0);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.imageView.contentMode = UIViewContentModeCenter;
        btn.titleLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.tag = 1+i;
    }
}

- (void)refreshView
{
    _header = [MJRefreshHeaderView header];
    _header.delegate = self;
    _header.scrollView = _tableView;
    
//    _footer = [MJRefreshFooterView footer];
//    _footer.delegate = self;
//    _footer.scrollView = _tableView;
}

- (void)dealloc

{
    [_header free];
    
    //[_footer free];
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        _curNumber = 1;
        //刷新
        [self cellDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:YES andWithType:@"0"];
        
    } else {
//        //加载更多
//        _curNumber ++;
//        if(_countNum/13+1 == _currNum){
//            [_footer endRefreshing];
//        }else{
//            [self cellDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:NO];
//        }
    }
}
//- (void)addTimer
//{
//    _myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:_myTimer forMode:NSRunLoopCommonModes];
//}
//
//- (void)nextImage
//{
//    // 1.增加pageControl的页码
//    _currentIndex = 0;
//    if (_pageControl.currentPage == 3) {
//        _currentIndex = 0;
//    } else {
//        _currentIndex = _pageControl.currentPage + 1;
//    }
//
//    // 2.计算scrollView滚动的位置
//    CGFloat offsetX = _currentIndex * _scrollView.frame.size.width;
//    CGPoint offset = CGPointMake(offsetX, 0);
//    [_scrollView setContentOffset:offset animated:YES];
//}
//
//- (void)removeTimer
//{
//    [_myTimer invalidate];
//    _myTimer = nil;
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    // 停止定时器(一旦定时器停止了,就不能再使用)
//    [self removeTimer];
//}
////停止拖拽的时候调用
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    // 开启定时器
//    [self addTimer];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//
//    CGFloat scrollW = _scrollView.frame.size.width;
//    _currentIndex = (scrollView.contentOffset.x + scrollW * 0.5) / scrollW;
//    _pageControl.currentPage = _currentIndex;
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    _currentIndex = _scrollView.contentOffset.x/QdxWidth;
//    if(_scrollView.contentOffset.x >=QdxWidth*3){
//        _scrollView.contentOffset = CGPointMake(0, 0);
//    }
//    _pageControl.currentPage = _currentIndex;
//
//}

- (void)sussRes
{
    [self hideProgess];
}

- (void)failRes
{
    [self showProgessOK:@"加载失败"];
}

- (void)topViewData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [homehttp topViewDatasucceed:^(id data) {
        NSDictionary *dataDict = data[@"Msg"][@"data"];
        for(NSDictionary *dict in dataDict){
            int i = [dict[@"goods_index"] intValue];
            if (i == 1) {
                HomeModel *model = [[HomeModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                _model_tmp = model;
                NSString *str = model.good_url;
                [_scrollArr addObject:[NSString stringWithFormat:@"%@%@",hostUrl,str]];
                [_modelArr addObject:model];
            }
        }
        
        for(int i = 0;i<4;i++){
            [arr addObject:_scrollArr[i]];
        }
        //添加数据
        imgScrollView.pics = arr;
        //点击事件
        [imgScrollView returnIndex:^(NSInteger index) {
            QDXLineDetailViewController *detailLine = [[QDXLineDetailViewController alloc] init];
            detailLine.homeModel = [_modelArr objectAtIndex:index];
            detailLine.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailLine animated:YES];
        }];
        //刷新（必需的步骤）
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [imgScrollView reloadView];
        });
    } failure:^(NSError *error) {
        
    }];
});
}

- (void)state
{
    [self showProgessMsg:@"加载中"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    appdelegate.loading = YES;
    [homehttp statesucceed:^(id data) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        _code = [dict[@"Code"] intValue];
        appdelegate.code = [NSString stringWithFormat:@"%d",(int)_code];
        if(_code == 2){
            appdelegate.ticket = dict[@"Msg"][@"ticket"][@"ticket_id"];
        }else if (_code == 1) {
            [NSKeyedArchiver archiveRootObject:dict[@"Msg"][@"myline_id"] toFile:QDXCurrentMyLineFile];
        }
        appdelegate.loading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeScanBtn];
            [self hideProgess];
        });
        
    } failure:^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败，请检查网络！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self hideProgess];
        }]
         ];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    } WithToken:save];
    });
}

- (void)state1
{
    [_scanBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dbversion
{
    [self showProgessMsg:@"加载中"];
    [homehttp dbversionsucceed:^(id data) {
        [self hideProgess];
    } failure:^(NSError *error) {
        [self hideProgess];
    }];
}
- (void)cellDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll andWithType:(NSString *)type
{
        [self showProgessMsg:@"加载中"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [homehttp loadCellsucceed:^(id data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
            NSDictionary *dataDict = dict[@"Msg"][@"data"];
            _currNum = [dict[@"Msg"][@"curr"] integerValue];
            _countNum = [dict[@"Msg"][@"count"] integerValue];
            if (isRemoveAll) {
                [_dataArr removeAllObjects];
            }
            _dataArr = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dataDict){
                HomeModel *model = [[HomeModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_dataArr addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [_header endRefreshing];
                [_footer endRefreshing];
                [self hideProgess];
            });
            
            //[self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
    
        } failure:^(NSError *error) {
            [_header endRefreshing];
            [_footer endRefreshing];
        } WithCurr:cur WithType:type];
        });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseCell *cell = [BaseCell baseCellWithTableView:_tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.homeModel = _dataArr[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, QdxWidth, 10);
        view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        UIView *view1 = [[UIView alloc] init];
        view1.frame = CGRectMake(0, 10, QdxWidth, 29);
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        UIView *haedView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 3, 18)];
        haedView.backgroundColor = [UIColor colorWithRed:13/255.0 green:131/255.0 blue:252/255.0 alpha:1];
        [view addSubview:haedView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 200, 30)];
        titleLabel.text = @"经典推荐";
        titleLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [view1 addSubview:titleLabel];
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 39, QdxWidth, 1)];
        viewLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:0.1];
        [view addSubview:viewLine];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    lineVC.homeModel = _dataArr[indexPath.row];
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
}

- (void)btnClick:(UIButton *)btn
{
    NSString *type = [NSString stringWithFormat:@"%li",btn.tag];
    [self cellDataWith:@"1" isRemoveAll:YES andWithType:type];
}

- (void)changeScanBtn
{
    
    if(_code == 0){
        _scanBtn.hidden = NO;
        [_scanBtn addTarget:self action:@selector(scanClick1) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        
        _scanBtn.hidden = YES;
    }
    
}

- (void)scanClick
{
    if (save) {
        [self scanClick1];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }
}
- (void)scanClick1
{
    ImagePickerController *imageVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag, NSString *from) {
        imageVC.from = from;
        _result = result;
        NSLog(@"%@",_result);
        [self netWorking];
    }];
    imageVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:imageVC animated:YES];
}

- (void)netWorking
{
    
    //创建请求管理对象
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"ticketinfo_name"] = _result;
    [mgr POST:[NSString stringWithFormat:@"%@%@",hostUrl,actUrl] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSDictionary *dictMsg = dict[@"Msg"];
        StartModel *model = [[StartModel alloc] init];
        [model setCode:dict[@"Code"] ];
        [model setMsg:dict[@"Msg"]];
        int temp = [model.Code intValue];
        if (!temp) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",model.Msg] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];
            
            
            
        }else{
            [model setTicket_id:dictMsg[@"ticket_id"]];
            if([model.ticket_id longLongValue] <100000000000){
                [NSKeyedArchiver archiveRootObject:model.ticket_id toFile:QDXTicketFile];
                LineController *lineVC = [[LineController alloc] init];
                QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:lineVC];
                self.delegate = lineVC;
                [self.delegate PassTicket:model.ticket_id andClick:@"2"];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }else{
            }
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)setClick
{
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }else{
        [self.sideMenuViewController presentLeftMenuViewController];
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

- (void)choiceBtnClicked
{
    LineController *lineVC = [[LineController alloc] init];
    lineVC.click = @"1";
    lineVC.ticketID = saveTicket_id;
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
    
}


- (void)topBtnClicked:(UIButton *)btn
{
    QDXLineDetailViewController *detailLine = [[QDXLineDetailViewController alloc] init];
    btn.tag = _currentIndex;
    detailLine.homeModel = [_modelArr objectAtIndex:btn.tag];
    detailLine.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailLine animated:YES];
}

- (void)startGame
{
    NSString *isHave = [NSKeyedUnarchiver unarchiveObjectWithFile:QDXMyLineFile];
    if (isHave) {
        QDXGameViewController *viewController = [[QDXGameViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        QDXProtocolViewController *viewController = [[QDXProtocolViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
