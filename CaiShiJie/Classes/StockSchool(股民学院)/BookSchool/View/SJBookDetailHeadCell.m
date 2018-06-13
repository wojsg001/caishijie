//
//  SJBookDetailHeadCell.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBookDetailHeadCell.h"
#import "SJBookDetailHead.h"
// 建议放在pch文件中
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "UIImageView+WebCache.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface SJBookDetailHeadCell ()

@property (nonatomic, strong) UIView *addImgView; // 放图片的视图
@property (nonatomic, strong) UIImageView *bookImgView;
@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) UILabel *bookAuthorLabel;
@property (nonatomic, strong) UILabel *bookStartTimeLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, assign) BOOL isExpandedNow;

@end

@implementation SJBookDetailHeadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 初始化子视图
        [self initChildView];
    }
    return self;
}

- (void)initChildView
{
    WS(weakSelf);

    _bookTitleLabel = [[UILabel alloc] init];
    _bookTitleLabel.textColor = RGB(68, 68, 68);
    _bookTitleLabel.font = [UIFont systemFontOfSize:16];
    _bookTitleLabel.preferredMaxLayoutWidth = SJScreenW / 2  - 10;
    [self.contentView addSubview:_bookTitleLabel];
    [_bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(27);
        make.left.equalTo(weakSelf.contentView.mas_centerX).offset(0);
        make.right.mas_equalTo(-10);
    }];
    
    _bookAuthorLabel = [[UILabel alloc] init];
    _bookAuthorLabel.textColor = RGB(115, 115, 115);
    _bookAuthorLabel.font = [UIFont systemFontOfSize:14];
    _bookAuthorLabel.preferredMaxLayoutWidth = SJScreenW / 2  - 10;
    [self.contentView addSubview:_bookAuthorLabel];
    [_bookAuthorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bookTitleLabel.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.bookTitleLabel.mas_left).offset(0);
        make.right.mas_equalTo(-10);
    }];
    
    _bookStartTimeLabel = [[UILabel alloc] init];
    _bookStartTimeLabel.textColor = RGB(115, 115, 115);
    _bookStartTimeLabel.font = [UIFont systemFontOfSize:14];
    _bookStartTimeLabel.preferredMaxLayoutWidth = SJScreenW / 2  - 10;
    [self.contentView addSubview:_bookStartTimeLabel];
    [_bookStartTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bookAuthorLabel.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.bookTitleLabel.mas_left).offset(0);
        make.right.mas_equalTo(-10);
    }];
    
    _startReadButton = [[UIButton alloc] init];
    [_startReadButton setTitle:@"开始阅读" forState:UIControlStateNormal];
    _startReadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_startReadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startReadButton setBackgroundImage:[UIImage imageNamed:@"login_btn_n"] forState:UIControlStateNormal];
    [_startReadButton setBackgroundImage:[UIImage imageNamed:@"login_btn_h"] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_startReadButton];
    [_startReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bookStartTimeLabel.mas_bottom).offset(32);
        make.left.equalTo(weakSelf.bookTitleLabel.mas_left).offset(0);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(SJScreenW/2 - 10);
    }];
    
    _descLabel = [[UILabel alloc] init];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textColor = RGB(132, 132, 132);
    [self.contentView addSubview:_descLabel];
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.equalTo(weakSelf.startReadButton.mas_bottom).offset(20);
    }];
    // 应该始终要加上这一句
    // 不然在6/6plus上就不准确了
    _descLabel.preferredMaxLayoutWidth = SJScreenW - 20;
    
    _moreButton = [[UIButton alloc] init];
    [_moreButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton setTitle:@"展开" forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_moreButton setTitleColor:RGB(80, 145, 254) forState:UIControlStateNormal];
    [self.contentView addSubview:_moreButton];
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.descLabel.mas_bottom).offset(5);
        make.right.mas_equalTo(-10);
    }];
    
    
    // 放图片的位置
    _addImgView = [[UIView alloc] init];
    _addImgView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_addImgView];
    [_addImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.equalTo(weakSelf.contentView.mas_centerX).offset(0);
        make.bottom.equalTo(weakSelf.descLabel.mas_top).offset(0);
    }];
    
    _bookImgView = [[UIImageView alloc] init];
    [self.addImgView addSubview:_bookImgView];
    [_bookImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.addImgView);
        make.width.mas_equalTo(108);
        make.height.mas_equalTo(144);
    }];
    
    // 必须加上这句
    self.hyb_lastViewInCell = self.moreButton;
    self.hyb_bottomOffsetToCell = 10;
    self.isExpandedNow = YES;
}

- (void)configCellWithModel:(SJBookDetailHead *)model
{
    WS(weakSelf);
    [self.bookImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,model.cover_img]] placeholderImage:[UIImage imageNamed:@"end_book"]];
    self.bookTitleLabel.text = model.title;
    self.bookAuthorLabel.text = [NSString stringWithFormat:@"作者：%@",model.author];
    self.bookStartTimeLabel.text = [NSString stringWithFormat:@"出版时间：%@",model.publication_at];
    self.descLabel.text = model.summary;
    
    if (model.isExpand != self.isExpandedNow)
    {
        self.isExpandedNow = model.isExpand;
        
        if (self.isExpandedNow)
        {
            [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(10);
                make.right.mas_equalTo(-10);
                make.top.equalTo(weakSelf.startReadButton.mas_bottom).offset(20);
            }];
        }
        else
        {
            [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_lessThanOrEqualTo(60);
            }];
        }
    } else {
        if (self.isExpandedNow) {
            [self.moreButton setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            [self.moreButton setTitle:@"展开" forState:UIControlStateNormal];
        }
    }
}

- (void)buttonDown:(UIButton *)sender
{
    if (self.expandBlock)
    {
        self.expandBlock(!self.isExpandedNow);
    }
}


@end
