//
//  MCGooglePlus.m
//  MC
//
//  Created by Ken on 2014/11/5.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCGooglePlus.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface MCGooglePlus ()


@property (nonatomic, retain)    GPPSignIn *signIn;
@property (nonatomic, copy) void (^completionHandler)(UIBackgroundFetchResult fetchResult);
@property (nonatomic, retain)    GTLPlusPerson *person;

//GTLPlusPerson
@end

@implementation MCGooglePlus
@synthesize signIn,group,email,googlePlusID;
///google plus client id
static NSString * const kClientId = @"834759886613-u716johhr2nbc6hphmt3a984buoaekhc.apps.googleusercontent.com";

-(id) init {
    self = [super init];
    MCLogger(@"INTO  >>>>>>>> init ");
    if (self) {
        //        if ([MPVarible getInstance].isFirstUploadLoginInfo == nil) {
        //            [MPVarible getInstance].isFirstUploadLoginInfo = @"Y";
        //        }
    }
    MCLogger(@"END  >>>>>>>> init ");
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    MCLogger(@"viewDidLoad>>>>>>>INTO>>>>>>");
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCCONFIG" ofType:@"plist"];
    if (plistPath == nil) {
        MCLogger(@"<Parameter Setting> Properity list not found [error code:101]");
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    

    signIn = [GPPSignIn sharedInstance];
    // You previously set kClientId in the "Initialize the Google+ client" step
    if ([dict objectForKey:@"GooglePlus"] != nil) {
        signIn.clientID = [dict objectForKey:@"GooglePlus"];
        MCLogger(@"google+ api key:%@", [dict objectForKey:@"GooglePlus"]);
    } else {
        signIn.clientID = kClientId;
    }
    
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    signIn.shouldFetchGoogleUserID = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.delegate = self;
    
    [signIn authenticate];
    
    [signIn trySilentAuthentication];
    
    MCLogger(@"viewDidLoad>>>>>>>END>>>>>>");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    //取得 八大生活的註冊在mc的名稱
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCCONFIG" ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString* ottName = nil;
    if (plistPath == nil) {
        ottName = @"";
    }else{
        ottName = (NSString*)[dict objectForKey:@"OTT_NAME"];
    }
    
    if(!error) {
        // Get the email address.
        MCLogger(@"%@", signIn.authentication.userEmail);
        MCLogger(@"%@", signIn.authentication.userID);
        
        
        //information >>>>start
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                        MCLogger(@"Error: %@", error);
                    } else {
                        // Retrieve the display name and "about me" text
                        //                    [person retain];
                        NSString *description = [NSString stringWithFormat:
                                                 @"%@\n%@", person.displayName,
                                                 person.aboutMe];
                        MCLogger(@"%@",description);
                        MCLogger(@"userID>>>>%@<<<<",person.identifier);
                        [[NSUserDefaults standardUserDefaults] setObject:person.identifier forKey:@"googleUserID"];
                        [[NSUserDefaults standardUserDefaults] setObject:signIn.authentication.userEmail forKey:@"googleUserEMAIL"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        self.email = signIn.authentication.userEmail;
                        self.googlePlusID = person.identifier;
                        
                        //login to MC server
                        MCLogin* mcl = [[MCLogin alloc] init];
                        [mcl GetAmbitUserInfoViaOpenID:signIn.authentication.userEmail
                                               openUID:person.identifier
                                            login_type:LOGIN_TYPE_GOOGLE
                                                 sysID:ottName
                                               idGroup:nil
                                               success:^(id responseObject) {
//                                                   success(responseObject);
                                                   
                                               } failure:^(NSError *error) {

                                               }];
                        [self dismissViewControllerAnimated:YES completion:nil];

//                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:signIn.authentication.userEmail, @"EMAIL",person.identifier,@"GOOGLEUSERID",nil];
                    }
                }];
        //information >>>>ends
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
}


@end
