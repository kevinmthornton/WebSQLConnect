//
//  HelpWebView.m
//  WebSQLConnect
//
//  Created by kevin thornton on 1/24/14.
//  Copyright (c) 2014 kevin thornton. All rights reserved.
//

#import "HelpWebView.h"

@implementation HelpWebView

// THIS IS WHERE IT STARTS - called when RootViewController > loadView is fired off
// load up this web view with webview-document.html
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Set delegate in order to "shouldStartLoadWithRequest" to be called
        self.delegate = self;
        // Set non-opaque in order to make "body{background-color:transparent}" working for the setBackgroundColor method
        self.opaque = NO;
        // load our html file into our class
        NSString *path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
