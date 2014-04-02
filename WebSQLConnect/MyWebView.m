//  MyWebView.m
/*
 
 
 
 */
//


#import "MyWebView.h"
#import "PCCDatabase.h"

// category for adding to the NSArray class
@interface NSArray(JSONCategories)
+(NSArray*)arrayWithContentsOfJSONURLString:(NSString*)urlAddress;

-(NSData*)toJSON;
@end

@implementation NSArray(JSONCategories)
// gets an NSString with a web address
// does all the downloading, fetching, parsing and whatnot then returns an instance of an array
+(NSArray*)arrayWithContentsOfJSONURLString: (NSString*)urlAddress {
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

// toJSON which you call on an NSArray instance to get JSON data out of it
-(NSData*)toJSON {
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

@end


@implementation MyWebView
@synthesize pccDatabase = _pccDatabase;


// NOT USED as of now; calling all this from inside webView: shouldStartLoadWithRequest:
-(void)executeJSFunction:(NSString *)jsString webView:(UIWebView *)webView {
    jsString = [jsString stringByAppendingFormat:@"javascript:%@",jsString];
    NSString *formattedJSString = [[NSString alloc] initWithFormat:@"javascript:%@",jsString];
    NSLog(@"executeJS: %@", formattedJSString);
    [self stringByEvaluatingJavaScriptFromString:@"javascript:Directory.showData('executeJS');"];
    [self stringByEvaluatingJavaScriptFromString:@"javascript:function() { calledFromUIWebView() }"];
}

// boilerplate call for JS when a page is first loaded
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    // [self stringByEvaluatingJavaScriptFromString:@"javascript:Directory.showData('didfinish');"];
    
}


// THIS IS WHERE IT STARTS - called when RootViewController > loadView is fired off
// load up this web view with webview-document.html
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    // Set delegate in order to "shouldStartLoadWithRequest" to be called
    self.delegate = self;
    // Set non-opaque in order to make "body{background-color:transparent}" working for the setBackgroundColor method
    self.opaque = NO;
    // load our html file into our class
    NSString *path = [[NSBundle mainBundle] pathForResource:@"webview-document" ofType:@"html"];
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
  }
  return self;
}


// This main selector is called when a URL is loaded in our webview
// All images, xmlhttprequest, css, ... files/requests don't  generate this event
- (BOOL)webView:(UIWebView *)webView2 
	      shouldStartLoadWithRequest:(NSURLRequest *)request 
	      navigationType:(UIWebViewNavigationType)navigationType {
    
    // turn the request into a string so we can parse it
    NSString *requestString = [[request URL] absoluteString];
    // if this strings starts with js-frame, we are sending a command into the iframe that we want parsed out as a native method
    if ([requestString hasPrefix:@"js-frame:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        // function - what do we want to execute?
        NSString *function = (NSString*)[components objectAtIndex:1];
        // callbackId - send this back to JS
        NSString *callbackFunction = [components objectAtIndex:2];
        // the arguments to send to the intended function
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // change these into data so we can send to JSON
        NSData* argsAsData = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
        // parse with JSON for values
        NSError *error;
        NSArray *args = [NSJSONSerialization JSONObjectWithData:argsAsData options:kNilOptions error:&error];
        // send the parts to handleCall to be executed
        [self handleCall:function callbackFunction:callbackFunction args:args];
        return NO; // don't do anything
    } // if js-frame
    
    
  return YES;
}

// Implements all you native function in this one, by matching 'functionName' and parsing 'args'
// Use 'callbackId' with 'returnResult' selector when you get some results to send back to javascript
- (void)handleCall:(NSString*)functionName callbackFunction:(NSString *)callbackFunction args:(NSArray*)args {
    
    if ([functionName isEqualToString:@"setBackgroundColor"]) {
        if ([args count]!=3) {
            NSLog(@"setBackgroundColor wants exactly 3 arguments!");
            return;
        }
        NSNumber *red = (NSNumber*)[args objectAtIndex:0];
        NSNumber *green = (NSNumber*)[args objectAtIndex:1];
        NSNumber *blue = (NSNumber*)[args objectAtIndex:2];
        
        //  int blueValue = [blue intValue];
//        blue = [NSNumber numberWithInt:callbackId + 1];
        NSLog(@"handleCall > setBackgroundColor(%@,%@,%@)",red,green,blue);
        NSArray *returnArgs = [[NSArray alloc] initWithObjects:red, green, blue, nil];
        
        self.backgroundColor = [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1.0];
        
        // function below that will send this back to the web view
        [self returnResult:callbackFunction args:returnArgs];
        
    // can take this out eventually
    } else if ([functionName isEqualToString:@"nextViewController"]) {
        // NOTIFICATION for opening a web link that executes a native function
        // NOTIFICATION_NEXT_VIEW_CONTROLLER is set up in the Trillium-Prefix.pch file
        // set up an two array's for the notification object which will be a dictionary of these array key/values passed in
        // these can be as long as you want but, have to match in key/value pairs
        NSArray *keys = [NSArray arrayWithObjects:@"portalURL", nil];
        NSArray *values = [NSArray arrayWithObjects:@"http://www.YOUR-INTRANET.com", nil];
        // load up the dictionary with these two arrays
        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        // you can now set up a listener for NOTIFICATION_NEXT_VIEW_CONTROLLER in any view controller > viewDidLoad
        // object in the call below could be ANY OBJECT, in this case, it is a dicitonary of arrays
        NSNotification *notification = [NSNotification notificationWithName:NOTIFICATION_NEXT_VIEW_CONTROLLER object:notificationInfo];
        // posts the notification to the defaultCenter
        [[NSNotificationCenter defaultCenter] postNotification:notification];

    } else if ([functionName isEqualToString:@"directoryListing"]) {
        // no notification, keep this all local to this class
        [self directoryListing];
        
        // NOTIFICATION for opening a web link that executes a native function
        // NOTIFICATION_DIRECTORY_LISTING is set up in the Trillium-Prefix.pch file
        // you can now set up a listener for NOTIFICATION_DIRECTORY_LISTING in any view controller > viewDidLoad
        // object in the call below could be ANY OBJECT, in this case, it is a dicitonary of arrays
        // -- NSNotification *notification = [NSNotification notificationWithName:NOTIFICATION_DIRECTORY_LISTING object:nil];
        // posts the notification to the defaultCenter
        // -- [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSLog(@"Unimplemented method '%@'",functionName);
    }
}

// Call this function when you have results to send back to javascript callbacks
// callbackId : int comes from handleCall function
// args: list of objects to send to the javascript callback
//      the arg list is variable, hence the ,... --> from original NativeBridgeCode
// - (void)returnResult:(NSString *)callbackFunction args:(id)arg, ...; {
- (void)returnResult:(NSString *)callbackFunction args:(NSArray *)args {
    if(callbackFunction==(id) [NSNull null] || [callbackFunction length]==0 || [callbackFunction isEqualToString:@""]){
        return;
    }
    // take the string passed in and make a JSON string out of it
    NSData *jsonData = [args toJSON];
    // NSLog(@"jsonData: %@", jsonData);
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // NSLog(@"jsonString: %@", jsonString);
    NSString * fixedJSONString = [jsonString stringByReplacingOccurrencesOfString:@"[[" withString:@"["];
    fixedJSONString = [fixedJSONString stringByReplacingOccurrencesOfString:@"]]" withString:@"]"];
    
    // use fixedJSONString to send JSON data back into the web view javascript calls
    // [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,fixedJSONString] afterDelay:0];
    [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:callbackFunction waitUntilDone:NO];
    
    // could send this to another method
    // [self performSelector:@selector(returnResultAfterDelay:) withObject:callbackFunction afterDelay:0];
}

// NOT USED now, just calling right to performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) in returnResult:
-(void)returnResultAfterDelay:(NSString*)str {
    NSLog(@"returnResultAfterDelay str: %@", str);
  // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
  [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}


// clicked the link in index.html to show the directory listing
-(void)directoryListing {
    // is the database full? if not, fill it - use a CLASS method so we can re-use it inside the class for checking rows 
    BOOL databaseFull = [PCCDatabase databaseFull];
    
    
    // this should be kicked off after the login is successful
    if (!databaseFull) {
        NSLog(@"database NOT full");
        // start the process to fill up the database with data
        // if something fails in this process, the directory.html file will be kicked to help.html with a message
        [PCCDatabase kickOffDatabaseUpdate];
    } else {
        NSLog(@"has data");
    }
    
    NSString *jsonStringForDirectory = [PCCDatabase returnDataInJSONString];
    
    [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"javascript:Directory.showData(%@);",jsonStringForDirectory] afterDelay:1];
    
    
    // NOT USED but, good example
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        //[self executeJSFunction:[NSString stringWithFormat:@"Directory.showData(%@);",jsonStringForDirectory]];
    });
} // directoryListing

-(void)viewDidLoad {
    // put a var in here that gathers all the json data into a string
    // format the string and when webViewDidFinishLoad kicks off, that will send back to the directory.html  document to execute
    self.delegate = self;
    
    
}

@end
