//
//  MyWebView.h
//  UIWebView-Call-ObjC
//
//  Created by NativeBridge on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@class PCCDatabase;


@interface MyWebView : UIWebView <UIWebViewDelegate> {
    // OLD SBJSON *json;
    int alertCallbackId;

    
}
@property(nonatomic, retain) PCCDatabase *pccDatabase;



- (void)handleCall:(NSString*)functionName callbackFunction:(NSString *)callbackFunction args:(NSArray*)args;

// The ,... syntax says "handle variable amounrs of arguments"
// - (void)returnResult:(NSString *)callbackFunction args:(id)firstObj, ...;
- (void)returnResult:(NSString *)callbackFunction args:(NSArray *)args;


// call this when clicking on the directory listing link
-(void)directoryListing;



-(void)executeJSFunction:(NSString *)jsString webView:(UIWebView*)webView;

@end
