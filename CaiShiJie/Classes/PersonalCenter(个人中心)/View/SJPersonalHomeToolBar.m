//
//  SJPersonalHomeToolBar.m
//  CaiShiJie
//
//  Created by user on 16/10/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalHomeToolBar.h"
#import "SDAutoLayout.h"
#import "SJPersonalHomeModel.h"

@interface SJPersonalHomeToolBar ()

@property (nonatomic, strong) UIView *buttonBackgroundView;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UIButton *commentButton;

@end

@implementation SJPersonalHomeToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB(245, 245, 248);
        self.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
        self.layer.borderWidth = 0.5f;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _buttonBackgroundView = [[UIView alloc] init];
    _buttonBackgroundView.backgroundColor = [UIColor whiteColor];
    _buttonBackgroundView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    _buttonBackgroundView.layer.borderWidth = 0.5f;
    [self addSubview:_buttonBackgroundView];
    
    _forwardButton = [[UIButton alloc] init];
    [_forwardButton setTitle:@"4" forState:UIControlStateNormal];
    _forwardButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_forwardButton setTitleColor:[UIColor colorWithHexString:@"#999999" withAlpha:1] forState:UIControlStateNormal];
    [_forwardButton setImage:[UIImage imageNamed:@"HomePage_icon4"] forState:UIControlStateNormal];
    [_forwardButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    _forwardButton.tag = 301;
    [_forwardButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBackgroundView addSubview:_forwardButton];
    
    UIView *lineOne = [[UIView alloc] init];
    lineOne.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.buttonBackgroundView addSubview:lineOne];
    
    _praiseButton = [[UIButton alloc] init];
    [_praiseButton setTitle:@"4" forState:UIControlStateNormal];
    _praiseButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_praiseButton setTitleColor:[UIColor colorWithHexString:@"#999999" withAlpha:1] forState:UIControlStateNormal];
    [_praiseButton setImage:[UIImage imageNamed:@"HomePage_icon5"] forState:UIControlStateNormal];
    [_praiseButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    _praiseButton.tag = 302;
    [_praiseButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBackgroundView addSubview:_praiseButton];
    
    UIView *lineTwo = [[UIView alloc] init];
    lineTwo.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.buttonBackgroundView addSubview:lineTwo];
    
    _commentButton = [[UIButton alloc] init];
    [_commentButton setTitle:@"4" forState:UIControlStateNormal];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_commentButton setTitleColor:[UIColor colorWithHexString:@"#999999" withAlpha:1] forState:UIControlStateNormal];
    [_commentButton setImage:[UIImage imageNamed:@"HomePage_icon6"] forState:UIControlStateNormal];
    [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    _commentButton.tag = 303;
    [_commentButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBackgroundView addSubview:_commentButton];
    
    _buttonBackgroundView.sd_layout
    .leftEqualToView(self)
    .topEqualToView(self)
    .rightEqualToView(self)
    .heightIs(30);
    
    CGFloat buttonWidth = (SJScreenW - 1)/3;
    _forwardButton.sd_layout
    .leftEqualToView(self.buttonBackgroundView)
    .topEqualToView(self.buttonBackgroundView)
    .bottomEqualToView(self.buttonBackgroundView)
    .widthIs(buttonWidth);
    
    lineOne.sd_layout
    .leftSpaceToView(self.forwardButton, 0)
    .centerYEqualToView(self.buttonBackgroundView)
    .widthIs(0.5)
    .heightIs(15);
    
    _praiseButton.sd_layout
    .leftSpaceToView(lineOne, 0)
    .topEqualToView(self.buttonBackgroundView)
    .bottomEqualToView(self.buttonBackgroundView)
    .widthIs(buttonWidth);
    
    lineTwo.sd_layout
    .leftSpaceToView(self.praiseButton, 0)
    .centerYEqualToView(self.buttonBackgroundView)
    .widthIs(0.5)
    .heightIs(15);
    
    _commentButton.sd_layout
    .leftSpaceToView(lineTwo, 0)
    .topEqualToView(self.buttonBackgroundView)
    .bottomEqualToView(self.buttonBackgroundView)
    .widthIs(buttonWidth);
}

- (void)setModel:(SJPersonalHomeModel *)model {
    _model = model;
    
    [_forwardButton setTitle:_model.forward forState:UIControlStateNormal];
    [_praiseButton setTitle:_model.praise forState:UIControlStateNormal];
    [_commentButton setTitle:_model.comment forState:UIControlStateNormal];
}

- (void)buttonClicked:(UIButton *)button {
    
}

@end
