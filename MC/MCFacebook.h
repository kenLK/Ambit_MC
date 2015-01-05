//
//  MCFacebook.h
//  MC
//
//  Created by Ken on 2014/10/2.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MCVarible.h"
#import "MCFramework.h"
@interface MCFacebook : UIViewController<FBLoginViewDelegate>


@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSString *facebookID;

@property BOOL isLogin;

- (void)getUserInfoWithSuccess:(void (^)(id responseObject))success
                     failure:(void (^)(NSError *error))failure;
- (void)login:(void (^)(id responseObject))success
      failure:(void (^)(NSError *error))failure;

- (void)getUser:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

@end
