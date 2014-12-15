//
//  MCLogin.m
//  MC
//
//  Created by Ken on 2014/10/3.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCLogin.h"
@interface MCLogin(){
}
@property (retain) NSUserDefaults *userPrefs;
@property (assign) BOOL mLoginResult;
@end

@implementation MCLogin


@synthesize loginResultJSON,loginResultHTML,mFlag,userPrefs,mLoginResult,returnJason;

-(id) init {
    self = [super init];
    MCLogger(@"INTO  >>>>>>>> init ");
    if (self) {
        userPrefs = [NSUserDefaults standardUserDefaults];
//        gVar = [MPVarible getInstance];
        //        if ([MPVarible getInstance].isFirstUploadLoginInfo == nil) {
        //            [MPVarible getInstance].isFirstUploadLoginInfo = @"Y";
        //        }
        if ([MCVarible getInstance].useServerURL == nil) {
            [[MCVarible getInstance] initURLList];
        }
    }
    MCLogger(@"END  >>>>>>>> init ");
    return self;
}

-(NSString*) GetAmbitUserInfoViaBase:(NSString *) account password:(NSString *) password sysID:(NSString*) sysID{
    MCVarible* mcv = [MCVarible getInstance];
    //sysid,login_type,uid
//    NSString* verifyStr = [NSString stringWithFormat:@"%@%@%@",email,uid,uid];
//    NSString* verifyCode = [mcv sha1:verifyStr];
    NSString* returnStr = @"";
    
    NSRange range = [account rangeOfString:@"@"];
    
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",[MCVarible getInstance].useServerURL,SDKUserLogin];
    urlString = [urlString stringByAppendingFormat:@"SYS_ID=%@&",sysID];
    urlString = [urlString stringByAppendingFormat:@"USER_PASSWORD=%@&",password];
    
    MCLogger(@"range====0.0==>%d",range.location);
    
    MCLogger(@"range====1.0==>%@",account);
    if (range.location == NSNotFound) {
        urlString = [urlString stringByAppendingFormat:@"PHONE=%@&",account];
    }else{
        urlString = [urlString stringByAppendingFormat:@"EMAIL=%@&",account];
    }
    
    
    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    
    if(data != nil && !error && responseCode == 200){
        MCLogger(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return returnStr;
}


-(NSString*) GetAmbitUserInfoViaOpenID:(NSString *)email
                               openUID:(NSString *)openUID
                            login_type:(NSString *)login_type
                                 sysID:(NSString *)sysID
                               success:(void (^)(id responseObject))success
                               failure:(void (^)(NSError *error))failure
{
    MCVarible* mcv = [MCVarible getInstance];
    //sysid,login_type,uid
    NSString* verifyStr = [NSString stringWithFormat:@"%@%@%@%@",sysID,login_type,openUID,VERIFY_SECRET_KEY];
    MCLogger(@"verifyStr>>>>>>>%@<<<",verifyStr);
    NSString* verifyCode = [mcv sha1:verifyStr];
    MCLogger(@"verifyStr>sha1>>>>>>>%@<<<",verifyCode);
    // Create NSData object
    NSData *nsdata = [verifyCode dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    MCLogger(@"verifyStr>base64Encoded>>>>>>>%@<<<",base64Encoded);
    //replace string
    base64Encoded = [base64Encoded stringByReplacingOccurrencesOfString:@"+" withString:@"."];
    base64Encoded = [base64Encoded stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64Encoded = [base64Encoded stringByReplacingOccurrencesOfString:@"=" withString:@"-"];

    
    MCLogger(@"base64Encoded replace +/=>>>>>>>%@<<<",base64Encoded);
    NSString* returnStr = @"";
    
    if ([MCVarible getInstance].useServerURL == nil) {
        [[MCVarible getInstance] initURLList];
    }
    
    MCLogger(@"useServerURL>>>>>>>%@",mcv.useServerURL);
    //AFNetwork loggin
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    // 1
    NSURL *baseURL = [NSURL URLWithString:mcv.useServerURL];
    NSDictionary *parameters = @{@"SYS_ID": sysID,
                                 @"LOGIN_TYPE": login_type,
                                 @"LOGIN_UID": openUID,
                                 @"EMAIL": email,
                                 @"VALID_STR": base64Encoded};
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:sysID forKey:@"SYS_ID"];
    [params setValue:login_type forKey:@"LOGIN_TYPE"];
    [params setValue:openUID forKey:@"LOGIN_UID"];
    [params setValue:email forKey:@"EMAIL"];
    [params setValue:base64Encoded forKey:@"VALID_STR"];

    
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",[MCVarible getInstance].useServerURL,SDKOauthLogin];
    urlString = [urlString stringByAppendingFormat:@"SYS_ID=%@&",sysID];
    urlString = [urlString stringByAppendingFormat:@"LOGIN_TYPE=%@&",login_type];
    urlString = [urlString stringByAppendingFormat:@"LOGIN_UID=%@&",openUID];
    urlString = [urlString stringByAppendingFormat:@"EMAIL=%@&",email];
    urlString = [urlString stringByAppendingFormat:@"VALID_STR=%@&",base64Encoded];

    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    
    if(data != nil && !error && responseCode == 200){
            MCLogger(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        success(data);
    }
    
    
    return returnStr;
}
/*
 
 -(id) initWithWebView: (UIWebView*) web forState: (NSString*) state withVersion: (NSString *) version{
 MPLogger(@"INTO >>>>>> initWithWebView");
 MPLogger(@"<initWithWebView state> %@ \n", state);
 
 self = [self init];
 if (self) {
 gVar = [MPVarible getInstance];
 [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
 version = version;
 if ([self initialFramework] == YES) {
 [self setMLoginResult:NO];
 [self setMWebView:web];
 [self setURL:state];
 mFlag = [[NSMutableString alloc] init];
 userPrefs = [NSUserDefaults standardUserDefaults];
 
 if ([version isEqualToString:@"0"] || version == nil) {
 version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
 }
 
 [self versionUpdaterUseURL: version];
 
 MPLogger(@"<Version code> Version: %@", version);
 }
 }
 MPLogger(@"END >>>>>> initWithWebView");
 return self;
 }
 */

-(id)initBasicDuplicate:(UIWebView *)web toURL:(NSString *)url{
    MCLogger(@"INTO >>>>>> initBasicDuplicate");
    
    self = [self init];
    if (self) {
        MCVarible* gVar = [MCVarible getInstance];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

        if (self) {
//        if ([self initialFramework] == YES) {
//            [self setMLoginResult:NO];
            [self setMWebView:web];
            [self setURL:url];
            mFlag = [[NSMutableString alloc] init];
            userPrefs = [NSUserDefaults standardUserDefaults];
            
/*            if ([version isEqualToString:@"0"] || version == nil) {
                version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            }*/
            
//            [self versionUpdaterUseURL: version];
            
//            MCLogger(@"<Version code> Version: %@", version);
        }
    }
    MCLogger(@"END >>>>>> initBasicDuplicate");
    return self;
}
-(id)initOpenIDDuplicate:(UIWebView *)web toURL:(NSString *)url{

    MCLogger(@"INTO >>>>>> initOpenIDDuplicate");
    
    self = [self init];
    if (self) {
        MCVarible* gVar = [MCVarible getInstance];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        if (self) {
            //        if ([self initialFramework] == YES) {
            //            [self setMLoginResult:NO];
            [self setMWebView:web];
            [self setURL:url];
            mFlag = [[NSMutableString alloc] init];
            userPrefs = [NSUserDefaults standardUserDefaults];
            
            /*            if ([version isEqualToString:@"0"] || version == nil) {
             version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
             }*/
            
            //            [self versionUpdaterUseURL: version];
            
            //            MCLogger(@"<Version code> Version: %@", version);
        }
    }
    MCLogger(@"END >>>>>> initOpenIDDuplicate");
    return self;
}


- (void)webViewDidFinishLoad {
    MCLogger(@"INTO >>>>>> webViewDidFinishLoad");
    
    [mFlag setString:[self.mWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('flag').value"]];
    MCLogger(@"INTO >>>>>> webViewDidFinishLoad mFlag %@",mFlag);
    
    if ([mFlag isEqualToString:@"login"]) {
        
        if ([userPrefs objectForKey:@"user_account"] == nil && [userPrefs objectForKey:@"user_password"] == nil) {
            [userPrefs setObject:@"" forKey:@"user_account"];
            [userPrefs setObject:@"" forKey:@"user_password"];
            [userPrefs synchronize];
        }
        
        if ([userPrefs objectForKey:@"user_autologin"] == NULL) {
            [userPrefs setObject:@"true" forKey:@"user_autologin"];
            [userPrefs synchronize];
        }
        
        [self.mWebView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:
          @"insertAccount('%@', '%@', '%@', '%@', 'iOS', '%@', 'APPSTORE')",
          [userPrefs objectForKey:@"user_account"],
          [userPrefs objectForKey:@"user_password"],
          [userPrefs objectForKey:@"user_token"],
          [userPrefs objectForKey:@"user_autologin"],
//          gVar.gameID]];
          @""]];
    }
    
    if ([mFlag isEqualToString:@"loginNew"]) {
        
        if ([userPrefs objectForKey:@"user_account"] == nil && [userPrefs objectForKey:@"user_password"] == nil) {
            [userPrefs setObject:@"" forKey:@"user_account"];
            [userPrefs setObject:@"" forKey:@"user_password"];
            [userPrefs synchronize];
        }
        
        if ([userPrefs objectForKey:@"user_autologin"] == NULL) {
            [userPrefs setObject:@"true" forKey:@"user_autologin"];
            [userPrefs synchronize];
        }
        
        //        [self.mWebView stringByEvaluatingJavaScriptFromString:
        //         [NSString stringWithFormat:
        //          @"insertAccount('%@', '%@', '%@', '%@', 'iOS', '%@', 'APPSTORE')",
        //                [userPrefs objectForKey:@"user_account"],
        //                [userPrefs objectForKey:@"user_password"],
        //                [userPrefs objectForKey:@"user_token"],
        //                [userPrefs objectForKey:@"user_autologin"],
        //                gVar.gameID]];
        //        gameId, deviceId, os, pgid, isBundling
        // isBundling 讀檔 start
        //取得檔案路徑
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingString:@"/data.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *plistDict;
        if ([fileManager fileExistsAtPath: filePath]) //檢查檔案是否存在
        {
            plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        }else{
            plistDict = [[NSMutableDictionary alloc] init];
        }
        NSString *isBundling = [plistDict objectForKey:@"isBundling"];
        NSString *pgid = [plistDict objectForKey:@"pgid"];
        // isBundling 讀檔 end
        //        NSString* uuidString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //        NSString* uuidString = [self getDeviceID];    20131129
/*        [MPKeyChainValue checkUUID];
        NSString* uuidString = [MPKeyChainValue readUUID];
        [self.mWebView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:
          @"insertAccountNew('%@', '%@', 'iOS', '%@', '%@')",
          gVar.gameID,
          uuidString,
          pgid,
          isBundling]];
        MCLogger(@"insertAccountNew('%@', '%@', 'iOS', '%@', '%@')",
                 gVar.gameID,
                 uuidString,
                 pgid,
                 isBundling);
        */
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    //    NSString *yourHTMLSourceCodeString = [self.mWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    //    MCLogger(@"INTO >>>>>> HTML CODE %@",yourHTMLSourceCodeString);
    MCLogger(@"INTO >>>>>> iosapp >>>> 0.0 start %@ ",[self.mWebView.request.URL absoluteString]);
    if ([[self.mWebView.request.URL absoluteString] hasPrefix:@"iosapp"]) {
        MCLogger(@"INTO >>>>>> iosapp >>>> 1.0 start");
        NSArray *components = [[self.mWebView.request.URL absoluteString] componentsSeparatedByString:@":"];
        if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"iosapp"]) {
            
            if([(NSString *)[components objectAtIndex:1] isEqualToString:@"myfunction"]) {
                [userPrefs setObject:[components objectAtIndex:2] forKey:@"bundlingJason"];
                [userPrefs synchronize];
                [self setMLoginResult:YES];
                /*
                if ([[components objectAtIndex:4] isEqualToString:@"0"]) {
                    [userPrefs setObject:[components objectAtIndex:2] forKey:@"user_token"];
                    [userPrefs setObject:[components objectAtIndex:3] forKey:@"user_gid"];
                    [userPrefs synchronize];
//                    [self setMLoginResult:YES];
                }*/
            }
        
        }
        MCLogger(@"END >>>>>> iosapp >>>> end");
    }
    
    //  1021
    //    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    
    MCLogger(@"END >>>>>> webViewDidFinishLoad");
    
}




- (BOOL)shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    MCLogger(@"INTO >>>>>> shouldStartLoadWithRequest");
    NSString *requestString = [[request URL] absoluteString];
    if (navigationType == UIWebViewNavigationTypeFormSubmitted && [mFlag isEqualToString:@"login"]) {
        NSString *autoLogin = [self.mWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('autologin').checked"];
        
        if ([autoLogin isEqualToString:@"false"]) {
//            [self clearData];
        } else if ([autoLogin isEqualToString:@"true"]) {
            NSString *account = [self.mWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('account').value"];
            NSString *pwd = [self.mWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('pwd').value"];
            [userPrefs setObject:account forKey:@"user_account"];
            [userPrefs setObject:pwd forKey:@"user_password"];
        }
        [userPrefs setObject:autoLogin forKey:@"user_autologin"];
        [userPrefs synchronize];
        MCLogger(@"END >>>>>> shouldStartLoadWithRequest");
        return YES;
    }
    MCLogger(@">>>>>> shouldStartLoadWithRequest  >>>>>>>%@",requestString);
    NSRange startRange = [requestString rangeOfString:@"iosapp"];
    
//    if ([requestString hasPrefix:@"iosapp"]) {
    if (startRange.location  != NSNotFound) {
        requestString = [requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSRange startRange = [requestString rangeOfString:@"iosapp"];
        if (startRange.location != -1) {
            requestString = [requestString substringFromIndex:startRange.location];
        }
        
        NSArray *components = [requestString componentsSeparatedByString:@"#"];
        if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"iosapp"]) {
            
            if([(NSString *)[components objectAtIndex:1] isEqualToString:@"myfunction"]) {
                MCLogger(@"bundlingJason>>>>>>>%@",[components objectAtIndex:2]);
                self.returnJason = (NSString*)[components objectAtIndex:2];
                [userPrefs setObject:[components objectAtIndex:2] forKey:@"returnJason"];
                [userPrefs synchronize];
                [self setMLoginResult:YES];
                /*if ([[components objectAtIndex:4] isEqualToString:@"0"]) {
                    [userPrefs setObject:[components objectAtIndex:2] forKey:@"user_token"];
                    [userPrefs setObject:[components objectAtIndex:3] forKey:@"user_gid"];
                    [userPrefs synchronize];
                    [self setMLoginResult:YES];
                }*/
            }
        }
        
        MCLogger(@"END >>>>>> shouldStartLoadWithRequest");
        return NO;
    }
    
    MCLogger(@"END >>>>>> shouldStartLoadWithRequest");
    return YES;
}
-(NSString*)RegisterAmbitUserInfoViaOpenID:(NSString *)login_type registerValue:(NSDictionary *)regValue{
    MCLogger(@">>>>>RegisterAmbitUserInfoViaOpenID>>>>>>>>>>>>>>INTO>>>>>>>>");
    //OpenID 專用
    
    NSString* loginUID = [self objectForKeyOrNil:[regValue objectForKey:@"LOGIN_UID"]];//appid
    NSString* checkDate = [self objectForKeyOrNil:[regValue objectForKey:@"CHECK_DATE"]];
    NSString* vaildSTR = [self objectForKeyOrNil:[regValue objectForKey:@"VALID_STR"]];
    NSString* vaildEmailStr = [self objectForKeyOrNil:[regValue objectForKey:@"VALID_EMAIL_STR"]];
    
    NSString* sysID = [self objectForKeyOrNil:[regValue objectForKey:@"SYS_ID"]];
//    NSString* email = [self objectForKeyOrNil:[regValue objectForKey:@"EMAIL"]];
    
    //共用
    NSString* ADDR = [self objectForKeyOrNil:[regValue objectForKey:@"ADDR"]];
    NSString* BRITH_DATE = [self objectForKeyOrNil:[regValue objectForKey:@"BRITH_DATE"]];
    if ([BRITH_DATE isEqualToString:@""]) {
        BRITH_DATE = @"20141001";
    }
    NSString* EMAIL = [self objectForKeyOrNil:[regValue objectForKey:@"EMAIL"]];
    NSString* EMPLOYEE_NUMBER = [self objectForKeyOrNil:[regValue objectForKey:@"EMPLOYEE_NUMBER"]];
    NSString* ENG_NM = [self objectForKeyOrNil:[regValue objectForKey:@"ENG_NM"]];
    NSString* ENTERPRISE_CUSTOMER = [self objectForKeyOrNil:[regValue objectForKey:@"ENTERPRISE_CUSTOMER"]];
    if ([ENTERPRISE_CUSTOMER isEqualToString:@""]) {
        ENTERPRISE_CUSTOMER = @"N";
    }
    
    NSString* HSN_NM = [self objectForKeyOrNil:[regValue objectForKey:@"HSN_NM"]];
    
    NSString* IDN_BAN = [self objectForKeyOrNil:[regValue objectForKey:@"IDN_BAN"]];
    NSString* PHONE = [self objectForKeyOrNil:[regValue objectForKey:@"PHONE"]];
    NSString* SEX = [self objectForKeyOrNil:[regValue objectForKey:@"SEX"]];
    NSString* TERM_CHECK_FLAG = [self objectForKeyOrNil:[regValue objectForKey:@"TERM_CHECK_FLAG"]];
    NSString* TOWN_NM = [self objectForKeyOrNil:[regValue objectForKey:@"TOWN_NM"]];
    NSString* USER_NAME = [self objectForKeyOrNil:[regValue objectForKey:@"USER_NAME"]];
    NSString* USER_NM = [self objectForKeyOrNil:[regValue objectForKey:@"USER_NM"]];
    NSString* USER_PASSWORD = [self objectForKeyOrNil:[regValue objectForKey:@"USER_PASSWORD"]];
    NSString* USER_TYPE = [self objectForKeyOrNil:[regValue objectForKey:@"USER_TYPE"]];
    NSString* ZIP = [self objectForKeyOrNil:[regValue objectForKey:@"ZIP"]];
    if ([ZIP isEqualToString:@""]) {
        ZIP = @"110";
    }
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",[MCVarible getInstance].useServerURL,SDKOauthRegister];
    urlString = [urlString stringByAppendingFormat:@"SYS_ID=%@&",sysID];
    urlString = [urlString stringByAppendingFormat:@"LOGIN_TYPE=%@&",login_type];
    urlString = [urlString stringByAppendingFormat:@"LOGIN_UID=%@&",loginUID];
    urlString = [urlString stringByAppendingFormat:@"EMAIL=%@&",EMAIL];
    urlString = [urlString stringByAppendingFormat:@"VALID_STR=%@&",vaildSTR];
    urlString = [urlString stringByAppendingFormat:@"CHECK_DATE=%@&",checkDate];
    urlString = [urlString stringByAppendingFormat:@"VALID_EMAIL_STR=%@&",vaildEmailStr];
    
    urlString = [urlString stringByAppendingFormat:@"ADDR=%@&",ADDR];
    urlString = [urlString stringByAppendingFormat:@"BRITH_DATE=%@&",BRITH_DATE];
    urlString = [urlString stringByAppendingFormat:@"EMPLOYEE_NUMBER=%@&",EMPLOYEE_NUMBER];
    urlString = [urlString stringByAppendingFormat:@"ENG_NM=%@&",ENG_NM];
    urlString = [urlString stringByAppendingFormat:@"ENTERPRISE_CUSTOMER=%@&",ENTERPRISE_CUSTOMER];
    urlString = [urlString stringByAppendingFormat:@"HSN_NM=%@&",HSN_NM];
    urlString = [urlString stringByAppendingFormat:@"IDN_BAN=%@&",IDN_BAN];
    urlString = [urlString stringByAppendingFormat:@"PHONE=%@&",PHONE];
    urlString = [urlString stringByAppendingFormat:@"SEX=%@&",SEX];
    urlString = [urlString stringByAppendingFormat:@"TERM_CHECK_FLAG=%@&",TERM_CHECK_FLAG];
    urlString = [urlString stringByAppendingFormat:@"TOWN_NM=%@&",TOWN_NM];
    urlString = [urlString stringByAppendingFormat:@"USER_NAME=%@&",USER_NAME];
    urlString = [urlString stringByAppendingFormat:@"USER_NM=%@&",USER_NM];
    urlString = [urlString stringByAppendingFormat:@"USER_PASSWORD=%@&",USER_PASSWORD];
    urlString = [urlString stringByAppendingFormat:@"USER_TYPE=%@&",USER_TYPE];
    urlString = [urlString stringByAppendingFormat:@"ZIP=%@&",ZIP];
    
    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    NSString* resultJSON = @"";

    if(data != nil && !error && responseCode == 200){
        resultJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        MCLogger(@"%@",resultJSON);
        //        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    
    MCLogger(@">>>>>RegisterAmbitUserInfoViaOpenID>>>>>>>>>>>>>>END>>>>>>>>");
    return resultJSON;
}

-(NSString*)RegisterAmbitUserInfoViaBasic:(NSString *)login_type registerValue:(NSDictionary *)regValue{
    MCLogger(@">>>>>RegisterAmbitUserInfoViaOpenID>>>>>>>>>>>>>>INTO>>>>>>>>");
    //OpenID 專用
    
    NSString* loginUID = [self objectForKeyOrNil:[regValue objectForKey:@"LOGIN_UID"]];//appid
    NSString* checkDate = [self objectForKeyOrNil:[regValue objectForKey:@"CHECK_DATE"]];
    NSString* vaildSTR = [self objectForKeyOrNil:[regValue objectForKey:@"VALID_STR"]];
    NSString* vaildEmailStr = [self objectForKeyOrNil:[regValue objectForKey:@"VALID_EMAIL_STR"]];
    
    NSString* sysID = [self objectForKeyOrNil:[regValue objectForKey:@"SYS_ID"]];
    //    NSString* email = [self objectForKeyOrNil:[regValue objectForKey:@"EMAIL"]];
    
    //共用
    NSString* ADDR = [self objectForKeyOrNil:[regValue objectForKey:@"ADDR"]];
    NSString* BRITH_DATE = [self objectForKeyOrNil:[regValue objectForKey:@"BRITH_DATE"]];
    if ([BRITH_DATE isEqualToString:@""]) {
        BRITH_DATE = @"20141001";
    }
    NSString* EMAIL = [self objectForKeyOrNil:[regValue objectForKey:@"EMAIL"]];
    NSString* EMPLOYEE_NUMBER = [self objectForKeyOrNil:[regValue objectForKey:@"EMPLOYEE_NUMBER"]];
    NSString* ENG_NM = [self objectForKeyOrNil:[regValue objectForKey:@"ENG_NM"]];
    NSString* ENTERPRISE_CUSTOMER = [self objectForKeyOrNil:[regValue objectForKey:@"ENTERPRISE_CUSTOMER"]];
    if ([ENTERPRISE_CUSTOMER isEqualToString:@""]) {
        ENTERPRISE_CUSTOMER = @"N";
    }
    
    NSString* HSN_NM = [self objectForKeyOrNil:[regValue objectForKey:@"HSN_NM"]];
    
    NSString* IDN_BAN = [self objectForKeyOrNil:[regValue objectForKey:@"IDN_BAN"]];
    NSString* PHONE = [self objectForKeyOrNil:[regValue objectForKey:@"PHONE"]];
    NSString* SEX = [self objectForKeyOrNil:[regValue objectForKey:@"SEX"]];
    NSString* TERM_CHECK_FLAG = [self objectForKeyOrNil:[regValue objectForKey:@"TERM_CHECK_FLAG"]];
    NSString* TOWN_NM = [self objectForKeyOrNil:[regValue objectForKey:@"TOWN_NM"]];
    NSString* USER_NAME = [self objectForKeyOrNil:[regValue objectForKey:@"USER_NAME"]];
    NSString* USER_NM = [self objectForKeyOrNil:[regValue objectForKey:@"USER_NM"]];
    NSString* USER_PASSWORD = [self objectForKeyOrNil:[regValue objectForKey:@"USER_PASSWORD"]];
    NSString* USER_TYPE = [self objectForKeyOrNil:[regValue objectForKey:@"USER_TYPE"]];
    NSString* ZIP = [self objectForKeyOrNil:[regValue objectForKey:@"ZIP"]];
    if ([ZIP isEqualToString:@""]) {
        ZIP = @"110";
    }
    NSString* CALLING_COUNTRY_CODE = [self objectForKeyOrNil:[regValue objectForKey:@"CALLING_COUNTRY_CODE"]];
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",[MCVarible getInstance].useServerURL,SDKRegister];
    urlString = [urlString stringByAppendingFormat:@"SYS_ID=%@&",sysID];
    urlString = [urlString stringByAppendingFormat:@"LOGIN_TYPE=%@&",login_type];
    urlString = [urlString stringByAppendingFormat:@"LOGIN_UID=%@&",loginUID];
    urlString = [urlString stringByAppendingFormat:@"EMAIL=%@&",EMAIL];
    urlString = [urlString stringByAppendingFormat:@"VALID_STR=%@&",vaildSTR];
    urlString = [urlString stringByAppendingFormat:@"CHECK_DATE=%@&",checkDate];
    urlString = [urlString stringByAppendingFormat:@"VALID_EMAIL_STR=%@&",vaildEmailStr];
    
    urlString = [urlString stringByAppendingFormat:@"ADDR=%@&",ADDR];
    urlString = [urlString stringByAppendingFormat:@"BRITH_DATE=%@&",BRITH_DATE];
    urlString = [urlString stringByAppendingFormat:@"EMPLOYEE_NUMBER=%@&",EMPLOYEE_NUMBER];
    urlString = [urlString stringByAppendingFormat:@"ENG_NM=%@&",ENG_NM];
    urlString = [urlString stringByAppendingFormat:@"ENTERPRISE_CUSTOMER=%@&",ENTERPRISE_CUSTOMER];
    urlString = [urlString stringByAppendingFormat:@"HSN_NM=%@&",HSN_NM];
    urlString = [urlString stringByAppendingFormat:@"IDN_BAN=%@&",IDN_BAN];
    urlString = [urlString stringByAppendingFormat:@"PHONE=%@&",PHONE];
    urlString = [urlString stringByAppendingFormat:@"SEX=%@&",SEX];
    urlString = [urlString stringByAppendingFormat:@"TERM_CHECK_FLAG=%@&",TERM_CHECK_FLAG];
    urlString = [urlString stringByAppendingFormat:@"TOWN_NM=%@&",TOWN_NM];
    urlString = [urlString stringByAppendingFormat:@"USER_NAME=%@&",USER_NAME];
    urlString = [urlString stringByAppendingFormat:@"USER_NM=%@&",USER_NM];
    urlString = [urlString stringByAppendingFormat:@"USER_PASSWORD=%@&",USER_PASSWORD];
    urlString = [urlString stringByAppendingFormat:@"USER_TYPE=%@&",USER_TYPE];
    urlString = [urlString stringByAppendingFormat:@"ZIP=%@&",ZIP];
    urlString = [urlString stringByAppendingFormat:@"CALLING_COUNTRY_CODE=%@&",CALLING_COUNTRY_CODE];//CALLING_COUNTRY_CODE
    
    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    NSString* resultJSON = @"";
    
    if(data != nil && !error && responseCode == 200){
        resultJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        MCLogger(@"%@",resultJSON);
        //        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    
    MCLogger(@">>>>>RegisterAmbitUserInfoViaOpenID>>>>>>>>>>>>>>END>>>>>>>>");
    return resultJSON;
}
-(NSString*)GetAmbitUserInfoViaBase:(NSString *)account userPassword:(NSString *)userPassword sysID:(NSString *)sysID{
    
    MCLogger(@">>>>>RegisterAmbitUserInfoViaOpenID>>>>>>>>>>>>>>INTO>>>>>>>>");
    
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",[MCVarible getInstance].useServerURL,SDKUserLogin];
    urlString = [urlString stringByAppendingFormat:@"SYS_ID=%@&",sysID];
    urlString = [urlString stringByAppendingFormat:@"USER_PASSWORD=%@&",userPassword];
    
    NSRange range = [account rangeOfString:@"@"];
    
    
    MCLogger(@"location====0.0==>%d",range.location);
    
    if (range.length > 0) {
        
        urlString = [urlString stringByAppendingFormat:@"EMAIL=%@&",account];
    }else{
        urlString = [urlString stringByAppendingFormat:@"PHONE=%@&",account];
    }
    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    NSString* resultJSON = @"";
    
    if(data != nil && !error && responseCode == 200){
        resultJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        MCLogger(@"%@",resultJSON);
        //        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    
    MCLogger(@">>>>>RegisterAmbitUserInfoViaOpenID>>>>>>>>>>>>>>END>>>>>>>>");
    return resultJSON;
}
- (id)objectForKeyOrNil:(id)key {
//    id val = [self objectForKey:key];
    if (key == nil)
    {
        return @"";
    }
    return key;
}
- (BOOL) getLoginResult {
    return mLoginResult;
}
- (NSString*) GetAPTGUserInfoViaBase:(NSString *)account userPassword:(NSString *)userPassword sysID:(NSString *)sysID{
    MCVarible* mcv = [MCVarible getInstance];
    //sysid,login_type,uid
    //    NSString* verifyStr = [NSString stringWithFormat:@"%@%@%@",email,uid,uid];
    //    NSString* verifyCode = [mcv sha1:verifyStr];
    NSString* returnStr = @"";
    
    NSRange range = [account rangeOfString:@"@"];
    
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",[MCVarible getInstance].useServerURL,SDKAPTGUserLogin];
    urlString = [urlString stringByAppendingFormat:@"SYS_ID=%@&",sysID];
    urlString = [urlString stringByAppendingFormat:@"USER_PASSWORD=%@&",userPassword];
    urlString = [urlString stringByAppendingFormat:@"SDK=IOS&",userPassword];    
    MCLogger(@"range====0.0==>%d",range.location);
    
    MCLogger(@"range====1.0==>%@",account);
    if (range.length > 0) {
//        urlString = [urlString stringByAppendingFormat:@"PHONE=%@&",account];
        urlString = [urlString stringByAppendingFormat:@"EMAIL=%@&",account];
    }else{
        urlString = [urlString stringByAppendingFormat:@"PHONE=%@&",account];
    }
    
    
    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    
    if(data != nil && !error && responseCode == 200){
        MCLogger(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return returnStr;

}

-(id) initAPTGWithWebView: (UIWebView*) web{
    MCLogger(@"INTO >>>>>> initWithWebView");
    
    self = [self init];
    
    
    if (self) {
        MCVarible* gVar = [MCVarible getInstance];
        
        
        
        NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@?",gVar.useServerURL,SDKAPTGUserLogin];
        urlString = [urlString stringByAppendingFormat:@"SDK=IOS&"];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

//        if ([self initialFramework] == YES) {
            [self setMLoginResult:NO];
            [self setMWebView:web];
            [self setURL:urlString];
            mFlag = [[NSMutableString alloc] init];
            userPrefs = [NSUserDefaults standardUserDefaults];
            
        
//        }
    }
    MCLogger(@"END >>>>>> initWithWebView");
    return self;
}

#pragma mark -
#pragma mark Webview part

- (void) setURL: (NSString*) urlStr {
    MCLogger(@"INTO >>>>>> setURL>>>%@",urlStr);

    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.mWebView loadRequest:requestObj];
    MCLogger(@"END >>>>>> setURL");
}
@end
