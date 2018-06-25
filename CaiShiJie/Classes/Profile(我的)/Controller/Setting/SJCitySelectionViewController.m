//
//  SJCitySelectionViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCitySelectionViewController.h"
#import "SJCityModel.h"
#import "SJCityCell.h"
#import "SJCityGroupSection.h"

#import "SJhttptool.h"
#import "NSString+SJMD5.h"

@interface SJCitySelectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeight;

// 内容数组
@property (nonatomic, strong) NSArray *dataArray;
// 标题数组
@property (nonatomic, strong) NSArray *sectionArray;
// 状态数组
@property (nonatomic, strong) NSMutableArray *stateArray;

@end

@implementation SJCitySelectionViewController

- (NSMutableArray *)stateArray
{
    if (_stateArray == nil)
    {
        _stateArray = [NSMutableArray array];
    }
    return _stateArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topLineHeight.constant = 0.5f;
    self.bottomLineHeight.constant = 0.5f;
    self.view.backgroundColor = RGB(245, 245, 248);
    self.navigationItem.title = @"城市设置";
    
    // 设置CollectionView属性
    [self setUpCollectionView];
    
    self.sectionArray = [SJCityModel allProvinces];
    self.dataArray = [SJCityModel allCitysWithAllProvince];
    
    for (int i = 0; i < _sectionArray.count; i++)
    {
        //所有的分区都是闭合
        [self.stateArray addObject:@"0"];
    }
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

#pragma mark - 保存
- (void)save
{
    if ([self.cityTextField.text isEqualToString:@""])
    {
        [MBHUDHelper showWarningWithText:@"请选择城市"];
        return;
    }
    
    NSString *url =[NSString stringWithFormat:@"%@/mobile/user/updateaddress",HOST];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    NSArray *array =[self.cityTextField.text componentsSeparatedByString:@"-"];
    NSString *str1 =array[0];//省份
    NSString *str2 =array[1];//地区
    NSLog(@"%@",array);
    
    NSDictionary *dic =[NSDictionary dictionaryWithObjectsAndKeys:str1,@"province",str2,@"city",md5Auth_key,@"token",datestr,@"time",user_id,@"userid",nil,@"district", nil];
    
    [SJhttptool POST:url paramers:dic success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"修改失败！"];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"网络错误！"];
    }];
}

- (void)setUpCollectionView
{
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"SJCityCell" bundle:nil] forCellWithReuseIdentifier:@"SJCityCell"];
    
    //参数二：用来区分是分组头还是分组脚
    [_collectionView registerNib:[UINib nibWithNibName:@"SJCityGroupSection" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SJCityGroupSection"];
}

#pragma mark - UICollectionViewDataSource 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_stateArray[section] isEqualToString:@"1"])
    {
        // 如果是打开状态
        NSArray *tmpArr = self.dataArray[section];
        return tmpArr.count;
    }
    else
    {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SJCityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJCityCell" forIndexPath:indexPath];
    NSArray *tmpArr = self.dataArray[indexPath.section];
    SJCityModel *city = tmpArr[indexPath.row];
    
    cell.titleLabel.text = city.city;
    
    return cell;
}

//协议中的方法，用于返回单元格的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SJScreenW-20)/3, 44);
}

//协议中的方法，用于返回整个CollectionView上、左、下、右距四边的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //上、左、下、右的边距
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

//协议中的方法，用来返回分组头的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //宽度随便定，系统会自动取collectionView的宽度
    //高度为分组头的高度
    return CGSizeMake(0, 44);
}

//参数二：用来区分是分组头还是分组脚
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SJCityGroupSection *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SJCityGroupSection" forIndexPath:indexPath];
    header.sectionTitle.text = _sectionArray[indexPath.section];
    
    
    [header.sectionBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    header.sectionBtn.tag = indexPath.section + 1;
    
    
    if ([self.stateArray[indexPath.section] isEqualToString:@"0"]) {

        [header.sectionBtn setImage:[UIImage imageNamed:@"article_icon2_n"] forState:UIControlStateNormal];
        
    }
    else if ([self.stateArray[indexPath.section] isEqualToString:@"1"]){
        
        [header.sectionBtn setImage:[UIImage imageNamed:@"mine_down_icon"] forState:UIControlStateNormal];
        
    }
    return header;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tmpArr = self.dataArray[indexPath.section];
    SJCityModel *city = tmpArr[indexPath.row];
    
    self.cityTextField.text = [NSString stringWithFormat:@"%@-%@",self.sectionArray[indexPath.section],city.city];
}

- (void)buttonClick:(UIButton *)sender//headButton点击
{
    //判断状态值
    if ([self.stateArray[sender.tag - 1] isEqualToString:@"1"]){
        //修改
        [self.stateArray replaceObjectAtIndex:sender.tag - 1 withObject:@"0"];
    }else{
        [self.stateArray replaceObjectAtIndex:sender.tag - 1 withObject:@"1"];
    }
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag - 1]];
}

@end
