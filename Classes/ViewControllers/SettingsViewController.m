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

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize mTextSizeArray = _mTextSizeArray;
@synthesize mButtonSettingsTextSize = _mButtonSettingsTextSize;

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
	// Do any additional setup after loading the view.
  
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
  
  // Define the text size array.
  NSNumber *extraSmall = [NSNumber numberWithInt:12];
  NSNumber *small = [NSNumber numberWithInt:14];
  NSNumber *normal = [NSNumber numberWithInt:16];
  NSNumber *large = [NSNumber numberWithInt:18];
  NSNumber *extraLarge = [NSNumber numberWithInt:22];
  
  _mTextSizeArray = [[NSMutableArray alloc] init];
  [_mTextSizeArray addObject:extraSmall];
  [_mTextSizeArray addObject:small];
  [_mTextSizeArray addObject:normal];
  [_mTextSizeArray addObject:large];
  [_mTextSizeArray addObject:extraLarge];
  
  // If the current device is a tablet, increase the font sizes
  if (_isTablet) {
    for (NSInteger i = 0; i < [_mTextSizeArray count]; i++) {
      [_mTextSizeArray replaceObjectAtIndex:i
                                 withObject:[NSNumber numberWithInt:[[_mTextSizeArray objectAtIndex:i] intValue] + 4]];
    }
  }
  
  /**
   * UI Elements.
   */
  
  // Set the main view background color.
  [[self view] setBackgroundColor:[UIColor blackColor]];
  
  // TITLE VIEW
  // ALGORITHMS
  
  UIFont *titleFont;
  UIFont *rowFont;
  UIFont *previewFont;
  
  CGFloat titlePadding;
  CGFloat titleMargin;
  CGFloat rowPadding;
  CGFloat rowMargin;
  CGFloat lineBreakPointSize;
  
  if (_isTablet) {
    titlePadding = 20;
    titleMargin = 54;
    titleFont = [UIFont boldSystemFontOfSize:54];
    
    rowPadding = 20;
    rowMargin = 80;
    rowFont = [UIFont systemFontOfSize:40];
    
    previewFont = [UIFont boldSystemFontOfSize:30];
    lineBreakPointSize = 20;
  }
  else {
    titlePadding = 8;
    titleMargin = 22;
    titleFont = [UIFont boldSystemFontOfSize:22];
    
    rowPadding = 8;
    rowMargin = 32;
    rowFont = [UIFont systemFontOfSize:16];
    
    previewFont = [UIFont boldSystemFontOfSize:12];
    lineBreakPointSize = 8;
  }
  
  CGFloat titleHeight = titleFont.pointSize + (titleMargin * 2) + (titlePadding * 2);
  // First button must be declared early to determine button size.
  UIImage *nextButtonImage = [UIImage imageNamed:@"button_dropdown"];
  CGFloat rowHeight = MAX((rowFont.pointSize + rowPadding * 2), nextButtonImage.size.height + (rowPadding * 2));
  CGFloat rowXOffsetLabel = rowMargin;
  CGFloat rowXOffsetButton = (_screenWidth) - rowMargin;
  
  // TITLEVIEW
  
  _titleView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        0,
                                                        _screenWidth,
                                                        titleHeight)];
  [_titleView setBackgroundColor:[UIColor blackColor]];
  [_titleView setContentMode:UIViewContentModeLeft];
  [_titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  
  // RETURN BUTTON
  
  UIImage *returnButtonImage = [UIImage imageNamed:@"button_return"];
  
  // Set padding for the return button and progress indicator.
  CGFloat returnButtonX = 0;
  CGFloat returnButtonY = (titleHeight / 2) - (returnButtonImage.size.height / 2);
  
  // Return button.
  _mIbReturn = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mIbReturn addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  [_mIbReturn setImage:returnButtonImage forState:UIControlStateNormal];
  [_mIbReturn setAlpha:1.0];
  _mIbReturn.frame = CGRectMake(returnButtonX,
                                returnButtonY,
                                returnButtonImage.size.width,
                                returnButtonImage.size.height);
  [_mIbReturn setContentMode:UIViewContentModeLeft];
  [_mIbReturn setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbReturn setTag:14];
  
  [_titleView addSubview:_mIbReturn];
  
  // TITLE LABEL
  
  _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                          0,
                                                          _screenWidth,
                                                          titleHeight)];
  [_titleLabel setContentMode:UIViewContentModeLeft];
  [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [_titleLabel setTextColor:[UIColor whiteColor]];
  [_titleLabel setBackgroundColor:[UIColor clearColor]];
  [_titleLabel setTextAlignment:UITextAlignmentCenter];
  [_titleLabel setFont:titleFont];
  _titleLabel.text = NSLocalizedString(@"tv_settings_label", nil);
  
  [_titleView addSubview:_titleLabel];
  
  [[self view] addSubview:_titleView];
  
  // CENTERING THE TEXT LABEL AND PREVIEW WITH THE DROPDOWN BUTTON ALGORITHM
  // (one row centered and factor in the additional height added by the preview,
  // and subtract half of this new height from the y position of each view).
  CGFloat textLabelFinal = (rowHeight * 0) + titleHeight - ((previewFont.pointSize + lineBreakPointSize) / 2);
  CGFloat textSizePreview = (((rowHeight * 0) + titleHeight) + previewFont.pointSize) + lineBreakPointSize - ((previewFont.pointSize + lineBreakPointSize) / 2);
  
  
  // TEXT SIZE LABEL
  
  _mLabelTextSize = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                              textLabelFinal,
                                                              _screenWidth,
                                                              rowHeight)];
  _mLabelTextSize.text = NSLocalizedString(@"tv_settings_text_size_label", nil);
  [_mLabelTextSize setContentMode:UIViewContentModeLeft];
  [_mLabelTextSize setAutoresizingMask:UIViewAutoresizingNone];
  [_mLabelTextSize setTextColor:[UIColor whiteColor]];
  [_mLabelTextSize setBackgroundColor:[UIColor clearColor]];
  [_mLabelTextSize setTextAlignment:UITextAlignmentLeft];
  [_mLabelTextSize setFont:rowFont];
  
  [[self view] addSubview:_mLabelTextSize];
  
  
  _mButtonTextSize = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mButtonTextSize addTarget:self
                       action:@selector(onClick:)
             forControlEvents:UIControlEventTouchUpInside];
  //UIImage *musicButtonImageStop = [UIImage imageNamed:@"button_stop"];
  [_mButtonTextSize setImage:nextButtonImage forState:UIControlStateNormal];
  //[musicButton setImage:musicButtonImageStop forState:UIControlStateSelected];
  
  [_mButtonTextSize setContentMode:UIViewContentModeLeft];
  [_mButtonTextSize setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
  _mButtonTextSize.frame = CGRectMake(rowXOffsetButton - nextButtonImage.size.width,
                                      (rowHeight * 0) + titleHeight,
                                      nextButtonImage.size.width,
                                      rowHeight);
  [_mButtonTextSize setTag:5];
  [_mButtonTextSize setSelected:NO];
  
  
  [[self view] addSubview:_mButtonTextSize];
  
  
  // TEXTSIZE CURRENT SELECTION LABEL
  
  _mCurrentSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                                 textSizePreview,
                                                                 rowFont.pointSize * 5,
                                                                 rowHeight)];
  [_mCurrentSizeLabel setContentMode:UIViewContentModeLeft];
  [_mCurrentSizeLabel setAutoresizingMask:UIViewAutoresizingNone];
  [_mCurrentSizeLabel setTextColor:[Colors colorFromHexString:@"#828282FF"]];
  [_mCurrentSizeLabel setBackgroundColor:[UIColor clearColor]];
  [_mCurrentSizeLabel setTextAlignment:UITextAlignmentLeft];
  [_mCurrentSizeLabel setFont:previewFont];
  
  [[self view] addSubview:_mCurrentSizeLabel];
  
  
  // SHOP LABEL
  
  _mLabelShop = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                          (rowHeight * 1) + titleHeight,
                                                          _screenWidth,
                                                          rowHeight)];
  _mLabelShop.text = NSLocalizedString(@"tv_settings_shop_label", nil);
  [_mLabelShop setContentMode:UIViewContentModeLeft];
  [_mLabelShop setAutoresizingMask:UIViewAutoresizingNone];
  [_mLabelShop setTextColor:[UIColor whiteColor]];
  [_mLabelShop setBackgroundColor:[UIColor clearColor]];
  [_mLabelShop setTextAlignment:UITextAlignmentLeft];
  [_mLabelShop setFont:rowFont];
  
  [[self view] addSubview:_mLabelShop];
  
  
  UIButton *shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [shopButton addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  UIImage *shopButtonImage = [UIImage imageNamed:@"button_next"];
  [shopButton setImage:shopButtonImage forState:UIControlStateNormal];
  shopButton.frame = CGRectMake(rowXOffsetButton - shopButtonImage.size.width,
                                (rowHeight * 1) + titleHeight,
                                shopButtonImage.size.width,
                                rowHeight);
  [shopButton setContentMode:UIViewContentModeScaleAspectFit];
  [shopButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
  [shopButton setTag:6];
  
  [[self view] addSubview:shopButton];
  
  // Create a reference to this via via an instance variable.
  _mButtonShop = shopButton;
  
  // CREDITS LABEL
  
  
  _mLabelCredits = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                             (rowHeight * 2) + titleHeight,
                                                             _screenWidth,
                                                             rowHeight)];
  _mLabelCredits.text = NSLocalizedString(@"tv_settings_credits_label", nil);
  [_mLabelCredits setContentMode:UIViewContentModeLeft];
  [_mLabelCredits setAutoresizingMask:UIViewAutoresizingNone];
  [_mLabelCredits setTextColor:[UIColor whiteColor]];
  [_mLabelCredits setBackgroundColor:[UIColor clearColor]];
  [_mLabelCredits setTextAlignment:UITextAlignmentLeft];
  [_mLabelCredits setFont:rowFont];
  
  [[self view] addSubview:_mLabelCredits];
  
  
  UIButton *creditsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [creditsButton addTarget:self
                    action:@selector(onClick:)
          forControlEvents:UIControlEventTouchUpInside];
  UIImage *creditsButtonImage = [UIImage imageNamed:@"button_next"];
  [creditsButton setImage:creditsButtonImage forState:UIControlStateNormal];
  creditsButton.frame = CGRectMake(rowXOffsetButton - creditsButtonImage.size.width,
                                   (rowHeight * 2) + titleHeight,
                                   creditsButtonImage.size.width,
                                   rowHeight);
  [creditsButton setContentMode:UIViewContentModeScaleAspectFit];
  [creditsButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
  [creditsButton setTag:7];
  
  [[self view] addSubview:creditsButton];
  
  // Create a reference to this via via an instance variable.
  _mButtonCredits = creditsButton;
  
  // KG MODAL CONTENT VIEW
  _cellCounter = 0;
  _KGContentView = [[UIView alloc] init];
  
  _KGContentView.frame = CGRectMake(0, 0, 280, 220);
  _KGContentView.backgroundColor = [UIColor blackColor];
  
  // Create the table view.
  CGRect tableViewRect = _KGContentView.bounds;
  UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewRect];
  
  // Set the delegate data source for the table view.
  tableView.delegate = self;
  tableView.dataSource = self;
  tableView.backgroundColor = [UIColor clearColor];
  tableView.bounces = NO;
  tableView.scrollEnabled = NO;
  tableView.tag = 8;
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [_KGContentView addSubview:tableView];
  
  // Update output based on stored preferences, if any.
  [self updateView];
  
}

// Implements viewWillAppear.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateView];
}

// Implements viewDidUnload.
- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
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

- (void)updateView {
  
  /**
   * UPDATE DATA FROM PREFERENCES
   */
  
  // Get the set or default preference for text size and spinner display (the index).
  NSInteger defaultInteger = 2;
  NSInteger spinnerDefaultItem = [Preferences getPreferenceInt:@"spinnerDefaultItem"
                                                  defaultValue:defaultInteger];
  
  // Update spinner default selection view. This is needed for the initial
  // loading of this view. In manual selections, it's redundant.
  _mButtonSettingsTextSize.titleLabel.hidden = NO;
  _mButtonSettingsTextSize.titleLabel.textColor = [UIColor blackColor];
  
  // Switching against array indices.
  switch (spinnerDefaultItem) {
      
      // Extra small
    case 0: {
      [_mButtonSettingsTextSize setTitle:@"Extra Small"
                                forState:UIControlStateNormal];
      _mCurrentSizeLabel.text = @"Extra Small";
    }
      break;
      
      // Small
    case 1: {
      [_mButtonSettingsTextSize setTitle:@"Small"
                                forState:UIControlStateNormal];
      _mCurrentSizeLabel.text = @"Small";
    }
      break;
      
      // Normal
    case 2: {
      [_mButtonSettingsTextSize setTitle:@"Normal"
                                forState:UIControlStateNormal];
      _mCurrentSizeLabel.text = @"Normal";
    }
      break;
      
      // Large
    case 3: {
      [_mButtonSettingsTextSize setTitle:@"Large"
                                forState:UIControlStateNormal];
      _mCurrentSizeLabel.text = @"Large";
    }
      break;
      
      // Extra large
    case 4: {
      [_mButtonSettingsTextSize setTitle:@"Extra Large"
                                forState:UIControlStateNormal];
      _mCurrentSizeLabel.text = @"Extra Large";
    }
      break;
  }
}

// Provides information for the table view.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return [_mTextSizeArray count];
  
}

// Provides information for the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"nodeListCell";
  
  _cellCounter++;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  // Set the style of the table view
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
  }
  
  // Get the object in the array corresponding to the current row.
  NSNumber *textSize = [_mTextSizeArray objectAtIndex:indexPath.row];
  
  // Set the title on the cell appropriately.
  cell.textLabel.adjustsFontSizeToFitWidth = NO;
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.font = [cell.textLabel.font fontWithSize:textSize.intValue];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  // Switching against array indices.
  switch (indexPath.row) {
      
      // Extra small
    case 0: {
      cell.textLabel.text = @"Extra Small";
    }
      break;
      
      // Small
    case 1: {
      cell.textLabel.text = @"Small";
    }
      break;
      
      // Normal
    case 2: {
      cell.textLabel.text = @"Normal";
    }
      break;
      
      // Large
    case 3: {
      cell.textLabel.text = @"Large";
    }
      break;
      
      // Extra large
    case 4: {
      cell.textLabel.text = @"Extra Large";
    }
      break;
  }
  
  CGFloat newTableHeight = _cellCounter * cell.frame.size.height;
  
  tableView.frame = CGRectMake(tableView.frame.origin.x,
                               tableView.frame.origin.y,
                               tableView.frame.size.width,
                               newTableHeight);
  [self updateKgFrame:tableView.frame];
  
  // Add a seperator only in between cells.
  if (indexPath.row != 0) {
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         tableView.frame.size.width,
                                                                         1)];
    separatorLineView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:separatorLineView];
  }
  
  return cell;
}

#pragma mark - Table view delegate

// Handles table cell selection events.
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
  
  /**
   * Handles tableview select events.
   */
  
  // Store the preference and close the tableview.
  [Preferences setPreferenceInt:@"spinnerDefaultItem" value:indexPath.row];
  [Preferences setPreferenceInt:@"textSize" value:indexPath.row];
  
  // Update the text size displays.
  [self updateView];
  
  // Dismiss the tableview.
  [[KGModal sharedInstance] hideAnimated:YES];
}

- (void) updateKgFrame:(CGRect)newFrame {
  
  _KGContentView.bounds = newFrame;
  
}

- (IBAction)onClick:(id)sender {
  switch ([sender tag]) {
      // The Text Size Button
    case 5: {
      
      // This simply acts as a saftey net after the initial table build. It's
      // useless and can be removed.
      _cellCounter = 0;
      
      // Show the modal view.
      [[KGModal sharedInstance] setShowCloseButton:YES];
      [[KGModal sharedInstance] setAnimateWhenDismissed:YES];
      [[KGModal sharedInstance] showWithContentView:_KGContentView
                                        andAnimated:YES];
      [[KGModal sharedInstance] setModalBackgroundColor:[Colors colorFromHexString:@"#000000FF"]];
      [[KGModal sharedInstance] setBackgroundDisplayStyle:KGModalBackgroundDisplayStyleSolid];
      
    }
      break;
      
      // Shop Button
    case 6: {
      // Launch the shop view.
      ShopViewController *shopViewController;
      
      if (_isTablet) {
        shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopViewController_iPad"
                                                                  bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopViewController_iPhoneLarge"
                                                                    bundle:nil];
        }
        else {
          // iPhone Classic
          shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopViewController_iPhone"
                                                                    bundle:nil];
        }
      }
      
      [self.navigationController pushViewController:shopViewController
                                           animated:YES];
    }
      
      break;
      
      // Credits Button
    case 7: {
      // Launch the credits view.
      CreditsViewController *creditsViewController;
      
      if (_isTablet) {
        creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController_iPad"
                                                                        bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController_iPhoneLarge"
                                                                          bundle:nil];
        }
        else {
          // iPhone Classic
          creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController_iPhone"
                                                                          bundle:nil];
        }
      }
      
      [self.navigationController pushViewController:creditsViewController
                                           animated:YES];
    }
      
      break;
      
      // The return button.
    case 14: {
      [self.navigationController popViewControllerAnimated:YES];
    }
      
      break;
  }
}

@end
