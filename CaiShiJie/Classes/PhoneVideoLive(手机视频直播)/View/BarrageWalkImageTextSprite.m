//
//  BarrageWalkImageTextSprite.m
//  CaiShiJie
//
//  Created by user on 18/8/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import "BarrageWalkImageTextSprite.h"

@interface BarrageWalkImageTextSprite ()

@end

@implementation BarrageWalkImageTextSprite

- (UIView *)bindingView {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 1;
    label.attributedText = self.attributedText;
    [label sizeToFit];
    
    return label;
}

@end
