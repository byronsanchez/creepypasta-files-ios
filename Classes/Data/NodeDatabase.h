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

#import <Foundation/Foundation.h>
#include <sqlite3.h>

#import "DBUpgradeTask.h"
#import "NSString+RegexSplitAdditions.h"
#import "Node.h"
#import "Variable.h"
#import "Category.h"

// Handles all database requests made by the application.
@interface NodeDatabase : NSObject {
  
 @private
  
  // Define the actual database property.
  sqlite3 *_mOurDatabase;
  NSString *_homeDirectory;
  NSString *_databasePath;
  
  // Define query builder properties.
  NSString *_mLeftOperand;
  NSString *_mRightOperand;
  NSString *_mOperator;
  
  // A boolean signaling whether or not an upgrade task is in progress.
  BOOL _mIsUpgradeTaskInProgress;
}

@property(nonatomic, copy) NSString *homeDirectory;
@property(nonatomic, copy) NSString *databasePath;
@property(nonatomic, copy) NSString *mLeftOperand;
@property(nonatomic, copy) NSString *mRightOperand;
@property(nonatomic, copy) NSString *mOperator;
@property(nonatomic, assign) BOOL mIsUpgradeTaskInProgress;

// Wrapper method for creating the database. Intended for external access.
- (void)createDatabase;

// Creates the database or establishes the database connection.
- (void)createDB;

// Checks to see if a database file exists in the default system location.
- (BOOL)DBExists;

// Runs updates from the specified script ID an all subsequent available
// updates.
- (void)runUpdates:(NSString *)recentScriptID;

// Applies a change-script to the database.
- (void)applyScript:(NSString *)script;

// Extracts the specified portion of the script file name.
- (NSString *)extractStringFromScript:(NSString *)scriptFileName
                                value:(NSString *)scriptMeta;

// Returns whether or not a table exists in the database.
- (BOOL)doesTableExist:(NSString *)tableName;

// Returns the path of the document directory.
- (NSString *)getDocumentDirectory;

// Returns the value of a SQLite pragma.
- (NSInteger)getPragma:(NSString *)pragmaName;

// Sets the value of a SQLite pragma.
- (NSInteger)setPragma:(NSString *)pragma_name value:(NSString *)pragmaValue;

// Returns a full list of node titles.
- (NSMutableArray *)getNodeListData;

// Returns a single node row containing all column data.
- (Node *)getNodeData:(NSInteger)l;

// Queries the node table to detemine whether or not a row is bookmarked
- (NSInteger)getNodeIsBookmarked:(NSInteger)l;

// Returns a full list of variables from the variables table.
- (NSMutableArray *)getVariableListData;

// Updates a node column.
- (void)updateNode:(NSInteger)l
            column:(NSString *)column
             value:(NSInteger)value;

// Updates a variable column.
- (void)updateVariable:(NSInteger)l
                column:(NSString *)column
                 value:(NSString *)value;

// Closes the database connection.
- (void)close;

// Sets conditions for a potential WHERE clause.
- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand;

// Sets conditions for a potential WHERE clause.
- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand
       operatorString:(NSString *)operatorString;

// Flushes any query builder properties.
- (void)flushQuery;

// If updates are available, applies the updates to the database.
- (void)onUpgrade:(sqlite3 *)db
       oldVersion:(NSInteger)oldVersion
       newVersion:(NSInteger)newVersion;

@end
