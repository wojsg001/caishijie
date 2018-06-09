//
//  SJCityModel.h
//  CaiShiJie
//
//  Created by user on 16/4/11.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJCityModel : NSObject

@property (nonatomic,strong) NSString *city;

//所有的省份信息
+ (NSArray *)allProvinces;
//某个省份对应的城市信息
+ (NSArray *)allCitysWithAllProvince;

@end
