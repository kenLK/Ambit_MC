//
//  MCVarible.h
//  MC
//
//  Created by Ken on 2014/10/3.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "MCLog.h"

@interface MCVarible : NSObject


@property (nonatomic, retain) NSString* gameID;
@property (nonatomic, retain) NSString* gID;
@property (nonatomic, retain) NSString* serverID;
@property (nonatomic, retain) NSString* roleID;
@property (nonatomic, retain) NSString* useServerURL;
@property (nonatomic, retain) NSString* isFirstUploadLoginInfo;
@property (nonatomic, retain) NSString* verifyPKEY;
@property (nonatomic, retain) NSString* deviceToken;

@property (assign) BOOL isAppStoreBlockActivate;
@property (assign) BOOL isVerifyBlockActivate;
//@property (nonatomic, retain) MPStoreObserver *observer;
@property (assign) BOOL isDebugMode;

+ (MCVarible*) getInstance;

- (BOOL) initURLList;

-(NSString*)sha1:(NSString*)input;

@end
