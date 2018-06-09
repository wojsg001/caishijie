//
//  SJPersonalHomeUserView.m
//  CaiShiJie
//
//  Created by user on 16/10/12.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalHomeUserView.h"
#import "SJPersonalHomeModel.h"
#import "SDAutoLayout.h"

#define kMargin 10
#define kHeadImageWH 35
#define ContentMaxWidth SJScreenW - kHeadImageWH - kMargin * 3

@interface SJPersonalHomeUserView ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation SJPersonalHomeUserView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _headImageView = [[UIImageView alloc] init];
    _headImageView.image = [UIImage imageNamed:@"pho_mytg"];
    [self addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"----";
    _nameLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.text = @"----";
    _timeLabel.textColor = [UIColor colorWithHexString:@"#999999" withAlpha:1];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_timeLabel];
    
    _headImageView.sd_layout
    .leftSpaceToView(self, 10)
    .topSpaceToView(self, 23)
    .widthIs(35)
    .heightIs(35);
    
    _nameLabel.sd_layout
    .leftSpaceToView(self.headImageView, 10)
    .topEqualToView(self.headImageView)
    .heightIs(15)
    .widthIs(ContentMaxWidth);
    
    _timeLabel.sd_layout
    .leftEqualToView(self.nameLabel)
    .topSpaceToView(self.nameLabel, 10)
    .heightIs(12)
    .widthIs(ContentMaxWidth);
}

- (void)setModel:(SJPersonalHomeModel *)model {
    _model = model;
    
    _timeLabel.text = _model.created_at;
}

- (void)setTeacherInfoDic:(NSDictionary *)teacherInfoDic {
    _teacherInfoDic = teacherInfoDic;
    
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _teacherInfoDic[@"head_img"]]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    _nameLabel.text = _teacherInfoDic[@"nickname"];
}

@end
