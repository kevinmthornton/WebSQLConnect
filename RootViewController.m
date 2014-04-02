//
//  RootViewController.m
//  WebSQLConnect
//
//  Created by kevin thornton on 1/9/14.
//  Copyright (c) 2014 kevin thornton. All rights reserved.
//

#import "RootViewController.h"
#import "MyWebView.h"
#import "NextViewController.h"
#import "PCCDatabase.h"
#import "Directory.h"
#import "HelpWebView.h"

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize nextVC = _nextVC;
@synthesize pccDatabase = _pccDatabase;
@synthesize myWebView = _myWebView;
@synthesize helpWebView = _helpWebView;

// NOT USED now - calling this right from MyWebView so that we can execute everything right in that class/thread
// NOTIFICATION CALL - to show the directory listing
-(void)directoryListing {
    // is the database full? if not, fill it
    
    //PCCDatabase *pccDatabase = [[PCCDatabase alloc]init];
    BOOL databaseFull = [PCCDatabase databaseFull];
    
    if (!databaseFull) {
        NSLog(@"database NOT full");
        // start the process to fill up the database with data
        // if something fails in this process, the directory.html file will be kicked to help.html with a message
        [PCCDatabase kickOffDatabaseUpdate];
    } else {
        NSLog(@"has data");
    }
    
//    NSArray *namesArray = [pccDatabase directoryListByLetter:@"t"];
//    NSLog(@"namesArray: %@", namesArray);
    
    NSString *jsonStringForDirectory = [PCCDatabase returnDataInJSONString];
//  NSLog(@"jsonStringForDirectory: %@", jsonStringForDirectory);
    
    // [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"javascript:Directory.showData(%@);",jsonStringForDirectory] afterDelay:1];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self.myWebView executeJSFunction:[NSString stringWithFormat:@"Directory.showData(%@);",jsonStringForDirectory] webView:self.myWebView];
    });
} // directoryListing

-(void)returnResultAfterDelay:(NSString*)str {
//    NSLog(@"return: %@", str);
    // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
    [self.myWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}


// this is called from MyWebView > webview-document.html in the links
// it travels through MyWebView and the notification center
-(void)openNextViewController:(NSNotification *)notification {
    NSDictionary *notificationInfo = (NSDictionary *)notification.object;
    NSURL *portalURL =  [notificationInfo objectForKey:@"portalURL"];
    [self.view addSubview:self.nextVC.view];
}

// do they have an internet connection?
- (BOOL) connectedToInternet {
    NSError *urlError = [[NSError alloc] init];
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"] encoding:NSUTF8StringEncoding error:&urlError];
    return ( URLString != NULL ) ? YES : NO;
}

// do they have an internet connection?
- (BOOL) connectedToPortal {
    NSError *urlError = [[NSError alloc] init];
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.YOUR-INTRANET.com"] encoding:NSUTF8StringEncoding error:&urlError];
    return ( URLString != NULL ) ? YES : NO;
}



- (void)viewDidLoad{
    [super viewDidLoad];
	// set up nextVC
    if (!self.nextVC) {
        self.nextVC = [[NextViewController alloc] initWithNibName:@"NextViewController" bundle:nil];
    }
    
    // listen for NOTIFICATION_NEXT_VIEW_CONTROLLER and assign it to the method openNextViewController:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openNextViewController:) name:NOTIFICATION_NEXT_VIEW_CONTROLLER object:nil];

    // listen for NOTIFICATION_NEXT_VIEW_CONTROLLER and assign it to the method openNextViewController:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directoryListing) name:NOTIFICATION_DIRECTORY_LISTING object:nil];
    
    // copy the database from the app to the file system if it is not already present
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"universalApp" ofType:@"sqlite3"];
    NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"universalApp"] stringByAppendingPathExtension:@"sqlite3"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:documentsPath]) {
        NSError *error = nil;
        BOOL success = [fileManager copyItemAtPath:bundlePath toPath:documentsPath error:&error];
        // raise an exception if this copy does not work
        NSAssert(success, @"%s: copyItemAtPath failed: %@", __FUNCTION__, error);
    } else {
        // the file is on the system
        NSLog(@"from log call: database is on the filesystem already");
    }
    
    if ([self connectedToInternet]) {
        if ([self connectedToPortal]) {
            // all is well, load up the main web view
            CGRect frame=[UIScreen mainScreen].applicationFrame;
            self.view = [[MyWebView alloc] initWithFrame:frame];
        } else {
            // NOT connected to VPN/portal
            NSLog(@"You do not appear to be connected to the VPN");
            // help files for connecting to portal
            CGRect frame=[UIScreen mainScreen].applicationFrame;
            self.view = [[HelpWebView alloc] initWithFrame:frame];
        }
    } else {
        // NOT connected to the internet
        NSLog(@"You do not appear to be connected to the internet.");
        // help files for making connection
        CGRect frame=[UIScreen mainScreen].applicationFrame;
        self.view = [[HelpWebView alloc] initWithFrame:frame];
    }
    

    //self.myWebView = [[MyWebView alloc] init];
    // self.myWebView.delegate = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    // should fail gracefully
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
