//
//  GLSoundCloudViewController.m
//  FacebookSignIn
//
//  Created by Innvente iOS on 05/09/2013.
//  Copyright (c) 2013 Innventee. All rights reserved.
//

#import "GLSoundCloudViewController.h"
#import "EmyAppDelegate.h"



NSString *clientid;
NSString *clientsecret;
NSString *redirect;


@interface GLSoundCloudViewController ()


@end

@implementation GLSoundCloudViewController
@synthesize webview, isLogin;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
                self.isLogin = @"no";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    clientsecret =@"0e84dfaa538f588b379cdcf49ea0b1bf";
    clientid     =@"8e5c4de06519e45d7973742e47fa9e02";
    redirect = @"LoginTumblr://oauth";
    
    consumer = [[OAConsumer alloc] initWithKey:clientid secret:clientsecret realm:nil];
    
    NSURL* requestTokenUrl = [NSURL URLWithString:@"http://api.soundcloud.com/oauth/request_token"];
    OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                               consumer:consumer
                                                                                  token:nil
                                                                                  realm:redirect
                                                                      signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:redirect];
    [requestTokenRequest setHTTPMethod:@"POST"];
    [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:self
                    didFinishSelector:@selector(didReceiveRequestToken:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];
    //   [indicator startAnimating];
}
- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    
    NSURL* authorizeUrl = [NSURL URLWithString:@"http://soundcloud.com/oauth/authorize"];
    OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                            consumer:consumer
                                                                               token:nil
                                                                               realm:redirect
                                                                   signatureProvider:nil];
    NSString* oauthToken = requestToken.key;
    OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
    [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
    
    [webview loadRequest:authorizeRequest];
    
    
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    //   WebServiceSocket *connection = [[WebServiceSocket alloc] init];
    // connection.delegate = self;
    NSString *pdata = [NSString stringWithFormat:@"type=2&token=%@&secret=%@&login=%@", accessToken.key, accessToken.secret, self.isLogin];
    //   [connection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
    
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"SoundCloud TOken"
                              message:pdata
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error {
    // ERROR!
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //  [indicator startAnimating];
    
    /*   UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@"Test"
     message:[request.URL absoluteString]
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alertView show]; */
     
    if ([[[request URL] scheme] isEqualToString:@"logintumblr"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"oauth_verifier"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        if (verifier) {
            NSURL* accessTokenUrl = [NSURL URLWithString:@"http://api.soundcloud.com/oauth/access_token"];
            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl
                                                                                      consumer:consumer
                                                                                         token:requestToken
                                                                                         realm:nil
                                                                             signatureProvider:nil];
            OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            [dataFetcher fetchDataWithRequest:accessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(didReceiveAccessToken:data:)
                              didFailSelector:@selector(didFailOAuth:error:)];
        } else {
            // ERROR!
        }
        
        [webView removeFromSuperview];
        
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    // ERROR!
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // [indicator stopAnimating];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)topnav{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)startingFetch{
    //  [indicator startAnimating];
}
-(void)fetchComplete:(NSString *)data onEndPoint:(int)endPoint wasCached:(Boolean)check{
    /*   [indicator stopAnimating];
     SBJsonParser *jResponse = [[SBJsonParser alloc]init];
     NSDictionary *accountData = [jResponse objectWithString:data];
     if([[accountData objectForKey:@"status"] isEqualToString:@"fail"]){
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tapazine" message:@"You are not a member of Tapazine" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
     [alert show];
     }else{
     AppState *state = [AppState getAppState];
     state.twitterName = [accountData objectForKey:@"name"];
     state.defaultCategory = [NSString stringWithFormat:@"%@", [accountData objectForKey:@"default"]];
     state.currentCategory = [NSString stringWithFormat:@"%@", [accountData objectForKey:@"default"]];
     if([state.loggedinUsing isEqualToString:@""]){
     state.loggedinUsing = @"twitter";
     state.user_id = [accountData objectForKey:@"user_id"];
     state.shouldRefresh = YES;
     }
     state.isLoggedIn = @"YES";
     [AppState synchronizeSettingsToPhone];
     }
     [self.navigationController popViewControllerAnimated:YES]; */
    
}
@end
