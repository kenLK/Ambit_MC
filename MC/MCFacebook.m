//
//  MCFacebook.m
//  MC
//
//  Created by Ken on 2014/10/2.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCFacebook.h"
@interface MCFacebook ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;

@property (strong, nonatomic) NSString *objectID;

@property (strong, nonatomic) ACAccountStore *accountStore;//ACAccountStore


@end

@implementation MCFacebook
@synthesize facebookID,email,isLogin;

- (id) init
{
    if (self = [super init])
    {
        self.facebookID = @""; // do your own initialisation here
        self.email = @"";
        self.isLogin = NO;
    }
    return self;
}
// ------------> Login code starts here <------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Create a FBLoginView to log the user in with basic, email and friend list permissions
        // You should ALWAYS ask for basic permissions (public_profile) when logging the user in
        FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
        
        // Set this loginUIViewController to be the loginView button's delegate
        loginView.delegate = self;
        
        // Align the button in the center horizontally
        loginView.frame = CGRectOffset(loginView.frame,
                                       (self.view.center.x - (loginView.frame.size.width / 2)),
                                       5);
//        loginView.frame = *(viewFrame);
        // Align the button in the center vertically
        loginView.center = self.view.center;
        
        // Add the button to the view
        [self.view addSubview:loginView];
        
    }
    return self;
}

- (void) viewDidLoad {
    /*
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) // check Facebook is configured in Settings or not
    {
        self.accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *facebookAcc = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        
        NSDictionary *options = @{
                                  @"ACFacebookAppIdKey" : @"1483100008608308",
                                  @"ACFacebookPermissionsKey" : @[@"email"],
                                  @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone}; // Needed only when write permissions are requested
        
        NSDictionary *emailReadPermisson = @{
                                             ACFacebookAppIdKey : @"1483100008608308",
                                             ACFacebookPermissionsKey : @[@"email"],
                                             ACFacebookAudienceKey : ACFacebookAudienceEveryone,
                                             };

        [self.accountStore requestAccessToAccountsWithType:facebookAcc options:emailReadPermisson completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 NSArray *accountsArray = [self.accountStore accountsWithAccountType:facebookAcc];
                 //[AppCommon hideProgressHUD];
                 NSDictionary *facebookAccount = [[self.accountStore accountsWithAccountType:facebookAcc] lastObject];
                 NSLog(@"facebook UserName: %@", [facebookAccount valueForKey:@"username"]);
                 
                 ACAccount *account = accountsArray[0];

                 NSString* userID = ((NSDictionary*)[account valueForKey:@"properties"])[@"user_id"];
                 [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"facebookUserID"];
                 [[NSUserDefaults standardUserDefaults] setObject:[facebookAccount valueForKey:@"username"] forKey:@"facebookUserEMAIL"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [self dismissViewControllerAnimated:YES completion:nil];
                 
                 MCLogger(@"facebookAcc>>>>>userID>>>>>>%@>>>>>>",userID);
             }
             else
             {
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                     UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"error" message:@"User Has disabled your app from settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
                 }
                 else
                 {
                     NSLog(@"Error in Login: %@", error);
                     
                     UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"error" message:@"login Fail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
                 }
             }
         }];
    }
    else
    {
        //[AppCommon hideProgressHUD];
        NSLog(@"Not Configured in Settings......"); // show user an alert view that facebook is not configured in settings.
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"error" message:@"Not Configured in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    */
}

- (NSString*)requestUserInfo
{
    // We will request the user's public picture and the user's birthday
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"public_profile", @"user_birthday",@"email"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // These are the current permissions the user has
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  
                                  // We will store here the missing permissions that we will have to request
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession
                                       requestNewReadPermissions:requestPermissions
                                       completionHandler:^(FBSession *session, NSError *error) {
                                           if (!error) {
                                               // Permission granted, we can request the user information
                                               [self makeRequestForUserData];
                                           } else {
                                               // An error occurred, we need to handle the error
                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                               NSLog(@"error %@", error.description);
                                           }
                                       }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestForUserData];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                                  [self fbResync];
                              }
                          }];
    
    // call server register user
    /*NSError* error = nil;
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@partner/api/getGameEnv?game_id=%@&version_code=%@&", [MCVarible getInstance].useServerURL,[MCVarible getInstance].gameID, @""];
    MCLogger(@"url====0.0==>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:20];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlrequest
                                         returningResponse:&response
                                                     error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    MCLogger(@"INTO >>>>>> %@ ",responseBody);
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    */

    
    return @"";
    
}

- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
//            NSError* jsonError = nil;
//            NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&jsonError];
            NSDictionary *userData = (NSDictionary *)result;
            if (userData) {
                NSString *birthday = userData[@"birthday"];
                NSString *facebookID = userData[@"id"];
                NSString *email = userData[@"email"];
                NSString *first_name = userData[@"first_name"];

                NSString *last_name = userData[@"last_name"];
                NSString *link = userData[@"link"];
                NSString *locale = userData[@"locale"];
                NSString *name = userData[@"name"];
                NSString *timezone = userData[@"timezone"];
                NSString *updated_time = userData[@"updated_time"];
                
                NSLog(@"user info birthday>>>>%@",birthday);
                NSLog(@"user info email>>>>%@",email);
                NSLog(@"user info first_name>>>>%@",first_name);
                NSLog(@"user info facebookID>>>>%@",facebookID);
                NSLog(@"user info last_name>>>>%@",last_name);
                NSLog(@"user info link>>>>%@",link);
                NSLog(@"user info locale>>>>%@",locale);
                NSLog(@"user info name>>>>%@",name);
                NSLog(@"user info timezone>>>>%@",timezone);
                NSLog(@"user info updated_time>>>>%@",updated_time);
                
            }
        } else {
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
}

// ------------> Code for requesting user information ends here <------------

// ------------> Code for requesting user information starts here <------------

/*
 This function asks for the user's public profile and birthday.
 It first checks for the existence of the public_profile and user_birthday permissions
 If the permissions are not present, it requests them
 If/once the permissions are present, it makes the user info request
 */

-(void)fbResync
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
}

-(void)getUserInfoWithSuccess:(void (^)(id))success
                    failure:(void (^)(NSError *))failure{
    MCLogger(@"getUserInfo>>>>>>>>>>>>>INTO>>>>>>>>>>>>>>");
//    NSDictionary *userData = [NSDictionary dictionary] ;
    
    
    // try to open session with existing valid token
    NSArray *permissions = [[NSArray alloc] initWithObjects:
//                            @"publish_actions",
                            @"public_profile",
                            @"email",
                            nil];
    FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
    [FBSession setActiveSession:session];
    //         openActiveSessionWithReadPermissions
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                      //    called while state changed
                                      [self checkState];
                                  }];

    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         NSLog(@"Response done.");
         if (!error) {
             NSMutableString *userInfo = [[NSMutableString alloc] init];
             NSLog(@"user : %@", user);
             success(user);
             
         }else {
             //NSLog(@"error : %@", error);
                 [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                     
                      if (!error) {
                          success(user);
                      }
                 }];
             
         }
     }];
    
    MCLogger(@"getUserInfo>>>>>>>>>>>>>END>>>>>>>>>>>>>>");
}
- (void)checkState{
    
    FBSessionState nowState = FBSession.activeSession.state;
    
    switch (nowState) {
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
            break;
            
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            break;
            
        case FBSessionStateCreated:
            NSLog(@"FBSessionStateCreated");
            NSLog(@"No Login");
            break;
            
        case FBSessionStateCreatedOpening:
            NSLog(@"FBSessionStateCreatedOpening");
            break;
            
        case FBSessionStateCreatedTokenLoaded:
            NSLog(@"Token Got!");
            //  even have vaild Token, still need a Session to do the communication.
            [FBSession openActiveSessionWithAllowLoginUI:NO];   //  create a session.
            
        case FBSessionStateOpen:
            NSLog(@"%@", (nowState==FBSessionStateOpen)?@"FBSessionStateOpen":@"FBSessionStateCreatedTokenLoaded");
            isLogin = YES;
//            MainViewController *main = [[[MainViewController alloc] init] autorelease];
//            [self presentViewController:main animated:YES completion:nil];
            break;
            
        case FBSessionStateOpenTokenExtended:
            NSLog(@"FBSessionStateOpenTokenExtended");
            break;
    }
}




-(NSDictionary*)getTestInfo:(NSString *)user
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure{
    MCLogger(@"getUserInfo>>>>>>>>>>>>>INTO>>>>>>>>>>>>>>");
    NSDictionary *userData = [NSDictionary dictionary] ;

    
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"http://echo.jsontest.com/key/value/one/two"];
    
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
    return userData;
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged
{
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error) {
                //              self.nameLabel.text = user.name;
                //              self.emailLabel.text = [user objectForKey:@"email"];
                NSLog(@"get id %@ ",[user objectForKey:@"id"]);
                NSLog(@"get name %@ ",[user objectForKey:@"name"]);
                NSLog(@"get first_name %@ ",[user objectForKey:@"first_name"]);
                NSLog(@"get middle_name %@ ",[user objectForKey:@"middle_name"]);
                NSLog(@"get last_name %@ ",[user objectForKey:@"last_name"]);
                NSLog(@"get link %@ ",[user objectForKey:@"link"]);
                NSLog(@"get username %@ ",[user objectForKey:@"username"]);
                NSLog(@"get birthday %@ ",[user objectForKey:@"birthday"]);
                NSLog(@"get email %@ ",[user objectForKey:@"email"]);
            }
        }];
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
//        [self userLoggedIn];
        
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error) {
                //              self.nameLabel.text = user.name;
                //              self.emailLabel.text = [user objectForKey:@"email"];
                NSLog(@"get id %@ ",[user objectForKey:@"id"]);
                NSLog(@"get name %@ ",[user objectForKey:@"name"]);
                NSLog(@"get first_name %@ ",[user objectForKey:@"first_name"]);
                NSLog(@"get middle_name %@ ",[user objectForKey:@"middle_name"]);
                NSLog(@"get last_name %@ ",[user objectForKey:@"last_name"]);
                NSLog(@"get link %@ ",[user objectForKey:@"link"]);
                NSLog(@"get username %@ ",[user objectForKey:@"username"]);
                NSLog(@"get birthday %@ ",[user objectForKey:@"birthday"]);
                NSLog(@"get email %@ ",[user objectForKey:@"email"]);
            }
        }];
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
//            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
//                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }
}

-(void)publishFacebook{
    NSMutableDictionary *postParams2= [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"haberLink", @"link",
                                       @"abc.com", @"name",
                                       @"title", @"caption",
                                       @"desc", @"description",
                                       nil];
    
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:postParams2
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat: @"Shared Facebook"];
             
             
             
             [[[UIAlertView alloc] initWithTitle:@"Shared Facebook"
                                         message:alertText
                                        delegate:self
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil]
              show];
             
         }
     }];
}

-(void)login:(void (^)(id))success
     failure:(void (^)(NSError *))failure{

    MCLogger(@"getUserInfo>>>>>>>>>>>>>INTO>>>>>>>>>>>>>>");
    //    NSDictionary *userData = [NSDictionary dictionary] ;
    
    
    // try to open session with existing valid token
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            //                            @"publish_actions",
                            @"public_profile",
                            @"email",
                            nil];
    FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
    [FBSession setActiveSession:session];
    //         openActiveSessionWithReadPermissions
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                      if (!error) {
                                          success(session);
                                      }else{
                                          failure(error);
                                      }
                                      //    called while state changed
                                      [self checkState];
                                  }];
}

-(void)getUser:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCCONFIG" ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString* ottName = nil;
    if (plistPath == nil) {
        ottName = @"";
    }else{
        ottName = (NSString*)[dict objectForKey:@"OTT_NAME"];
    }
 
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         NSLog(@"Response done.");
         if (!error) {
             NSMutableString *userInfo = [[NSMutableString alloc] init];
             NSLog(@"user : %@", user);
//             success(user);
             
             MCLogin* mcl = [[MCLogin alloc] init];
             self.email = [user objectForKey:@"email"];
             self.facebookID = [user objectForKey:@"id"];
             [mcl GetAmbitUserInfoViaOpenID:self.email
                                    openUID:self.facebookID
                                 login_type:LOGIN_TYPE_FACEBOOK
                                      sysID:ottName
                                    success:^(id responseObject) {
                                        success(responseObject);
                                    } failure:^(NSError *error) {
                                        failure(error);
                                    }];
             
         }else {
             //NSLog(@"error : %@", error);
             [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                 
                 if (!error) {
//                     success(user);

                     MCLogin* mcl = [[MCLogin alloc] init];
                     self.email = [user objectForKey:@"email"];
                     self.facebookID = [user objectForKey:@"id"];
                     [mcl GetAmbitUserInfoViaOpenID:self.email
                                            openUID:self.facebookID
                                         login_type:LOGIN_TYPE_FACEBOOK
                                              sysID:ottName
                                            success:^(id responseObject) {
                                                success(responseObject);
                                            } failure:^(NSError *error) {
                                                failure(error);
                                            }];
                 }else{
                     failure(error);
                 }
             }];
             
         }
     }];
}

@end
