//
//  SXAdManager.m
//
//  Created by dongshangxian on 15/9/27.
//  Copyright © 2015年 ShangxianDante. All rights reserved.
//

#import "SXAdManager.h"
#import "SXNetworkTools.h"

#define kCachedCurrentImage ([[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingString:@"/adcurrent.png"])
#define kCachedNewImage     ([[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingString:@"/adnew.png"])

@interface SXAdManager ()

+ (void)downloadImage:(NSString *)imageUrl;

@end

@implementation SXAdManager

+ (BOOL)isShouldDisplayAd
{
    return ([[NSFileManager defaultManager]fileExistsAtPath:kCachedCurrentImage isDirectory:NULL] || [[NSFileManager defaultManager]fileExistsAtPath:kCachedNewImage isDirectory:NULL
]);
}

+ (UIImage *)getAdImage
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:kCachedNewImage isDirectory:NULL]) {
        [[NSFileManager defaultManager]removeItemAtPath:kCachedCurrentImage error:nil];
        [[NSFileManager defaultManager]moveItemAtPath:kCachedNewImage toPath:kCachedCurrentImage error:nil];
    }
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:kCachedCurrentImage]];
}

+ (void)downloadImage:(NSString *)imageUrl
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:imageUrl]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            [data writeToFile:kCachedNewImage atomically:YES];
        }
    }];
    [task resume];
}

+ (void)loadLatestAdImage
{
    NSString *path = [NSString stringWithFormat:@"%@/mobile/advertising/index?code=11001",HOST];
    
    [[[SXNetworkTools sharedNetworkToolsWithoutBaseUrl] GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
        
        SJLog(@"广告信息：%@",responseObject);
        if ([responseObject[@"states"] isEqualToString:@"1"])
        {
            NSArray *adArray = [responseObject valueForKey:@"data"];
            
            if (adArray.count)
            {
                NSString *imgUrl = [NSString stringWithFormat:@"http://common.csjimg.com/%@",adArray[0][@"img"]];
                [[NSUserDefaults standardUserDefaults] setValue:adArray[0][@"url"] forKey:kAdUrlStr];
                NSString *imgUrl2 = nil;
                if (adArray.count >1) {
                    int random = arc4random()%adArray.count;
                    imgUrl2= [NSString stringWithFormat:@"http://common.csjimg.com/%@",adArray[random][@"img"]];
                    [[NSUserDefaults standardUserDefaults] setValue:adArray[random][@"url"] forKey:kAdUrlStr];
                }
                
                BOOL one = [[NSUserDefaults standardUserDefaults]boolForKey:@"one"];
                if (imgUrl2.length > 0) {
                    if (one) {
                        [self downloadImage:imgUrl];
                        [[NSUserDefaults standardUserDefaults]setBool:!one forKey:@"one"];
                    }else{
                        [self downloadImage:imgUrl2];
                        [[NSUserDefaults standardUserDefaults]setBool:!one forKey:@"one"];
                    }
                }else{
                    [self downloadImage:imgUrl];
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        SJLog(@"%@",error);
    }] resume];
}

@end
