//
//  SJPersonalHomeCell.m
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalHomeCell.h"
#import "SJPersonalHomeUserView.h"
#import "SJPersonalHomeOriginalView.h"
#import "SJPersonalHomeForwardView.h"
#import "SJPersonalHomeToolBar.h"
#import "SDAutoLayout.h"
#import "SJPersonalHomeModel.h"

@interface SJPersonalHomeCell ()

@property (nonatomic, strong) SJPersonalHomeUserView *userView;
@property (nonatomic, strong) SJPersonalHomeOriginalView *originalView;
@property (nonatomic, strong) SJPersonalHomeForwardView *forwardView;
@property (nonatomic, strong) SJPersonalHomeToolBar *toolBar;

@end

@implementation SJPersonalHomeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJPersonalHomeCell";
    SJPersonalHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJPersonalHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _userView = [[SJPersonalHomeUserView alloc] init];
    [self.contentView addSubview:_userView];
    
    _originalView = [[SJPersonalHomeOriginalView alloc] init];
    [self.contentView addSubview:_originalView];
    
    _forwardView = [[SJPersonalHomeForwardView alloc] init];
    [self.contentView addSubview:_forwardView];
    
    _toolBar = [[SJPersonalHomeToolBar alloc] init];
    [self.contentView addSubview:_toolBar];
    
    [self setupAutoHeightWithBottomView:_toolBar bottomMargin:0];
    
    _userView.sd_layout
    .leftEqualToView(self.contentView)
    .topEqualToView(self.contentView)
    .rightEqualToView(self.contentView)
    .heightIs(58);
}

- (void)setModel:(SJPersonalHomeModel *)model {
    _model = model;
    
    _originalView.frame = CGRectZero;
    _forwardView.frame = CGRectZero;
    _toolBar.frame = CGRectZero;
    
    [_originalView sd_clearAutoLayoutSettings];
    [_forwardView sd_clearAutoLayoutSettings];
    [_toolBar sd_clearAutoLayoutSettings];
    
    _userView.model = model;
    _toolBar.model = model;
    
    if ([_model.types isEqualToString:@"1"]) {
        // 转发
        _originalView.hidden = YES;
        _forwardView.hidden = NO;
        _forwardView.model = _model;
        
        self.forwardView.sd_resetLayout
        .leftSpaceToView(self.contentView, 55)
        .rightSpaceToView(self.contentView, 10)
        .topSpaceToView(self.userView, 10);
        
        self.toolBar.sd_resetLayout
        .leftEqualToView(self.contentView)
        .rightEqualToView(self.contentView)
        .topSpaceToView(self.forwardView, 15)
        .heightIs(36);
    } else {
        // 原创
        _originalView.hidden = NO;
        _forwardView.hidden = YES;
        _originalView.model = _model;

        self.originalView.sd_resetLayout
        .leftSpaceToView(self.contentView, 55)
        .rightSpaceToView(self.contentView, 10)
        .topSpaceToView(self.userView, 10);
        
        self.toolBar.sd_resetLayout
        .leftEqualToView(self.contentView)
        .rightEqualToView(self.contentView)
        .topSpaceToView(self.originalView, 0)
        .heightIs(36);
    }
}

- (void)setTeacherInfoDic:(NSDictionary *)teacherInfoDic {
    _teacherInfoDic = teacherInfoDic;
    
    _userView.teacherInfoDic = teacherInfoDic;
}

@end
