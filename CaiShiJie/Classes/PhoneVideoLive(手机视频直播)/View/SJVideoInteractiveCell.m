//
//  SJVideoInteractiveCell.m
//  CaiShiJie
//
//  Created by user on 16/11/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJVideoInteractiveCell.h"
#import "SDAutoLayout.h"
#import "SJVideoInteractiveModel.h"

#define KContentMaxWidth (250 - 20)

@interface SJVideoInteractiveCell ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation SJVideoInteractiveCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJVideoInteractiveCell";
    SJVideoInteractiveCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJVideoInteractiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _contentLabel = [[UILabel alloc] init];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.isAttributedContent = YES;
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.shadowColor = [UIColor colorWithHexString:@"#040000" withAlpha:0.75];
    _contentLabel.shadowOffset = CGSizeMake(0, 1);
    [self.contentView addSubview:_contentLabel];
    
    _contentLabel.sd_layout.topSpaceToView(self.contentView, 5)
    .leftSpaceToView(self.contentView, 10)
    .widthIs(KContentMaxWidth)
    .autoHeightRatio(0);
    
    [self setupAutoHeightWithBottomView:_contentLabel bottomMargin:5];
}

- (void)setModel:(SJVideoInteractiveModel *)model {
    _model = model;
    
    _contentLabel.attributedText = _model.attributedString;
    [_contentLabel sizeToFit];
}

@end
