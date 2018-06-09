//
//  SJAddReferenceContentView.m
//  CaiShiJie
//
//  Created by user on 16/3/30.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJAddReferenceContentView.h"

@interface SJAddReferenceContentView ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView0;
@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgView2;
@property (weak, nonatomic) IBOutlet UIImageView *imgView3;

@end

@implementation SJAddReferenceContentView

- (IBAction)ClickAddImageButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAddImageButton)])
    {
        [self.delegate didClickAddImageButton];
    }
}

- (void)setImageArr:(NSArray *)imageArr
{
    _imageArr = imageArr;
    
    [self clearImageView];
    
    for (int i = 0; i < self.imageArr.count; i++)
    {
        switch (i) {
            case 0:
                _imgView0.image = self.imageArr[i];
                break;
            case 1:
                _imgView1.image = self.imageArr[i];
                break;
            case 2:
                _imgView2.image = self.imageArr[i];
                break;
            case 3:
                _imgView3.image = self.imageArr[i];
                break;
                
            default:
                break;
        }
    }
}

- (void)clearImageView
{
    _imgView0.image = nil;
    _imgView1.image = nil;
    _imgView2.image = nil;
    _imgView3.image = nil;
}

@end
