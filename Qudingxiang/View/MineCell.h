//
//  MineCell.h
//  Qudingxiang
//
//  Created by Mac on 15/10/10.
//  Copyright © 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Myline;
@interface MineCell : UITableViewCell
@property (nonatomic, strong)Myline *myline;
+ (instancetype)baseCellWithTableView:(UITableView *)tableView;
@end
