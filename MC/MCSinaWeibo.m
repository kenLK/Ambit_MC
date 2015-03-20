//
//  MCSinaWeibo.m
//  MC
//
//  Created by Ken on 2014/11/18.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCSinaWeibo.h"

@interface MCSinaWeibo ()

@property (strong, nonatomic) ACAccountStore *accountStore;//ACAccountStore


@end

@implementation MCSinaWeibo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //[AppCommon showProgressHUD:NSLocalizedString(@"ProgressHUD_LoadingData", @"'Loading Data','Laden van Gegevens','Daten werden geladen' -General message")];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) // check SinaWeibo is configured in Settings or not
    {
        self.accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *weiboAcc = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
        
        [self.accountStore requestAccessToAccountsWithType:weiboAcc options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 NSArray *accountsArray = [self.accountStore accountsWithAccountType:weiboAcc];
                 //[AppCommon hideProgressHUD];
                 NSDictionary *sinaWeiboAccount = [[self.accountStore accountsWithAccountType:weiboAcc] lastObject];
                 NSLog(@"weiboAcc UserName1: %@", [sinaWeiboAccount valueForKey:@"username"]);
                 
                 ACAccount *account = accountsArray[0];
                 NSString *userID = ((NSDictionary*)[account valueForKey:@"properties"])[@"user_id"];
                 NSLog(@"weiboAcc0");
                 //NSString *userID = [sinaWeiboAccount valueForKey:@"user_id"];
                 NSLog(@"weiboAcc");
                 [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"sinaWeiboUserID"];
                                  NSLog(@"weiboAcc2");
                 [[NSUserDefaults standardUserDefaults] setObject:[sinaWeiboAccount valueForKey:@"username"] forKey:@"sinaWeiboUserEMAIL"];
                                  NSLog(@"weiboAcc3");
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [self dismissViewControllerAnimated:YES completion:nil];
                 
                 MCLogger(@"weiboAcc>>>>>userID>>>>>>%@>>>>>>",userID);
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
        NSLog(@"Not Configured in Settings......"); // show user an alert view that SinaWeibo is not configured in settings.
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"error" message:@"Not Configured in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
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

@end
