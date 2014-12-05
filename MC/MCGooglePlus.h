//
//  MCGooglePlus.h
//  MC
//
//  Created by Ken on 2014/11/5.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "MCFramework.h"
@interface MCGooglePlus : UIViewController<GPPSignInDelegate>

@property (nonatomic, retain)    dispatch_group_t group;

- (void)getUserInfoWithSuccess:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;

@end
