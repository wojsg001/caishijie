//
//  SJCityModel.m
//  CaiShiJie
//
//  Created by user on 18/4/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCityModel.h"

static NSArray *tmpArr=nil;
@implementation SJCityModel

+ (void)initialize{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"CityData.plist" ofType:nil];
    tmpArr=[NSArray arrayWithContentsOfFile:path];
}
//所有的省份信息
+ (NSArray *)allProvinces{
    NSMutableArray *arrM=[NSMutableArray new];
    for (NSDictionary *tmpDict in tmpArr) {
        NSString *p=tmpDict[@"State"];
        [arrM addObject:p];
    }
    return arrM;
}
//所有省份对应的城市信息
+ (NSArray *)allCitysWithAllProvince{
    NSMutableArray *cityArr = [NSMutableArray array];
    
    for (NSDictionary *dict in tmpArr) {
        NSMutableArray *arrM=[NSMutableArray array];
        NSArray *arr=dict[@"Cities"];
        for (NSDictionary *tmpDict in arr) {
            SJCityModel *model=[[SJCityModel alloc] init];
            [model setValuesForKeysWithDictionary:tmpDict];
            [arrM addObject:model];
        }
        [cityArr addObject:arrM];
    }
    
    return cityArr;
}

@end
