//
//  MCYahoo.h
//  MC
//
//  Created by focusardi on 2014/11/26.
//  Copyright (c) 2014年 Ken. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YahooSDK.h"
#import "MCFramework.h"

@interface MCYahoo : UIViewController
@property (strong, nonatomic) NSDictionary *userProfile;
//- (void)setUserProfile:(NSDictionary *)userProfile;

- (void)getUserInfoWithSuccess:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;

@end