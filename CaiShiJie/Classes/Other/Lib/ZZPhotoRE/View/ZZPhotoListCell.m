//
//  ZZPhotoListCell.m
//  ZZFramework
//
//  Created by Yuan on 15/12/17.
//  Copyright © 2015年 zzl. All rights reserved.
//

#import "ZZPhotoListCell.h"

@implementation ZZPhotoListCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 60, 60)];
        
        _coverImage.layer.masksToBounds = YES;
        
        _coverImage.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:_coverImage];
        
        CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 90;
        
        _title = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, labelWidth, 25)];
        
        _title.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_title];
        
        _subTitle = [[UILabel alloc]initWithFrame:CGRectMake(80, 40, labelWidth, 25)];
        
        _subTitle.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_subTitle];
        
        CGFloat right = [UIScreen mainScreen].bounds.size.width;
        
        UIImageView *right_Cell = [[UIImageView alloc]initWithFrame:CGRectMake(right - 29, 25, 9, 20)];
        
        right_Cell.image = PhotoListRightBtn;
        
        [self.contentView addSubview:right_Cell];
        
    }
    return self;
}

-(void)loadPhotoListData:(PHAssetCollection *)collectionItem
{
    if ([collectionItem isKindOfClass:[PHAssetCollection class]]) {
        PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:collectionItem options:nil];
        
        
        [[PHImageManager defaultManager] requestImageForAsset:group.lastObject
                                                   targetSize:CGSizeMake(200,200)
                                                  contentMode:PHImageContentModeDefault
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result == nil) {
                                                        self.coverImage.image = NOPhoto_Data_Pic;
                                                    }else{
                                                        self.coverImage.image = result;
                                                    }
                                                    
                                                    
                                                }];
        
        
        PHAssetCollection *titleAsset = collectionItem;

        if ([titleAsset.localizedTitle isEqualToString:@"All Photos"]) {
            self.title.text = @"相机胶卷";
        }else{
            self.title.text = [NSString stringWithFormat:@"%@",titleAsset.localizedTitle];
        }
        
        
        self.subTitle.text = [NSString stringWithFormat:@"%lu",(unsigned long)group.count];
    }
}
@end
