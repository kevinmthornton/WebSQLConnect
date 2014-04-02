//
//  AppDelegate.h
//  WebSQLConnect
//
//  Created by kevin thornton on 1/9/14.
//  Copyright (c) 2014 kevin thornton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *rootViewController;

@end
