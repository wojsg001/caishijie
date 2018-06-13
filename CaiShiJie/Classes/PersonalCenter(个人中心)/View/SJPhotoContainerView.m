//
//  SJPhotoContainerView.m
//  CaiShiJie
//
//  Created by user on 16/10/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPhotoContainerView.h"
#import "SDAutoLayout.h"
#import "SDPhotoBrowser.h"

@interface SJPhotoContainerView ()<SDPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *picPathStringsArray;
@property (nonatomic, strong) NSArray *imageViewsArray;

@end

@implementation SJPhotoContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [tempArray addObject:imageView];
    }
    
    self.imageViewsArray = [tempArray copy];
}

- (void)setPictureString:(NSString *)pictureString {
    _pictureString = pictureString;
    
    NSArray *tmpArray = [_pictureString componentsSeparatedByString:@","];
    _picPathStringsArray = [tmpArray mutableCopy];
    [_picPathStringsArray removeLastObject];
    
    for (NSInteger i = _picPathStringsArray.count; i < self.imageViewsArray.count; i++) {
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        imageView.hidden = YES;
    }
    
    if (_picPathStringsArray.count == 0) {
        self.height = 0;
        self.fixedHeight = @(0);
        return;
    }
    
    CGFloat itemW = [self itemWidthForPicPathArray:_picPathStringsArray];
    CGFloat itemH = 0;
    if (_picPathStringsArray.count == 1) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, [_picPathStringsArray firstObject]]]]];
        if (image.size.width) {
            itemH = image.size.height / image.size.width * itemW;
        }
    } else {
        itemH = itemW;
    }
    NSInteger perRowItemCount = [self perRowItemCountForPicPathArray:_picPathStringsArray];
    CGFloat margin = 5;
    [_picPathStringsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger columnIndex = idx % perRowItemCount;
        NSInteger rowIndex = idx / perRowItemCount;
        UIImageView *imageView = [_imageViewsArray objectAtIndex:idx];
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, obj]] placeholderImage:[UIImage imageNamed:@"neican_photo"]];
        imageView.frame = CGRectMake(columnIndex * (itemW + margin), rowIndex * (itemH + margin), itemW, itemH);
    }];
    
    CGFloat w = perRowItemCount * itemW + (perRowItemCount - 1) * margin;
    int columnCount = ceilf(_picPathStringsArray.count * 1.0 / perRowItemCount);
    CGFloat h = columnCount * itemH + (columnCount - 1) *margin;
    self.width = w;
    self.height = h;
    
    self.fixedHeight = @(h);
    self.fixedWidth = @(w);
}

- (CGFloat)itemWidthForPicPathArray:(NSArray *)array
{
    if (array.count == 1) {
        return 120;
    } else {
        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 80 : 70;
        return w;
    }
}

- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array
{
    if (array.count < 3) {
        return array.count;
    } else if (array.count <= 4) {
        return 2;
    } else {
        return 3;
    }
}

#pragma mark - 点击图片
- (void)tapImageView:(UITapGestureRecognizer *)tap {
    UIView *imageView = tap.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag;
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.picPathStringsArray.count;
    browser.delegate = self;
    [browser show];
}

#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    NSString *imageName = self.picPathStringsArray[index];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, imageName]];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

@end
