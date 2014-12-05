//
//  MCTwitter.m
//  MC
//
//  Created by Ken on 2014/11/17.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCTwitter.h"

@interface MCTwitter ()

@property (strong, nonatomic) ACAccountStore *accountStore;//ACAccountStore

@end

@implementation MCTwitter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) // check Twitter is configured in Settings or not
    {
        self.accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *twitterAcc = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAcc options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 NSArray *accountsArray = [self.accountStore accountsWithAccountType:twitterAcc];
                 //[AppCommon hideProgressHUD];
                 NSDictionary *twitterAccount = [[self.accountStore accountsWithAccountType:twitterAcc] lastObject];
                 NSLog(@"Twitter UserName: %@", [twitterAccount valueForKey:@"username"]);
                 
                 ACAccount *account = accountsArray[0];
                 NSString* userID = ((NSDictionary*)[account valueForKey:@"properties"])[@"user_id"];
                 [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"twitterUserID"];
                 [[NSUserDefaults standardUserDefaults] setObject:[twitterAccount valueForKey:@"username"] forKey:@"twitterUserEMAIL"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [self dismissViewControllerAnimated:YES completion:nil];
                 
                 MCLogger(@"twitterAcc>>>>>userID>>>>>>%@>>>>>>",userID);
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
        NSLog(@"Not Configured in Settings......"); // show user an alert view that Twitter is not configured in settings.
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
