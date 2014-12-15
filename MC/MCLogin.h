//
//  MCLogin.h
//  MC
//
//  Created by Ken on 2014/10/3.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCVarible.h"
#import "AFNetworking.h"
#import "MCConstants.h"
#import "AFNetworkActivityLogger.h"
@interface MCLogin : UIViewController<UIWebViewDelegate>

@property (retain) NSMutableString *mFlag;
@property (nonatomic, retain) UIWebView *mWebView;

@property (strong, nonatomic) NSDictionary *loginResultJSON;

@property (strong, nonatomic) NSDictionary *loginResultHTML;

-(NSString*) GetAmbitUserInfoViaBase:(NSString *) account
                        userPassword:(NSString *)userPassword
                               sysID:(NSString*) sysID;


-(NSString*) GetAmbitUserInfoViaOpenID:(NSString *) email
                               openUID:(NSString *)openUID
                            login_type:(NSString*)login_type
                                 sysID:(NSString*) sysID
                               success:(void (^)(id responseObject))success
                               failure:(void (^)(NSError *error))failure;


-(NSString*) RegisterAmbitUserInfoViaBasic:(NSString *) login_type
                             registerValue:(NSDictionary *)regValue;

-(NSString*) RegisterAmbitUserInfoViaOpenID:(NSString *) login_type
                                    registerValue:(NSDictionary *)regValue;


-(id) initBasicDuplicate: (UIWebView*) web
             toURL: (NSString*) url;

-(id) initOpenIDDuplicate: (UIWebView*) web
               toURL: (NSString*) url;

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;

- (BOOL) getLoginResult;
@property (assign) NSString *returnJason;


-(NSString*) GetAPTGUserInfoViaBase:(NSString *) account
                        userPassword:(NSString *)userPassword
                               sysID:(NSString*) sysID;

-(id) initAPTGWithWebView: (UIWebView*) web;
@end
