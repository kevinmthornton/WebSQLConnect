//
//  RootViewController.h
//  WebSQLConnect
//
//  Created by kevin thornton on 1/9/14.
//  Copyright (c) 2014 kevin thornton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NextViewController;
@class PCCDatabase;
@class MyWebView;
@class HelpWebView;

@interface RootViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic, retain) PCCDatabase *pccDatabase;
@property(nonatomic, retain) NextViewController *nextVC;
@property(nonatomic, retain) MyWebView *myWebView;
@property(nonatomic, retain) HelpWebView *helpWebView;


// main method for displaying the list of employees
-(void)directoryListing;
-(void)returnResultAfterDelay:(NSString*)str;
-(void)openNextViewController:(NSNotification *)notification ;
- (BOOL) connectedToInternet;
- (BOOL) connectedToPortal;

@end
