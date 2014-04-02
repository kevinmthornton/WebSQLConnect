//
//  PCCDatabase.h
//  WebSQLConnect
//
//  Created by kevin thornton on 1/15/14.
//  Copyright (c) 2014 kevin thornton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface PCCDatabase : NSObject {
    //    variable to store the pointer to our SQLite database
    sqlite3 *_database;
    sqlite3 *theDatabase;
    NSString *documentsFolder;
    NSString *documentsPath;
    NSFileManager *fileManager;
}

@property sqlite3 *theDatabase;
@property(nonatomic, strong) NSString *documentsFolder;
@property(nonatomic, strong) NSString *documentsPath;
@property(nonatomic, strong) NSFileManager *fileManager;


// class method to return the singleton instance of our PCCDatabase object
+ (PCCDatabase*)database;

// array to hold the list of main info
-(NSArray *)directoryListByLetter:(NSString *)letter;

//check if the DB is full or not
+(BOOL)databaseFull;

// get the data out of the db and return it in a JSON formatted string
+(NSString *)returnDataInJSONString;

// where it all starts to get new data into the database whether first time, an update or new data pushed
+(void)kickOffDatabaseUpdate;

+(BOOL)fillDatabaseWithData;

+(void)insertDataIntoDatabase:(NSString*)first_name last_name:(NSString*)last_name company:(NSString*)company division:(NSString*)division
                        title:(NSString*)title department:(NSString*)department email:(NSString*)email work_phone:(NSString*)work_phone cell_phone:(NSString*)cell_phone;

+(BOOL)downloadZipFile;

@end
