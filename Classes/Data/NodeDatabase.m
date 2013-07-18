//
// Copyright (c) 2013 Byron Sanchez (hackbytes.com)
// www.chompix.com
//
// Licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "NodeDatabase.h"

// Define the static constants for the class. Use exterm instead of static for
// public static strings.

// Define the SQLite database location.
static NSString *const DATABASE_NAME = @"creepypasta_files.db";
static NSString *const DATABASE_PATH = @"Documents";

// Define the tables used in the application.
static NSString *const DATABASE_TABLE_NODE = @"node";
static NSString *const DATABASE_TABLE_CATEGORIES = @"categories";
static NSString *const DATABASE_TABLE_VARIABLES = @"variables";
static NSString *const DATABASE_TABLE_SCHEMA = @"schema";

// Define the "node" table SQLite columns
static NSString *const KEY_NODE_ROWID = @"_id";
static NSString *const KEY_NODE_CATEGORYID = @"cid";
static NSString *const KEY_NODE_TITLE = @"title";
static NSString *const KEY_NODE_BODY = @"body";
static NSString *const KEY_NODE_IS_BOOKMARKED = @"is_bookmarked";

// Define the "categories" table SQLite columns
static NSString *const KEY_CATEGORIES_ROWID = @"_id";
static NSString *const KEY_CATEGORIES_CATEGORY = @"category";
static NSString *const KEY_CATEGORIES_DESCRIPTION = @"description";

// Define the "variables" table SQLite columns
static NSString *const KEY_VARIABLES_ROWID = @"_id";
static NSString *const KEY_VARIABLES_KEY = @"key";
static NSString *const KEY_VARIABLES_VALUE = @"value";
static NSString *const KEY_VARIABLES_SKU = @"sku";

// Define the "schema" table SQLite columns
static NSString *const KEY_SCHEMA_ROWID = @"_id";
static NSString *const KEY_SCHEMA_MAJOR_RELEASE_NUMBER = @"major_release_number";
static NSString *const KEY_SCHEMA_MINOR_RELEASE_NUMBER = @"minor_release_number";
static NSString *const KEY_SCHEMA_POINT_RELEASE_NUMBER = @"point_release_number";
static NSString *const KEY_SCHEMA_SCRIPT_NAME = @"script_name";
static NSString *const KEY_SCHEMA_DATE_APPLIED = @"date_applied";

// Define the current schema version.
static NSInteger const SCHEMA_VERSION = 2;

@implementation NodeDatabase

@synthesize homeDirectory = _homeDirectory;
@synthesize databasePath = _databasePath;
@synthesize mLeftOperand = _mLeftOperand;
@synthesize mRightOperand = _mRightOperand;
@synthesize mOperator = _mOperator;
@synthesize mIsUpgradeTaskInProgress = _mIsUpgradeTaskInProgress;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    _mIsUpgradeTaskInProgress = NO;
  }
  return self;
}

- (void)createDatabase {
  [self createDB];
}

- (void)createDB {
  // Check to see if the database exists. (Typically, on first run, it
  // should not exist yet). We create/open the database regardless, however, we
  // use this check to determine what we do after the database is opened or
  // created.
  BOOL dbExist = [self DBExists];
  
  // Get a readable database for use, or create one if one does not yet exist.
  if (sqlite3_open([_databasePath UTF8String], &_mOurDatabase) != SQLITE_OK) {
    _mOurDatabase = nil;
  }
  else {
    // If a database did not previously exist, run all available changescripts.
    if (!dbExist) {
      DBUpgradeTask *upgradeTask = [[DBUpgradeTask alloc] initWithContext:self scriptID:@"0000"];
      [upgradeTask execute];
    }
    // Make sure to NOT run onUpgrade on a fresh install. Only run it when the
    // database already previously existed.
    else {
      // Run the update check, in case updates should be applied.
      NSInteger currentSchemaVersion = [self getPragma:@"user_version"];
      if (SCHEMA_VERSION > currentSchemaVersion) {
        [self onUpgrade:_mOurDatabase
             oldVersion:currentSchemaVersion
             newVersion:SCHEMA_VERSION];
      }
    }
  }
}

- (BOOL)DBExists {

  BOOL fileExists = NO;
  
  // Define a string containing the default system database file path
  // for our application's database.
  // NSString *databasePath = @"";
  _databasePath = [[self getDocumentDirectory] stringByAppendingPathComponent:DATABASE_NAME];
  
  // Open the database.
  fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_databasePath];
  
  // If db is not null, database exists, return true.
  // Else, db does NOT exist, return false.
  return (fileExists) ? YES : NO;
}

- (void)runUpdates:(NSString *)recentScriptID {
  // TODO: For v2.0, return results for all database queries with either YES or
  // NO signalling success or failure.
  BOOL updatesCompleted = NO;
  // Signal a fresh install if the database is being created from scratch.
  BOOL isFreshInstall = NO;
  if ([recentScriptID isEqualToString:@"0000"]) {
    isFreshInstall = YES;
  }

  // Error handling for the directory load.
  NSError *directoryLoadError = nil;
  
  // Get a list of all database scripts from the assets directory.
  NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot
                                                 error:&directoryLoadError];
  if (!fm) {
    // Output a message.
    [[[UIAlertView alloc] initWithTitle:[directoryLoadError localizedDescription]
                                message:[directoryLoadError localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
  }
  NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'sc.'"];
  NSArray *fileList = [dirContents filteredArrayUsingPredicate:fltr];
  
  for (NSInteger i = 0; i < [fileList count]; i++) {
    NSString *fileString = [fileList objectAtIndex:i];
    NSString *scriptIDString = [self extractStringFromScript:fileString
                                                       value:@"point_release_number"];
    
    // If the current iteration scriptID is less than the most recently
    // applied update, skip to the next iteration.
    // Ignore this check for fresh installs, as all scripts will run in
    // in that case.
    if (!isFreshInstall && [scriptIDString compare:recentScriptID] <= 0) {
      continue;
    }
    [self applyScript:fileString];
    
    // This is what happens when you don't think ahead. Now we have to
    // skip logging directly to the database for the first 3
    // changescripts, because the schema table is first introduced in
    // the third changescript. The third changescript also
    // retroactively logs all previous change scripts.
    if ([scriptIDString compare:@"0003"] <= 0) {
      continue;
    }
    
    // Update the Schema Change Log.
    
    // Prepare the data to insert.
    NSString *major_release_number = [self extractStringFromScript:fileString value:@"major_release_number"];
    NSString *minor_release_number = [self extractStringFromScript:fileString value:@"minor_release_number"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date_applied = [formatter stringFromDate:[NSDate date]];
    
    // Create the new values
    NSString *query = [NSString stringWithFormat:@"INSERT INTO schema(%@, %@, %@, %@, %@) VALUES('%@','%@','%@','%@','%@');", KEY_SCHEMA_MAJOR_RELEASE_NUMBER, KEY_SCHEMA_MINOR_RELEASE_NUMBER, KEY_SCHEMA_POINT_RELEASE_NUMBER, KEY_SCHEMA_SCRIPT_NAME, KEY_SCHEMA_DATE_APPLIED, major_release_number, minor_release_number, scriptIDString, fileString, date_applied];
    
    // Prepare the statement.
    sqlite3_stmt *statement;
    // If it prepares without error...
    if (sqlite3_prepare_v2(_mOurDatabase,
                           [query UTF8String],
                           -1,
                           &statement,
                           nil)
        == SQLITE_OK) {
      
      // Execute the statement. SQLITE_DONE should be returned if the insert
      // was succesfully completed.
      if (SQLITE_DONE != sqlite3_step(statement)) {
        updatesCompleted = NO;
      }
      else {
        updatesCompleted = YES;
      }

      // Garbage collect the memory used for running the statement.
      sqlite3_finalize(statement);
    }
  }
  
  // If the updates were successfull, update the user_version pragma
  if (updatesCompleted) {
    // Update the SQLite pragma that will store a persistent schema version
    // for future updates.
    NSString *pragmaValue = [NSString stringWithFormat:@"%d", SCHEMA_VERSION];
    [self setPragma:@"user_version" value:pragmaValue];
  }
  
  // Close the database regardless of whether or not the updates were
  // successful.
  sqlite3_close(_mOurDatabase);
}

- (void)applyScript:(NSString *)script {
  // TODO: For v2.0, return results for all database queries with either YES or
  // NO signalling success or failure.
  BOOL returnValue = YES;
  NSString *ddlFilePath = [[NSBundle mainBundle] pathForResource:script ofType:nil];

  NSError *ddlReadError = nil;
  NSString *ddl = [[NSString alloc] initWithContentsOfFile:ddlFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&ddlReadError];
  if (!ddl) {
    // Output a message.
    [[[UIAlertView alloc] initWithTitle:[ddlReadError localizedDescription]
                                message:[ddlReadError localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
  }
  
  // Split the string into an array using a regex.
  NSArray *items = [ddl componentsSeparatedByPattern:@";$"];

  for (NSInteger i = 0; i < [items count]; i++) {
    NSString *currentStatement = [items objectAtIndex:i];
    if ([[currentStatement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0) {
      NSString *query = [currentStatement stringByAppendingString:@";"];
      // Declare an object to step through the result set.
      sqlite3_stmt *statement;
      
      // Prepare the statement. If it runs without error...
      if (sqlite3_prepare_v2(_mOurDatabase,
                             [query UTF8String],
                             -1,
                             &statement,
                             nil)
          == SQLITE_OK) {
        // Execute the statement
        if (SQLITE_DONE != sqlite3_step(statement)) {
          returnValue = NO;
        }
        // Garbage collect the memory used for running the statement.
        sqlite3_finalize(statement);
      }
    }
  }
}

- (NSString *)extractStringFromScript:(NSString *)scriptFileName
                                value:(NSString *)scriptMeta {
  NSArray *parts = [scriptFileName componentsSeparatedByString:@"."];
  
  if ([scriptMeta isEqualToString:@"major_release_number"]) {
    return [parts objectAtIndex:1];
  }
  else if ([scriptMeta isEqualToString:@"minor_release_number"]) {
    return [parts objectAtIndex:2];
  }
  else if ([scriptMeta isEqualToString:@"point_release_number"]) {
    return [parts objectAtIndex:3];
  }
  else {
    return @"";
  }
}

- (BOOL)doesTableExist:(NSString *)tableName {
  NSString *query = [NSString stringWithFormat:@"select DISTINCT tbl_name from sqlite_master where tbl_name = '%@'", tableName];

  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  BOOL doesExist = NO;
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    if (sqlite3_step(statement) == SQLITE_ROW) {
      doesExist = YES;
    }
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
    if (doesExist) {
      return YES;
    }
  }
  
  return NO;
}

- (NSString *)getDocumentDirectory {
  if (_homeDirectory == nil) {
    _homeDirectory = @"";
    _homeDirectory = [NSHomeDirectory() stringByAppendingPathComponent:DATABASE_PATH];
  }
  
  return _homeDirectory;
}

- (NSInteger)getPragma:(NSString *)pragmaName  {
  NSString *query = [NSString stringWithFormat:@"PRAGMA %@;", pragmaName];
  const char *cQuery = [query UTF8String];
  
  static sqlite3_stmt *statement;
  NSInteger result = 0;
  if (sqlite3_prepare_v2(_mOurDatabase, cQuery, -1, &statement, NULL) == SQLITE_OK) {
    while(sqlite3_step(statement) == SQLITE_ROW) {
      result = sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
  }
  return result;
}

- (NSInteger)setPragma:(NSString *)pragmaName value:(NSString *)pragmaValue  {
  NSString *query = [NSString stringWithFormat:@"PRAGMA %@ = '%@';", pragmaName, pragmaValue];
  const char *cQuery = [query UTF8String];

  static sqlite3_stmt *statement;
  NSInteger result = 0;
  if (sqlite3_prepare_v2(_mOurDatabase, cQuery, -1, &statement, NULL) == SQLITE_OK) {
    while(sqlite3_step(statement) == SQLITE_ROW) {
      result = sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
  }
  return result;
}

- (NSMutableArray *)getNodeListData {
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_NODE_ROWID];
  [columns addObject:KEY_NODE_TITLE];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = @"";
  
  // If the WHERE clause properties were set...
  if (_mLeftOperand != nil && _mRightOperand != nil && _mOperator != nil) {
    // Define the WHERE clause.
    where = [[_mLeftOperand stringByAppendingString:_mOperator] stringByAppendingString:_mRightOperand];
  }
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_NODE];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // ORDER BY
  query = [[[query stringByAppendingString:@" ORDER BY UPPER("] stringByAppendingString:KEY_NODE_TITLE] stringByAppendingString:@")"];
  
  // Declare an array in which to store result data.
  NSMutableArray *retval = [[NSMutableArray alloc] init];
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *titleChars = (char *) sqlite3_column_text(statement, 1);
      
      // Convert the chars to strings.
      NSString *title = [[NSString alloc] initWithUTF8String:titleChars];
      
      // Initialize a new object in which to store the data.
      Node *node = [[Node alloc] init];
      
      // Store all the retrieved column data in a Node object.
      node.identifier = identifier;
      node.title = title;
      
      // Store the node object in the array.
      [retval addObject:node];
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return retval;
}

- (Node *)getNodeData:(NSInteger)l {
  
  // Initialize a new object in which to store the data.
  Node *node = [[Node alloc] init];
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_NODE_ROWID];
  [columns addObject:KEY_NODE_TITLE];
  [columns addObject:KEY_NODE_BODY];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = [KEY_NODE_ROWID stringByAppendingString:@" = "];
  // Append the where id.
  
  where = [where stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_NODE];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *titleChars = (char *) sqlite3_column_text(statement, 1);
      char *bodyChars = (char *) sqlite3_column_text(statement, 2);
      
      // Convert the chars to strings.
      NSString *title = [[NSString alloc] initWithUTF8String:titleChars];
      NSString *body = [[NSString alloc] initWithUTF8String:bodyChars];
      
      // Store all the retrieved column data in a Node object.
      node.identifier = identifier;
      node.title = title;
      node.body = body;
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return node;
}

- (NSInteger)getNodeIsBookmarked:(NSInteger)l {
  
  // Initialize a new object in which to store the data.
  NSInteger isBookmarked = 0;
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_NODE_IS_BOOKMARKED];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = [KEY_NODE_ROWID stringByAppendingString:@" = "];
  // Append the where id.
  where = [where stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_NODE];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      isBookmarked = sqlite3_column_int(statement, 0);
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return isBookmarked;
}

- (NSMutableArray *)getVariableListData {
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_VARIABLES_ROWID];
  [columns addObject:KEY_VARIABLES_KEY];
  [columns addObject:KEY_VARIABLES_VALUE];
  [columns addObject:KEY_VARIABLES_SKU];
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_VARIABLES];
  
  // ORDER BY
  query = [[[query stringByAppendingString:@" ORDER BY UPPER("] stringByAppendingString:KEY_VARIABLES_KEY] stringByAppendingString:@")"];
  
  // Declare an array in which to store result data.
  NSMutableArray *retval = [[NSMutableArray alloc] init];
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *keyChars = (char *) sqlite3_column_text(statement, 1);
      char *valueChars = (char *) sqlite3_column_text(statement, 2);
      char *skuChars = (char *) sqlite3_column_text(statement, 3);
      
      // Convert the chars to strings.
      NSString *key = [[NSString alloc] initWithUTF8String:keyChars];
      NSString *value = [[NSString alloc] initWithUTF8String:valueChars];
      NSString *sku = [[NSString alloc] initWithUTF8String:skuChars];
      
      // Initialize a new object in which to store the data.
      Variable *variable = [[Variable alloc] init];
      
      // Store all the retrieved column data in a Node object.
      variable.identifier = identifier;
      variable.key = key;
      variable.value = value;
      variable.sku = sku;
      
      // Store the node object in the array.
      [retval addObject:variable];
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return retval;
}

- (void)updateNode:(NSInteger)l
            column:(NSString *)column
             value:(NSInteger)value {
  /**
   * Query Building Phase
   */
  NSString *query = @"UPDATE ";
  query = [query stringByAppendingString:DATABASE_TABLE_NODE];
  
  query = [query stringByAppendingString:@" SET "];
  query = [query stringByAppendingString:column];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:[NSString stringWithFormat:@"%d", value]];
  
  query = [query stringByAppendingString:@" WHERE "];
  query = [query stringByAppendingString:@"_id"];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  // Declare a statement.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step.
    sqlite3_step(statement);
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
}

- (void)updateVariable:(NSInteger)l
                column:(NSString *)column
                 value:(NSString *)value {
  /**
   * Query Building Phase
   */
  NSString *query = @"UPDATE ";
  query = [query stringByAppendingString:DATABASE_TABLE_VARIABLES];
  
  query = [query stringByAppendingString:@" SET "];
  query = [query stringByAppendingString:column];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:value];
  
  query = [query stringByAppendingString:@" WHERE "];
  query = [query stringByAppendingString:@"_id"];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  // Declare a statement.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step.
    sqlite3_step(statement);
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
}

- (void)close {
  // Close the database connection.
  if (!_mIsUpgradeTaskInProgress) {
    sqlite3_close(_mOurDatabase);
  }
}

- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand {
  _mLeftOperand = leftOperand;
  _mRightOperand = rightOperand;
  _mOperator = @"=";
}

- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand
       operatorString:(NSString *)operatorString {
  _mLeftOperand = leftOperand;
  _mRightOperand = rightOperand;
  _mOperator = operatorString;
}

- (void)flushQuery {
  _mLeftOperand = nil;
  _mRightOperand = nil;
  _mOperator = nil;
}

- (void)onUpgrade:(sqlite3 *)db
       oldVersion:(NSInteger)oldVersion
       newVersion:(NSInteger)newVersion {
  BOOL tableExists = [self doesTableExist:@"schema"];
  
  if (!tableExists) {
    // most recent script == sc.01.00.0002
    // targetting users who have previously installed the application with the
    // pre-generated database.
    DBUpgradeTask *upgradeTask = [[DBUpgradeTask alloc] initWithContext:self scriptID:@"0002"];
    [upgradeTask execute];
  }
  else {
    // Define an array of columns to SELECT.
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    [columns addObject:KEY_SCHEMA_ROWID];
    [columns addObject:KEY_SCHEMA_MAJOR_RELEASE_NUMBER];
    [columns addObject:KEY_SCHEMA_MINOR_RELEASE_NUMBER];
    [columns addObject:KEY_SCHEMA_POINT_RELEASE_NUMBER];
    [columns addObject:KEY_SCHEMA_SCRIPT_NAME];
    [columns addObject:KEY_SCHEMA_DATE_APPLIED];
    
    /**
     * Query Building Phase
     */
    NSString *query = @"SELECT ";
    
    NSString *columnQuery = @"";
    
    // Iterate through the array of columns and append each to the query.
    for (NSInteger i = 0; i < [columns count]; i++) {
      columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
      
      // If the current column isn't the final column, also append a comma.
      if (i < ([columns count] - 1)) {
        columnQuery = [columnQuery stringByAppendingString:@", "];
      }
    }
    
    query = [query stringByAppendingString:columnQuery];
    
    // Append the table to the query.
    query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_SCHEMA];
    
    // ORDER BY
    query = [[[query stringByAppendingString:@" ORDER BY "] stringByAppendingString:KEY_SCHEMA_SCRIPT_NAME] stringByAppendingString:@" DESC"];
    
    // LIMIT
    query = [query stringByAppendingString:@" LIMIT 1"];
    
    // Declare an object to step through the result set.
    sqlite3_stmt *statement;
    
    // Execute the query. If it runs without error...
    if (sqlite3_prepare_v2(_mOurDatabase,
                           [query UTF8String],
                           -1,
                           &statement,
                           nil)
        == SQLITE_OK) {
      
      NSString *recentScriptID = nil;
      // Step through the result set...
      while (sqlite3_step(statement) == SQLITE_ROW) {
        
        // Store each column from the result set in a local variable.
        char *recentScriptIDChars = (char *) sqlite3_column_text(statement, 4);
        
        // Convert the chars to strings.
        recentScriptID = [self extractStringFromScript:[[NSString alloc] initWithUTF8String:recentScriptIDChars] value:@"point_release_number"];
      }
      
      // Garbage collect the memory used for running the statement.
      sqlite3_finalize(statement);
      DBUpgradeTask *upgradeTask = [[DBUpgradeTask alloc] initWithContext:self scriptID:recentScriptID];
      [upgradeTask execute];
    }
  }
}

@end
