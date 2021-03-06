//
//  DWViewCell.m
//  CardSlide
//
//  Created by DavidWang on 15/11/25.
//  Copyright © 2015年 DavidWang. All rights reserved.
//

#import "DWViewCell.h"

@interface DWViewCell ()

@end

@implementation DWViewCell

//- (void)awakeFromNib {
//    self.layer.cornerRadius = 5.0f;
//
//    CALayer *layer = [self layer];
//    layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    layer.borderWidth = 1.0f;
//    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0, 0);
//    self.layer.shadowOpacity = 0.5;
//    self.layer.shadowRadius = 10.0;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *showView = [[UIView alloc] initWithFrame:self.bounds];
        showView.backgroundColor = [UIColor whiteColor];
        showView.layer.cornerRadius = 12.0f;
        showView.layer.masksToBounds = YES;
        self.layer.shadowColor = QDXGray.CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = 4.0;
        [self.contentView addSubview:showView];
        
        self.showImg = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(80), FitRealValue(40), FitRealValue(410), FitRealValue(410))];
        [showView addSubview:self.showImg];
        
        self.showLab = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(80), FitRealValue(40 + 410 + 40), FitRealValue(410), FitRealValue(40))];
        self.showLab.textColor = QDXBlack;
        self.showLab.font = [UIFont systemFontOfSize:19];
        self.showLab.textAlignment = NSTextAlignmentCenter;
        [showView addSubview:self.showLab];
        
        self.showText = [[UITextView alloc] initWithFrame:CGRectMake(FitRealValue(60), FitRealValue(40 + 410 + 40 + 40 + 30 ), FitRealValue(430), FitRealValue(200))];
        self.showText.textColor = QDXGray;
        self.showText.font = [UIFont systemFontOfSize:15];
        self.showText.editable = NO;
        [showView addSubview:self.showText];
    }
    return self;
}

@end
