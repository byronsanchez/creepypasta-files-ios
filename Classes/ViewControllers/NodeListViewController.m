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

#import "NodeListViewController.h"

@interface NodeListViewController ()

@end

@implementation NodeListViewController

@synthesize mDbNodeHelper = _mDbNodeHelper;
@synthesize nodes = _nodes;
@synthesize categories = _categories;
@synthesize controllerInvoker = _controllerInvoker;
@synthesize titleView = _titleView;
@synthesize tableView = _tableView;
@synthesize tvListLabel = _tvListLabel;
@synthesize isTablet = _isTablet;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    
  }
  return self;
}

// Main initializer for the ViewController.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

// Implements viewDidLoad.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation
  // bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  /*
   * This screen needs to be dynamically positioned to fit each screen
   * size fluidly.
   */
  
  _isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
  
  // Get the screen metrics.
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  
  // Use standard metrics. Autoresizing masks will take care of orientation
  // changes.
  _screenWidth = screenRect.size.width;
  _screenHeight = screenRect.size.height;
  
  // DETERMINE DEVICE TYPE
  NSInteger device = UI_USER_INTERFACE_IDIOM();
  
  // Set defaults
  _isTablet = NO;
  _isLarge = NO;
  
  switch (device) {
    case UIUserInterfaceIdiomPhone: {
      if (_screenHeight == 480) {
        
        // iPhone Classic
        _isLarge = NO;
        
      }
      if (_screenHeight == 568) {
        _isLarge = YES;
      }
    }
      break;
      
    case UIUserInterfaceIdiomPad: {
      _isTablet = YES;
    }
      break;
  }
  
  /**
   * UI Elements.
   */
  
  // Set the main view background color.
  [[self view] setBackgroundColor:[UIColor blackColor]];
  
  // ROW PADDING
  CGFloat rowPadding;
  
  // Set row height
  if (_isTablet) {
    rowPadding = 16;
    rowPadding += rowPadding + 26;
    
  }
  else {
    rowPadding = 10;
    rowPadding += rowPadding + 16;
  }
  
  _tableView.rowHeight = rowPadding;
  
  
  // TITLE VIEW
  // ALGORITHMS
  
  UIFont *titleFont;
  
  CGFloat titlePadding;
  CGFloat titleMargin;
  
  if (_isTablet) {
    titlePadding = 20;
    titleMargin = 54;
    titleFont = [UIFont boldSystemFontOfSize:54];
  }
  else {
    titlePadding = 8;
    titleMargin = 22;
    titleFont = [UIFont boldSystemFontOfSize:22];
  }
  
  CGFloat titleHeight = titleFont.pointSize + (titleMargin * 2) + (titlePadding * 2);
  
  // TITLEVIEW
  
  _titleView.frame = CGRectMake(0, 0, _screenWidth, titleHeight);
  [_titleView setBackgroundColor:[UIColor blackColor]];
  [_titleView setContentMode:UIViewContentModeScaleAspectFit];
  [_titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  
  // TABLEVIEW
  _tableView.frame = CGRectMake(0,
                                titleHeight,
                                _screenWidth,
                                (_screenHeight - titleHeight));
  [_tableView setContentMode:UIViewContentModeScaleAspectFit];
  [_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth
                                   | UIViewAutoresizingFlexibleHeight)];
  _tableView.backgroundColor = [UIColor blackColor];
  _tableView.hidden = YES;
  
  // RETURN BUTTON
  
  UIImage *returnButtonImage = [UIImage imageNamed:@"button_return"];
  
  // Set padding for the return button and progress indicator.
  CGFloat returnButtonX = 0;
  CGFloat returnButtonY = (titleHeight / 2) - (returnButtonImage.size.height / 2);
  
  // Return button.
  UIButton *_mIbReturn = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mIbReturn addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  [_mIbReturn setImage:returnButtonImage
              forState:UIControlStateNormal];
  [_mIbReturn setAlpha:1.0];
  _mIbReturn.frame = CGRectMake(returnButtonX,
                                returnButtonY,
                                returnButtonImage.size.width,
                                returnButtonImage.size.height);
  [_mIbReturn setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbReturn setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbReturn setTag:13];
  
  [_titleView addSubview:_mIbReturn];
  
  // TITLE LABEL
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  _screenWidth,
                                                                  titleHeight)];
  [titleLabel setContentMode:UIViewContentModeLeft];
  [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [titleLabel setTextColor:[UIColor whiteColor]];
  [titleLabel setBackgroundColor:[UIColor clearColor]];
  [titleLabel setTextAlignment:UITextAlignmentCenter];
  [titleLabel setFont:titleFont];
  
  [_titleView addSubview:titleLabel];
  
  
  // TITLE VIEW GRADIENT
  UIImageView *titleViewBg = [[UIImageView alloc] initWithFrame:_titleView.bounds];
  [titleViewBg setContentMode:UIViewContentModeScaleToFill];
  [titleViewBg setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  
  // Add gradient to the title view
  CAGradientLayer *filesShineLayer = [CAGradientLayer layer];
  filesShineLayer.frame = titleViewBg.bounds;
  filesShineLayer.colors = [NSArray arrayWithObjects:
                            (id)[Colors colorFromHexString:@"#333333ff"].CGColor,
                            (id)[Colors colorFromHexString:@"#000000ff"].CGColor,
                            nil];
  filesShineLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
  
  // Render an image based off of the generated gradient and set it as the
  // background. 0 indicate that the image created should be at the scale of the
  // main screen, thus proper scaling for all devices.
  UIGraphicsBeginImageContextWithOptions(filesShineLayer.frame.size, NO, 0);
  [filesShineLayer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *filesImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [titleViewBg setImage:filesImage];
  
  [_titleView addSubview:titleViewBg];
  [_titleView sendSubviewToBack:titleViewBg];
  
  
  // If this is a bookmark view controller add a bookmark string.
  if ([_controllerInvoker isEqualToString:@"sMainToBookmarkList"]) {
    
    // BOOKMARK STRING
    
    CGFloat bookmarkFontSize;
    CGFloat bookmarkLabelPadding;
    
    if (_isTablet) {
      bookmarkFontSize = 40;
      bookmarkLabelPadding = 28;
    }
    else {
      bookmarkFontSize = 16;
      bookmarkLabelPadding = 10;
    }
    
    
    UIFont *bookmarkFont = [UIFont systemFontOfSize:bookmarkFontSize];
    
    _tvListLabel = [[UILabel alloc] init];
    _tvListLabel.text = NSLocalizedString(@"bookmarks_help", nil);
    _tvListLabel.textColor = [UIColor whiteColor];
    _tvListLabel.font = bookmarkFont;
    _tvListLabel.hidden = YES;
    _tvListLabel.backgroundColor = [UIColor clearColor];
    _tvListLabel.lineBreakMode = UILineBreakModeWordWrap;
    _tvListLabel.numberOfLines = 0;
    
    [_tvListLabel setContentMode:UIViewContentModeTopLeft];
    [_tvListLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    CGSize maximumLabelSize = CGSizeMake(_screenWidth - (bookmarkLabelPadding * 2),
                                         _screenHeight - (bookmarkLabelPadding * 2));
    CGSize expectedLabelSize = [_tvListLabel.text sizeWithFont:_tvListLabel.font
                                             constrainedToSize:maximumLabelSize
                                                 lineBreakMode:UILineBreakModeWordWrap];
    _tvListLabel.frame = CGRectMake(_tableView.frame.origin.x + bookmarkLabelPadding,
                                    _tableView.frame.origin.y + bookmarkLabelPadding,
                                    expectedLabelSize.width,
                                    expectedLabelSize.height);
    
    [[self view] addSubview:_tvListLabel];
    
  }
  
  
  /**
   * Database source data.
   */
  
  // Create our database access object.
  _mDbNodeHelper = [[NodeDatabase alloc] init];
  
  // Call the create right after initializing the helper, just in case
  // the user has never run the app before.
  [_mDbNodeHelper createDatabase];
  
  // Get the name of the host activity invoking this fragment and load
  // different data depending on that host.
  if ([_controllerInvoker isEqualToString:@"sMainToBookmarkList"]) {
    // Set the title.
    titleLabel.text = NSLocalizedString(@"tv_bookmarks_label", nil);
    // Get a list of bookmarked node titles.
    [self loadBookmarks];
  }
  else {
    // Set the title
    titleLabel.text = NSLocalizedString(@"tv_browse_label", nil);
    
    // Get a list of node titles.
    [self loadList];
  }
  
  // Close the database
  [_mDbNodeHelper close];
}

// Implements viewWillAppear.
- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  if ([_controllerInvoker isEqualToString:@"sMainToBookmarkList"]) {
    
    [self updateList];
    
    // Reload the data in the tableview.
    [_tableView reloadData];
    
    if ([_nodes count] == 0) {
      // Remove the tableview and add the label view.
      _tvListLabel.hidden = NO;
      _tableView.hidden = YES;
    }
    else {
      // Remove the label view and add the table view.
      _tvListLabel.hidden = YES;
      _tableView.hidden = NO;
    }
  }
  // Else this is a browse list, and only the table view needs to be displayed
  else {
    _tableView.hidden = NO;
  }
}

- (void)loadList {
  // Run the query.
  _nodes = [_mDbNodeHelper getNodeListData];
}

- (void)loadBookmarks {
  // Set the WHERE clause
  [_mDbNodeHelper setConditions:@"is_bookmarked" rightOperand:@"1"];
  // Run the query.
  _nodes = [_mDbNodeHelper getNodeListData];
  // Flush the query builder properties.
  [_mDbNodeHelper flushQuery];
}

- (void)updateList {
  
  if ([_controllerInvoker isEqualToString:@"sMainToBookmarkList"]) {
    
    // Call the create right after initializing the helper, just in case
    // the user has never run the app before.
    [_mDbNodeHelper createDatabase];
    
    // Get a list of bookmarked node titles.
    [self loadBookmarks];
    
    // Close the database
    [_mDbNodeHelper close];
  }
  else if ([_controllerInvoker isEqualToString:@"sMainToNodeList"]) {
    
    // Call the create right after initializing the helper, just in case
    // the user has never run the app before.
    [_mDbNodeHelper createDatabase];
    
    // Get a list of bookmarked node titles.
    [self loadList];
    
    // Close the database
    [_mDbNodeHelper close];
  }
  
}

// Implements viewDidUnload.
- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

// Returns whether or not a UI orientation change should occur based on the
// current physical device orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

#pragma mark - Table view data source
// Return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [_nodes count];
  
}

// Configures the cells in the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"nodeListCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  // Set the style of the table view
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
  }
  
  // Get the object in the array corresponding to the current row.
  Node *node = [_nodes objectAtIndex:indexPath.row];
  // Set the title on the cell appropriately.
  cell.textLabel.text = node.title;
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  cell.textLabel.numberOfLines = 0;
  cell.selectionStyle = UITableViewCellSelectionStyleGray;
  
  if (_isTablet) {
    cell.textLabel.font = [UIFont systemFontOfSize:26.0f];
  }
  else {
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
  }
  
  return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
// Handles cell selection events.
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Remove the selection so it doesn't show up when the user navigates back to
  // this view.
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  // Launch the credits view.
  NodeViewController *nodeViewController;
  
  if (_isTablet) {
    nodeViewController = [[NodeViewController alloc] initWithNibName:@"NodeViewController_iPad"
                                                              bundle:nil];
  }
  else {
    
    if (_isLarge) {
      // iPhone 5+
      nodeViewController = [[NodeViewController alloc] initWithNibName:@"NodeViewController_iPhoneLarge"
                                                                bundle:nil];
    }
    else {
      // iPhone Classic
      nodeViewController = [[NodeViewController alloc] initWithNibName:@"NodeViewController_iPhone"
                                                                bundle:nil];
    }
  }
  
  // Get the object in the array corresponding to the current row.
  Node *node = [_nodes objectAtIndex:indexPath.row];
  nodeViewController.mId = node.identifier;
  
  [self.navigationController pushViewController:nodeViewController
                                       animated:YES];
  
}

- (IBAction)onClick:(id)sender {
  
  switch ([sender tag]) {
      // The return button.
    case 13: {
      
      [self.navigationController popViewControllerAnimated:YES];
      
    }
      
      break;
  }
  
}

@end
