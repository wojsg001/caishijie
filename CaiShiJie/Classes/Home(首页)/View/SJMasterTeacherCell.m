//
//  SJMasterTeacherCell.m
//  CaiShiJie
//
//  Created by user on 18/5/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMasterTeacherCell.h"
#import "SJMasterTeacherView.h"
#import "SJMasterTeacherModel.h"
#import "UIImageView+WebCache.h"

#define NewCell_H 106

@interface SJMasterTeacherCell ()

@property (nonatomic, strong) UIScrollView *backScrollView;

@end

@implementation SJMasterTeacherCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJMasterTeacherCell";
    SJMasterTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJMasterTeacherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addContentView];
    }
    return self;
}

- (void)addContentView
{
    _backScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SJScreenW, NewCell_H)];
    
    _backScrollView.contentSize=CGSizeMake(2*SJScreenW, 0);
    _backScrollView.userInteractionEnabled=YES;
    _backScrollView.directionalLockEnabled=YES;
    _backScrollView.pagingEnabled=NO;
    _backScrollView.bounces=YES;
    _backScrollView.showsHorizontalScrollIndicator=NO;
    _backScrollView.showsVerticalScrollIndicator=NO;
    
    
    [self addSubview:_backScrollView];
}

- (void)setArray:(NSArray *)array
{
    _array = array;
    
    for (int i = 0; i < array.count; i++)
    {
        SJMasterTeacherModel *model = array[i];
        
        CGRect frame = CGRectMake((i+1)*10 + i*80, 8, 80, NewCell_H);
        SJMasterTeacherView *newShowView = [[SJMasterTeacherView alloc] init];
        newShowView.tag = i;
        newShowView.frame = frame;

        [newShowView.HeadView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,model.head_img]] placeholderImage:[UIImage imageNamed:@"index_account_photo3"]];
        newShowView.nickNameLabel.text = model.nickname;
        [_backScrollView addSubview:newShowView];
        
        UITapGestureRecognizer *tapNewview=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOneNewView:)];
        [newShowView addGestureRecognizer:tapNewview];
        
    }
    
    _backScrollView.contentSize=CGSizeMake(array.count*74 + 10, 0);
}

- (void)tapOneNewView:(UIGestureRecognizer*)sender
{
    SJLog(@"%ld", sender.view.tag);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(masterTeacherCell:didSelectedwhichOne:)])
    {
        [self.delegate masterTeacherCell:self didSelectedwhichOne:sender.view.tag];
    }
}

@end
