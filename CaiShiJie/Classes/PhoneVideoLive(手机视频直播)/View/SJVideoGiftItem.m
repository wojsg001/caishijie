//
//  SJVideoGiftItem.m
//  CaiShiJie
//
//  Created by user on 16/7/26.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJVideoGiftItem.h"
#import "SJGiftModel.h"

@interface SJVideoGiftItem ()

@property (nonatomic, strong) UIImageView *giftIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIImageView *selectedIcon;

@end

@implementation SJVideoGiftItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupChildViews];
        [self initLayoutSubviews];
    }
    return self;
}

- (void)setupChildViews {
    _giftIcon = [[UIImageView alloc] init];
    [self addSubview:_giftIcon];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor colorWithHexString:@"#ffffff" withAlpha:1];
    _nameLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_nameLabel];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    _priceLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_priceLabel];
    
    _selectedIcon = [[UIImageView alloc] init];
    [_selectedIcon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"select_icon"]];
    _selectedIcon.hidden = YES; // 默认未选择
    [self addSubview:_selectedIcon];
}

- (void)initLayoutSubviews {
    WS(weakSelf);
    [_giftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(70);
        make.centerX.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.giftIcon.mas_bottom).offset(0);
        make.centerX.mas_equalTo(weakSelf);
    }];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(6);
        make.centerX.mas_equalTo(weakSelf);
    }];
    
    [_selectedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.giftIcon.mas_top).offset(5);
        make.right.equalTo(weakSelf.giftIcon.mas_right).offset(-5);
    }];
}

- (void)setModel:(SJGiftModel *)model {
    _model = model;
    
    [_giftIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://common.csjimg.com/gift/%@",_model.img]] placeholderImage:[UIImage imageNamed:@"live_gift_img_n"]];
    _nameLabel.text = _model.gift_name;
    _priceLabel.text = [NSString stringWithFormat:@"%@金币", _model.price];
}

- (void)selectedItem:(BOOL)selected {
    self.selectedIcon.hidden = !selected;
}

- (void)dealloc {
    //SJLog(@"%s", __func__);
}

@end
