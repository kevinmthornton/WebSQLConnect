//
//  PCCDatabase.m
//  WebSQLConnect
//
//  Created by kevin thornton on 1/15/14.
//  Copyright (c) 2014 kevin thornton. All rights reserved.
//

#import "PCCDatabase.h"

// category for adding to the NSArray class
@interface NSArray(JSONCategories)
+(NSArray*)arrayWithContentsOfJSONURLString:(NSString*)urlAddress;
+(NSArray*)arrayWithContentsOfJSONFile:(NSString*)filePath;
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

+(NSArray*)arrayWithContentsOfJSONFile: (NSString*)filePath {
    NSData* data = [NSData dataWithContentsOfFile:filePath];
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


@implementation PCCDatabase
@synthesize theDatabase = _theDatabase;
@synthesize documentsFolder = _documentsFolder;
@synthesize documentsPath = _documentsPath;
@synthesize fileManager = _fileManager;


// return as a dictionary based on letter
-(NSArray *)directoryListByLetter:(NSString *)letter {
    // use the letter passed in to get the list of last names
    NSMutableArray *directoryArray = [[NSMutableArray alloc] init];
    
    
//    sqlite3 *theDatabase = NULL;
//    NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"universalApp"] stringByAppendingPathExtension:@"sqlite3"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:documentsPath]) {
        //      once you have path, open it up
        if (sqlite3_open([documentsPath UTF8String], &theDatabase) == SQLITE_OK) {
            //  construct our SQL string, and execute it with the sqlite3_prepare_v2 API call
            NSString *query = @"SELECT ID, first_name, last_name FROM tblDirectory ORDER BY last_name DESC";
            sqlite3_stmt *statement;
            // make sure this executed OK
            if (sqlite3_prepare_v2(theDatabase, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    char *firstChars = (char *) sqlite3_column_text(statement, 1);
                    char *lastChars = (char *) sqlite3_column_text(statement, 2);
                    NSString *first_name = [[NSString alloc] initWithUTF8String:firstChars];
                    NSString *last_name = [[NSString alloc] initWithUTF8String:lastChars];
            
                    NSArray *infoArray = [[NSArray alloc] initWithObjects:first_name, last_name, nil];
                    [directoryArray addObject:infoArray];
                } // while
                sqlite3_finalize(statement);// clean up the memory used for the statement
            } // if prepare
        } // if opened
    } else {
        NSLog(@"directoryLIstByLetter: %s", sqlite3_errmsg(theDatabase));
    } // else from if fileManager
    sqlite3_close(theDatabase);
    return directoryArray;
}

+(NSString *)returnDataInJSONString {
    // start off creating our string object formatting for JSON
    NSString *jsonString = @"[";
    sqlite3 *theDatabase = NULL;
    NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"universalApp"] stringByAppendingPathExtension:@"sqlite3"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:documentsPath]) {
        //      once you have path, open it up
        if (sqlite3_open([documentsPath UTF8String], &theDatabase) == SQLITE_OK) {
            //  construct our SQL string, and execute it with the sqlite3_prepare_v2 API call
            NSString *query = @"SELECT ID, first_name, last_name FROM tblDirectory ORDER BY last_name DESC";
            sqlite3_stmt *statement;
            // make sure this executed OK
            if (sqlite3_prepare_v2(theDatabase, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    char *firstChars = (char *) sqlite3_column_text(statement, 1);
                    char *lastChars = (char *) sqlite3_column_text(statement, 2);
                    NSString *first_name = [[NSString alloc] initWithUTF8String:firstChars];
                    NSString *last_name = [[NSString alloc] initWithUTF8String:lastChars];
                    // format this
                    jsonString = [jsonString stringByAppendingFormat:@"{\"first_name\" : \"%@\", \"last_name\" : \"%@\"},", first_name, last_name];
                } // while
                sqlite3_finalize(statement);// clean up the memory used for the statement
            } // if prepare
        } // if opened
    } else {
        NSLog(@"returnDataInJSONString: %s", sqlite3_errmsg(theDatabase));
    } // else from if fileManager
    sqlite3_close(theDatabase);
    jsonString = [jsonString substringToIndex:[jsonString length]-1]; // take off last comma from string
    jsonString = [jsonString stringByAppendingString:@"]"]; // attach last brace
    return jsonString;
}


+(void)kickOffDatabaseUpdate {
    // start the whole process of getting data into the database
    if([self downloadZipFile]) {
        if(![self fillDatabaseWithData]) {
            // something went wrong with filling the DB with data
            // send a call to the help files
        }
    } else {
        // something went wrong downloading the zip file
        // send a call to the help files
    }
    // all OK, program continues
}

// did the database get filled?
+(BOOL)fillDatabaseWithData {
    // for now, open directory.json in this app
    NSString *directoryJSONFilePath = [[NSBundle mainBundle] pathForResource:@"directory" ofType:@"json"];
    
    // this will become arrayWithContentsOfJSONURLString:urlOfJSONData - where you pass in the SessionID after login to get your data for this
    // each of the values in this array will be a dictionary
    NSArray *jsonDirectoryArray = [NSArray arrayWithContentsOfJSONFile:directoryJSONFilePath];
    
    for (NSDictionary *jsonDict in jsonDirectoryArray) {
        [self insertDataIntoDatabase:[jsonDict objectForKey:@"first_name"] last_name:[jsonDict objectForKey:@"last_name"] company:[jsonDict objectForKey:@"company"] division:[jsonDict objectForKey:@"division"] title:[jsonDict objectForKey:@"title"] department:[jsonDict objectForKey:@"department"] email:[jsonDict objectForKey:@"email"] work_phone:[jsonDict objectForKey:@"work_phone"] cell_phone:[jsonDict objectForKey:@"cell_phone"]];
    }
    
    
    // now get rows again to see if all is ok
    return [PCCDatabase databaseFull];
    
    return NO;
}


// CLASS METHOD
+(void)insertDataIntoDatabase:(NSString*)first_name last_name:(NSString*)last_name company:(NSString*)company division:(NSString*)division
                   title:(NSString*)title department:(NSString*)department email:(NSString*)email work_phone:(NSString*)work_phone cell_phone:(NSString*)cell_phone {
    /*
    // Create insert statement for the person
    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO tblDirectory (first_name,last_name,company,division,title,department,email,work_phone,cell_phone) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", first_name, last_name, company, division, title, department, email, work_phone, cell_phone];
    
    char *error;
    if ( sqlite3_exec((__bridge sqlite3 *)(_database), [insertStatement UTF8String], NULL, NULL, &error) == SQLITE_OK) {
        NSLog(@"inserted %@", first_name);
    } else {
        NSLog(@"Error: %s", error);
    }
     */
    // have to use local vars for the CLASS method, can't use instance vars
    sqlite3 *theDatabase = NULL;
    NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"universalApp"] stringByAppendingPathExtension:@"sqlite3"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:documentsPath]) {
        //      once you have path, open it up
        if (sqlite3_open([documentsPath UTF8String], &theDatabase) == SQLITE_OK) {
        
        /*
            NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO tblDirectory (first_name,last_name,company,division,title,department,email,work_phone,cell_phone) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", first_name, last_name, company, division, title, department, email, work_phone, cell_phone];
        
            char *error;
            if ( sqlite3_exec(theDatabase, [insertStatement UTF8String], NULL, NULL, &error) == SQLITE_OK) {
                NSLog(@"inserted %@", first_name);
            } else {
                NSLog(@"Error: %s", error);
            }
        */
        
        // prep statement
        sqlite3_stmt    *statement;
        NSString *querySQL = @"INSERT INTO tblDirectory (first_name,last_name,company,division,title,department,email,work_phone,cell_phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
        const char *query_stmt = [querySQL UTF8String];
    
        // preparing a query compiles the query so it can be re-used.
        sqlite3_prepare_v2(theDatabase, query_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [first_name UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 2, [last_name UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 3, [company UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 4, [division UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 5, [title UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 6, [department UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 7, [email UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 8, [work_phone UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(statement, 9, [cell_phone UTF8String], -1, SQLITE_STATIC);
    
    
        // process result
        if (sqlite3_step(statement) != SQLITE_DONE){
            NSLog(@"error: %s", sqlite3_errmsg(theDatabase));
        }
    
        sqlite3_finalize(statement);
        sqlite3_close(theDatabase);
        }
    } else {
        NSLog(@"Outside if error: %s", sqlite3_errmsg(theDatabase));
    }
}

// did the file get downloaded?
// session will have already been checked but, need to error gracefully if we can't get the zip file
+(BOOL)downloadZipFile {
    // download file
    // did we get the file? if not, display error through JS HELP Class call
    // else, unpack it
    
    // maybe not using .zip file but, compressed json string. in that case, use arrayWithContentsOfJSONURLString
    // and could even skip this step
    
    return YES;
}

+(BOOL)databaseFull {
    sqlite3 *theDatabase = NULL;
    NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"universalApp"] stringByAppendingPathExtension:@"sqlite3"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:documentsPath]) {
        //      once you have path, open it up
        if (sqlite3_open([documentsPath UTF8String], &theDatabase) == SQLITE_OK) {
            int rows = 0;
//          NSString *query = @"SELECT count(ID) as rowCount FROM universalApp";
            NSString *query = @"SELECT ID, first_name, last_name FROM tblDirectory ORDER BY last_name DESC";
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(theDatabase, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ERROR) {
                    NSAssert1(0,@"Error when counting rows  %s",sqlite3_errmsg(theDatabase));
                    return NO;
                } else {
                    while( sqlite3_step(statement) == SQLITE_ROW ){
                        rows = sqlite3_column_int(statement, 0);
                    }
                    if(rows) return YES;
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(theDatabase);
        } // if open
    } // if file manager
    return NO;
}

// create a singleton instance of PCCDatabase for ease of access
static PCCDatabase *_database;
+ (PCCDatabase*)database {
    // _database is the sqlite database object
    if (_database == nil) {
        _database = [[PCCDatabase alloc] init];
    }
    return _database;
}

// initialize our object and construct a path to our database file
- (id)init {
    if ((self = [super init])) {
        fileManager = [NSFileManager defaultManager];
        documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"universalApp"] stringByAppendingPathExtension:@"sqlite3"];
        //      once you have path, open it up
        if (sqlite3_open([documentsPath UTF8String], &theDatabase) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        
        self.documentsFolder = documentsFolder;
        self.documentsPath = documentsPath;
        self.fileManager = fileManager;
        
    }
    return self;
}


@end
