//
//  MCYahoo.m
//  MC
//
//  Created by focusardi on 2014/11/26.
//  Copyright (c) 2014年 Ken. All rights reserved.
//




#import "MCYahoo.h"


@interface MCYahoo()



@end

@implementation MCYahoo
@synthesize userProfile;

-(id) init {
    self = [super init];
    MCLogger(@"INTO  >>>>>>>> Yahoo init ");
    if (self) {
        //        if ([MPVarible getInstance].isFirstUploadLoginInfo == nil) {
        //            [MPVarible getInstance].isFirstUploadLoginInfo = @"Y";
        //        }
    }
    MCLogger(@"END  >>>>>>>> Yahoo init ");
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
//
//-(void)setUserProfile:(NSDictionary *)userProfile {
//    NSLog(@"setUserProfile");
//    
//    self.userProfile = userProfile;
//    MCLogger(@"setUserProfile>>>>>>>END>>>>>>");
//}

-(void)getUserInfoWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
     NSLog(@"getUserInfoWithSuccess");
    //information >>>>start
    if (self.userProfile == nil) {
        failure([NSError errorWithDomain:@"MCYahoo" code:-100 userInfo:self.userProfile]);
    }
    
    NSDictionary *userProfile2 = self.userProfile[@"profile"];
    
    if (userProfile2) {
        NSLog(@"User profile fetched");
        NSLog(@"%@",userProfile2);
        
        // Check e-mail
        NSString *yahooGuid = userProfile2[@"guid"];
        
        NSLog(@"Yahoo GUID: %@", yahooGuid);
        
        NSArray *emails = userProfile2[@"emails"];
        NSString *yahooEmail = @"";
        
        for (int i = 0;i < emails.count; i++){
            
            MCLogger(@"email>>>>>%@", emails[i][@"handle"]);
            
            NSRange range = [emails[i][@"handle"] rangeOfString:@"@yahoo.com"];
            MCLogger(@"email>>>>>%d", range.location);
            
            if (range.length > 0) {
                MCLogger(@">>%d",i);
                yahooEmail = emails[i][@"handle"];
                break;
            }
            
            if (i == emails.count - 1) {
                yahooEmail = emails[0][@"handle"];
            }
        }
        
        if ([@"" isEqualToString:yahooGuid]) {
            failure([NSError errorWithDomain:@"MCYahoo" code:-300 userInfo:self.userProfile]);
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:yahooGuid forKey:@"yahooGuid"];
        [params setValue:yahooEmail forKey:@"yahooEmail"];
        success(params);
        
        
    } else {
        
        failure([NSError errorWithDomain:@"MCYahoo" code:-200 userInfo:self.userProfile]);
    }

    
}

@end
