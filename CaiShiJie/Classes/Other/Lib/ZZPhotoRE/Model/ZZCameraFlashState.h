//
//  ZZCameraFlashState.h
//  ZZPhotoKit
//
//  Created by Yuan on 16/1/22.
//  Copyright © 2018年 Ace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZCameraFlashState : NSObject

+(ZZCameraFlashState *)flashState;

-(BOOL)flashLightState;
-(void)isOpen:(BOOL)isState;
@end
