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
@synthesize signIn,group;
///google plus client id
static NSString * const kClientId = @"1039948666930-tc2134amp1a1r836b5iq5lf2pnnq3s05.apps.googleusercontent.com";

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

    signIn = [GPPSignIn sharedInstance];
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
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
                        [self dismissViewControllerAnimated:YES completion:nil];

//                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:signIn.authentication.userEmail, @"EMAIL",person.identifier,@"GOOGLEUSERID",nil];
                    }
                }];
        //information >>>>ends
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
}
/*
- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    
    NSLog(@"%@",sourceApplication);

//    return NO;
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}*/
-(void)getUserInfoWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
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
                    failure(error);
                } else {
                    // Retrieve the display name and "about me" text
                    //                    [person retain];
                    NSString *description = [NSString stringWithFormat:
                                             @"%@\n%@", person.displayName,
                                             person.aboutMe];
                    MCLogger(@"%@",description);
                    MCLogger(@"userID>>>>%@<<<<",person.identifier);
                    [[NSUserDefaults standardUserDefaults] setObject:person.identifier forKey:@"googleUserID"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:signIn.authentication.userEmail, @"EMAIL",person.identifier,@"GOOGLEUSERID",nil];
                    success(dict);
                }
            }];
    //information >>>>ends

}

@end
