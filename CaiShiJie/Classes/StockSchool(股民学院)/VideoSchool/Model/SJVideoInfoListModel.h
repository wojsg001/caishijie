//
//  SJVideoInfoListModel.h
//  CaiShiJie
//
//  Created by user on 16/7/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJVideoInfoListModel : NSObject

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *item_type;
@property (nonatomic, copy) NSString *period_name;
@property (nonatomic, copy) NSString *period_id;
@property (nonatomic, copy) NSString *vod;
@property (nonatomic, copy) NSString *url;

@end
