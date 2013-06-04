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
  
}

@property(nonatomic, copy) NSString *homeDirectory;
@property(nonatomic, copy) NSString *databasePath;
@property(nonatomic, copy) NSString *mLeftOperand;
@property(nonatomic, copy) NSString *mRightOperand;
@property(nonatomic, copy) NSString *mOperator;


// Wrapper method for creating the database. Intended for external access.
- (void)createDatabase;

// Creates the database or establishes the database connection.
- (void)createDB;

// Checks to see if a database file exists in the default system location.
- (BOOL)DBExists;

// Copies our pre-populated database to the default system database location
// for our application.
- (void)copyDbFromResource;

// Returns the path of the document directory.
- (NSString *)getDocumentDirectory;

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

@end
