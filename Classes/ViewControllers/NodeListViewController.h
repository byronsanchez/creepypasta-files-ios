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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Node.h"
#import "NodeDatabase.h"
#import "NodeViewController.h"
#import "Colors.h"

// Displays a list of node items that the user can select.
@interface NodeListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
  
 @private
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  BOOL _isPortrait;
  
  // Define the database access property.
  NodeDatabase *_mDbNodeHelper;
  NSArray *_nodes;
  NSArray *_categories;
  NSString *_controllerInvoker;
  
  UIView *_titleView;
  UITableView *_tableView;
  UILabel *_tvListLabel;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, assign) BOOL isTablet;
@property(nonatomic, strong) NodeDatabase *mDbNodeHelper;
@property(nonatomic, strong) NSArray *nodes;
@property(nonatomic, strong) NSArray *categories;
@property(nonatomic, copy) NSString *controllerInvoker;
@property(nonatomic, strong) IBOutlet UIView *titleView;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) UILabel *tvListLabel;


// Queries the database for a list of nodes and returns an array of results.
- (void)loadList;

// Queries the database for a list of bookmarked nodes and returns an array
// of results.
- (void)loadBookmarks;

// Used by BookmarksActivity to update the listview if bookmarks are
// removed.
- (void)updateList;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
