//
//  GLSoundCloudViewController.h
//  FacebookSignIn
//
//  Created by Innvente iOS on 05/09/2013.
//  Copyright (c) 2013 Innventee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"
#import "EmyAppDelegate.h"

@interface GLSoundCloudViewController : UIViewController
{
IBOutlet UIWebView *webview;
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
}


@property(nonatomic,retain) IBOutlet UIWebView *webview;
@property(nonatomic,retain) NSString *isLogin;

-(IBAction)topnav;

@end