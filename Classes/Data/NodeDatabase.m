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

// Defie the "variables" table SQLite columns
static NSString *const KEY_VARIABLES_ROWID = @"_id";
static NSString *const KEY_VARIABLES_KEY = @"key";
static NSString *const KEY_VARIABLES_VALUE = @"value";
static NSString *const KEY_VARIABLES_SKU = @"sku";

// Define the current schema version.
static NSInteger const SCHEMA_VERSION = 1;


@implementation NodeDatabase

@synthesize homeDirectory = _homeDirectory;
@synthesize databasePath = _databasePath;

@synthesize mLeftOperand = _mLeftOperand;
@synthesize mRightOperand = _mRightOperand;
@synthesize mOperator = _mOperator;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    
  }
  return self;
}

- (void)createDatabase {
  [self createDB];
}

- (void)createDB {
  // Check to see if the database exists. (Typically, on first run, it
  // should not exist yet).
  BOOL dbExist = [self DBExists];
  
  // If a database does not exist, create one.
  if (!dbExist) {
    
    // Copy our pre-populated database in resources to the writeable Documents
    // directory
    [self copyDbFromResource];
    
  }
  
  // Get a readable database for use.
  if (sqlite3_open([_databasePath UTF8String], &_mOurDatabase) != SQLITE_OK) {
    _mOurDatabase = nil;
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

- (void)copyDbFromResource {
  
  // Define the file stream.
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // Define the error logging property.
  NSError *error = nil;
  
  // Set the source and destination paths for the database copy...
  NSString *dbFilePath = @"";
  NSString *copyDbPath = @"";
  dbFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
  copyDbPath = [[self getDocumentDirectory] stringByAppendingPathComponent:DATABASE_NAME];
  
  // If an error occurs...
  [fileManager copyItemAtPath:dbFilePath toPath:copyDbPath error:&error];
  
  // If an error occurred during copy.
  if (error != nil) {
    [[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                message:[error localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
  }
  
  fileManager = nil;
}

- (NSString *)getDocumentDirectory {
  if (_homeDirectory == nil) {
    _homeDirectory = @"";
    _homeDirectory = [NSHomeDirectory() stringByAppendingPathComponent:DATABASE_PATH];
  }
  
  return _homeDirectory;
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
  sqlite3_close(_mOurDatabase);
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

@end
