//
//  VideoCollectionViewCell.h
//  shipin
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *namelable;
@property (weak, nonatomic) IBOutlet UILabel *creat_at;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *courselable;

@end
