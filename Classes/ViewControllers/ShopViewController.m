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

#import "ShopViewController.h"

@interface ShopViewController ()

@end

@implementation ShopViewController

@synthesize mIbHashMap = _mIbHashMap;
@synthesize mSvShopBody = _mSvShopBody;

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
  
  // Allocate and initialize the database object.
  _mDbNodeHelper = [[NodeDatabase alloc] init];
  
  // Allocate and initialize the boolean and UI reference hashmaps.
  _mHas = [[NSMutableDictionary alloc] init];
  _mIbHashMap = [[NSMutableDictionary alloc] init];
  
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
  
  // Set the view background color.
  [[self view] setBackgroundColor:[Colors colorFromHexString:@"#000000FF"]];
  
  
  // ALGORITHMS
  
  UIFont *titleFont;
  
  UIFont *descriptionFont;
  CGFloat descriptionPadding;
  
  CGFloat titlePadding;
  CGFloat titleMargin;
  
  CGFloat rowPadding;
  CGFloat rowMargin;
  
  if (_isTablet) {
    titlePadding = 20;
    titleMargin = 54;
    titleFont = [UIFont boldSystemFontOfSize:54];
    
    descriptionFont = [UIFont italicSystemFontOfSize:40];
    descriptionPadding = 20;
    
    rowPadding = 20;
    rowMargin = 80;
    _rowFont = [UIFont systemFontOfSize:40];
  }
  else {
    titlePadding = 8;
    titleMargin = 22;
    titleFont = [UIFont boldSystemFontOfSize:22];
    
    descriptionFont = [UIFont italicSystemFontOfSize:16];
    descriptionPadding = 8;
    
    rowPadding = 8;
    rowMargin = 32;
    _rowFont = [UIFont systemFontOfSize:16];
  }
  
  _titleHeight = titleFont.pointSize + (titleMargin * 2) + (titlePadding * 2);
  _descriptionHeight = descriptionFont.pointSize + (descriptionPadding * 2);
  
  // First button must be declared early to determine button size.
  UIImage *musicButtonImagePlay = [UIImage imageNamed:@"button_shop"];
  _rowHeight = MAX((_rowFont.pointSize + rowPadding * 2),
                          musicButtonImagePlay.size.height + (rowPadding * 2));
  _rowXOffsetLabel = rowMargin;
  _rowXOffsetButton = (_screenWidth) - rowMargin;
  
  
  // TITLEVIEW
  
  _titleView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        0,
                                                        _screenWidth,
                                                        _titleHeight)];
  [_titleView setBackgroundColor:[UIColor blackColor]];
  [_titleView setContentMode:UIViewContentModeLeft];
  [_titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  
  // RETURN BUTTON
  
  UIImage *returnButtonImage = [UIImage imageNamed:@"button_return"];
  
  // Set padding for the return button and progress indicator.
  CGFloat returnButtonX = 0;
  CGFloat returnButtonY = (_titleHeight / 2) - (returnButtonImage.size.height / 2);
  
  // Return button.
  UIButton *_mIbReturn = [UIButton buttonWithType:UIButtonTypeCustom];
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
  [_mIbReturn setTag:13];
  
  [_titleView addSubview:_mIbReturn];
  
  // TITLE LABEL
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  _screenWidth,
                                                                  _titleHeight)];
  [titleLabel setContentMode:UIViewContentModeLeft];
  [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [titleLabel setTextColor:[UIColor whiteColor]];
  [titleLabel setBackgroundColor:[UIColor clearColor]];
  [titleLabel setTextAlignment:UITextAlignmentCenter];
  [titleLabel setFont:titleFont];
  titleLabel.text = NSLocalizedString(@"tv_shop_text", nil);
  
  [_titleView addSubview:titleLabel];
  
  [[self view] addSubview:_titleView];
  
  // SCROLLVIEW
  
  _mSvShopBody.frame = CGRectMake(0,
                                 _titleHeight,
                                 _screenWidth,
                                 (_screenHeight - _titleHeight));
  [_mSvShopBody setContentMode:UIViewContentModeScaleAspectFit];
  [_mSvShopBody setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
  
  // Set initial color so initial transitions don't show a white bg.
  _mSvShopBody.backgroundColor = [UIColor clearColor];
  _mSvShopBody.opaque = NO;
  
  // Make the scrollbar indicator white.
  _mSvShopBody.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  
  // TV SHOP DESCRIPTION (WITHIN SV)
  UILabel *descriptionLabel = [[UILabel alloc] init];
  descriptionLabel.text = NSLocalizedString(@"tv_shop_description", nil);
  [descriptionLabel setContentMode:UIViewContentModeLeft];
  [descriptionLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
  [descriptionLabel setTextColor:[UIColor whiteColor]];
  [descriptionLabel setBackgroundColor:[UIColor clearColor]];
  [descriptionLabel setTextAlignment:UITextAlignmentCenter];
  descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
  descriptionLabel.numberOfLines = 0;
  [descriptionLabel setFont:descriptionFont];
  
  CGSize maximumLabelSize = CGSizeMake(_screenWidth - (descriptionPadding * 2),
                                       _screenHeight - (descriptionPadding * 2));
  CGSize expectedLabelSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:UILineBreakModeWordWrap];
  _descriptionHeight = expectedLabelSize.height + (2 * descriptionPadding);
  descriptionLabel.frame = CGRectMake(((_screenWidth / 2) - (expectedLabelSize.width / 2)),
                                  descriptionPadding,
                                  expectedLabelSize.width,
                                  _descriptionHeight);
  [_mSvShopBody addSubview:descriptionLabel];
  

  // ACTIVITY INDICATOR
  
  // Create the progressbar view
  if (_isTablet) {
    _mPbShopQuery = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  }
  else {
    _mPbShopQuery = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  }
  
  [_mPbShopQuery setHidden:YES];
  
  // Configure the progress bar positioning (center of the screen, minus the title height).
  _mPbShopQuery.frame = CGRectMake((_screenWidth / 2) - (_mPbShopQuery.frame.size.width / 2),
                                    (((_screenHeight - _titleHeight) / 2) - (_mPbShopQuery.frame.size.height / 2)) + _titleHeight,
                                    _mPbShopQuery.frame.size.width,
                                    _mPbShopQuery.frame.size.height);
  
  [_mPbShopQuery setContentMode:UIViewContentModeCenter];
  [_mPbShopQuery setAutoresizingMask:(UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin)];
  
  // Add the progress bar to the main view.
  [[self view] addSubview:_mPbShopQuery];
  
  // Load state data.
  [self loadData];
  
  // Create all buttons based on the data in the categories table in the
  // db.
  [self createButtons];
  
  // Set the wait screen as the initial view.
  [self setWaitScreen:YES];
  
  // Register a transaction observer with the payment queue.
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  
  // Start setup. This is asynchronous and the response handler method
  // |[self productsRequest]| will be called once setup completes.
  [self requestProductData];
}

// Removes the transaction observer when the view is exited.
- (void)dealloc {
  // Cancel the products request if it exists.
  _request.delegate = nil;
  [_request cancel];
  _request = nil;
  
  // Clean up the transaction observer.
  [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)requestProductData {
  
  NSMutableArray *skuSet = [[NSMutableArray alloc] init];
  
  // Create a set of SKUs from our now locally-cached inventory data.
  for (NSInteger i = 0; i < [_mVariableData count]; i++) {
    Variable *variable = [_mVariableData objectAtIndex:i];
    
    [skuSet addObject:variable.sku];
    
  }
  
  // Create the products request.
  _request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:skuSet]];
  _request.delegate = self;
  [_request start];
  
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  
  _myProducts = [[NSMutableDictionary alloc] init];
  
  // Create a mutable dictionary of the product responses
  // TODO: Figure out how to handle negative responses.
  for (NSInteger i = 0; i < [_mVariableData count]; i++) {
    
    Variable *variable = [_mVariableData objectAtIndex:i];
    
    [_myProducts setValue:[response.products objectAtIndex:i] forKey:variable.sku];
    
  }
  
  // Populate UI from the products list.
  // Save a reference to the products list. When the user selects a product to
  // buy, I will need a product obect to create the payment request.
  // Do we have the items.
  // mHas.put(category.sku, inventory.hasPurchase(category.sku));
  
  // If we can't find it via the inventory, we might not have an
  // internet connection, so check the database.
  
  // Ensure that the database contains the purchase information.
  // TODO: See if there's a way to get the data directly from apple and use that
  // instead.
  [self checkDatabase];
  
  [self updateUi];
  [self setWaitScreen:NO];
  
  
}

- (void)provideContent:(NSString *)productIdentifier {
  
  for (NSInteger i = 0; i < [_mVariableData count]; i++) {
    
    // Store the current iteration's item object locally.
    Variable *variable = [_mVariableData objectAtIndex:i];
    
    
    if ([productIdentifier isEqualToString:variable.sku]) {
      // bought a coloring book!
      [self alert:[variable.key stringByAppendingString:@" feature has been added! You will no longer see ads."]];
      [_mHas setValue:[NSNumber numberWithBool:YES] forKey:variable.sku];

      // Ensure that the database contains the purchase
      // information.
      [self checkDatabase];
      
      [self updateUi];
      [self setWaitScreen:NO];
      
    }
  }
  
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    
    switch (transaction.transactionState) {
        
      case SKPaymentTransactionStatePurchased: {
        
        [self completeTransaction:transaction];
        
      }
        
        break;
        
      case SKPaymentTransactionStateFailed: {
        
        [self failedTransaction:transaction];
        
      }
        
        break;
        
      case SKPaymentTransactionStateRestored: {
        
        [self restoreTransaction:transaction];
        
      }
        
        break;
        
      default: {
        
      }
        
        break;
        
    }
    
  }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  
  // TODO: Consider recording transaction information to establish an audit
  // trail.
  // [self recordTransaction:transaction];
  
  // Update content for the user.
  [self provideContent:transaction.payment.productIdentifier];
  
  // Remove the transaction from the payment queue.
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
  
  // TODO: Consider recording transaction information to establish an audit
  // trail.
  // [self recordTransaction:transaction];
  
  // Update content for the user.
  [self provideContent:transaction.originalTransaction.payment.productIdentifier];
  
  // Remove the transaction from the payment queue.
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  
  if (transaction.error.code != SKErrorPaymentCancelled) {
    
    // Optionally, display an error here.
    
  }
  
  // Remove the wait screen.
  [self updateUi];
  [self setWaitScreen:NO];
  
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
  
  // Update the UI.
  [self updateUi];
  [self setWaitScreen:NO];
  
}

- (void)updateUi {
  
  // update the shop buttons to reflect whether or not the user has bought
  // the item.
  for (NSString *sku in _mIbHashMap) {
    
    // Store a reference to the current iteration's Image Holder.
    UIButton *ibHolder = [_mIbHashMap objectForKey:sku];
    
    // The buy button should only work when this product has not yet
    // been purchased.
    [ibHolder setEnabled:([[_mHas objectForKey:sku] boolValue] ? NO : YES)];
  }
  
  // Redraw the view.
  [_mSvShopBody setNeedsDisplay];
}

// Enables or disables the "please wait" screen.
- (void)setWaitScreen:(BOOL)set {
  // Update the views.
  [_mSvShopBody setHidden:(set ? YES : NO)];
  [_mPbShopQuery setHidden:(set ? NO : YES)];
  if (set) {
    [_mPbShopQuery startAnimating];
  }
  else {
    [_mPbShopQuery stopAnimating];
  }
  
  // Invalidate to redraw them
  [_mSvShopBody setNeedsDisplay];
  [_mPbShopQuery setNeedsDisplay];
}

- (void)createButtons {
  
  // Get the button images.
  UIImage *shopButtonImage = [UIImage imageNamed:@"button_shop"];
  
  CGFloat offset = 0;
  
  /**
   * RESTORE TRANSACTIONS BUTTON.
   */
  
  /**
   * UILabel.
   */
  UILabel *restoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(_rowXOffsetLabel,
                                                                 (_rowHeight * offset) + _descriptionHeight,
                                                                 _screenWidth,
                                                                 _rowHeight)];
  restoreLabel.text = @"Restore Purchases";
  [restoreLabel setContentMode:UIViewContentModeLeft];
  [restoreLabel setAutoresizingMask:UIViewAutoresizingNone];
  [restoreLabel setTextColor:[UIColor whiteColor]];
  [restoreLabel setBackgroundColor:[UIColor clearColor]];
  [restoreLabel setTextAlignment:UITextAlignmentLeft];
  [restoreLabel setFont:_rowFont];
  
  [_mSvShopBody addSubview:restoreLabel];
  
  /**
   * UIButton.
   */
  
  UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [restoreButton addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  [restoreButton setImage:shopButtonImage forState:UIControlStateNormal];
  [restoreButton setImage:[UIImage imageNamed:@"button_shop_disabled"]
              forState:UIControlStateDisabled];
  restoreButton.frame = CGRectMake(_rowXOffsetButton - shopButtonImage.size.width,
                                (_rowHeight * offset)  + _descriptionHeight,
                                shopButtonImage.size.width,
                                _rowHeight);
  [restoreButton setContentMode:UIViewContentModeScaleAspectFit];
  [restoreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
  [restoreButton setTag:14];
  
  [_mSvShopBody addSubview:restoreButton]; 
  
  offset++;
  
  /**
   * PURCHASE BUTTONS.
   */
  
  // Iterate through each category row.
  for (NSInteger i = 0; i < [_mVariableData count]; i++) {
    
    // Store the current iteration's item object locally.
    Variable *variable = [_mVariableData objectAtIndex:i];
    CGFloat position = i + offset;
    
    /**
     * UILabel.
     */
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(_rowXOffsetLabel,
                                                                   (_rowHeight * position) + _descriptionHeight,
                                                                   _screenWidth,
                                                                   _rowHeight)];
    itemLabel.text = [variable.key stringByAppendingString:@" Feature"];
    [itemLabel setContentMode:UIViewContentModeLeft];
    [itemLabel setAutoresizingMask:UIViewAutoresizingNone];
    [itemLabel setTextColor:[UIColor whiteColor]];
    [itemLabel setBackgroundColor:[UIColor clearColor]];
    [itemLabel setTextAlignment:UITextAlignmentLeft];
    [itemLabel setFont:_rowFont];

    [_mSvShopBody addSubview:itemLabel];

    /**
     * UIButton.
     */

    UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [itemButton addTarget:self
                   action:@selector(onClick:)
         forControlEvents:UIControlEventTouchUpInside];
    [itemButton setImage:shopButtonImage forState:UIControlStateNormal];
    [itemButton setImage:[UIImage imageNamed:@"button_shop_disabled"]
                   forState:UIControlStateDisabled];
    itemButton.frame = CGRectMake(_rowXOffsetButton - shopButtonImage.size.width,
                                  (_rowHeight * position)  + _descriptionHeight,
                                  shopButtonImage.size.width,
                                  _rowHeight);
    [itemButton setContentMode:UIViewContentModeScaleAspectFit];
    [itemButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    // Set tag as the viewtype _ sku
    [itemButton setStringTag:[@"UIButton_" stringByAppendingString:variable.sku]];
     
    // Store this data in the corresponding holder hash map
    [_mIbHashMap setValue:itemButton forKey:variable.sku];

    [_mSvShopBody addSubview:itemButton];

  }
  
}

- (void)alert:(NSString *)message {
  
  [[[UIAlertView alloc] initWithTitle:nil
                              message:message
                             delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                        nil)
                    otherButtonTitles:nil] show];
}

- (void)checkDatabase {
  // Check to see if the corresponding row exists in the database
  // and is enabled. If not, we need to enable it.
  for (NSInteger i = 0; i < [_mVariableData count]; i++) {
    
    // Store the current iteration's item object locally.
    Variable *variable = [_mVariableData objectAtIndex:i];
    
    // If the user doesn't have it in the data base but has it in
    // the inventory, the product hasn't yet been locally registered
    // so register it.
    if ([variable.value isEqualToString:@"0"]) {
      if ([[_mHas objectForKey:variable.sku] boolValue]) {
        
        // Database check!
        
        // Call the create method right just in case the user
        // has
        // never run the app before. If a database does not
        // exist,
        // the prepopulated one will be copied from the assets
        // folder. Else, a connection is established.
        [_mDbNodeHelper createDatabase];
        // Enable the coloring book in the database.
        [_mDbNodeHelper updateVariable:variable.identifier
                                column:@"value"
                                 value:@"1"];
        // Update the local cache for consistency
        variable.value = @"1";
        
        // Flush the buffer.
        [_mDbNodeHelper flushQuery];
        
        // This activity no longer needs the connection, so
        // close
        // it.
        [_mDbNodeHelper close];
        
        // A quick toast to confirm updated content in cases where a new
        // purchase has just occurred or a previous purchase has been
        // reinstated.
        // TODO: Decouple both cases and display an alert dialog for each case
        // so its more obvious.
        [self.view makeToast:@"Your content has been updated."
                    duration:5.0
                    position:@"bottom"];
      }
    }
    // Else the product has been locally registered, so just set the
    // local boolean to match correspondingly.
    else if ([variable.value isEqualToString:@"1"]) {
      [_mHas setValue:[NSNumber numberWithBool:YES] forKey:variable.sku];
    }
  }
}

- (void)loadData {
  
  // Database check!
  
  // Call the create method right just in case the user has never run the
  // app before. If a database does not exist, the prepopulated one will
  // be copied from the assets folder. Else, a connection is established.
  [_mDbNodeHelper createDatabase];
  
  // Query the database for all purchased features.
  
  // Execute the query.
  _mVariableData = [_mDbNodeHelper getVariableListData];
  // Flush the buffer.
  [_mDbNodeHelper flushQuery];
  
  // This activity no longer needs the connection, so close it.
  [_mDbNodeHelper close];
  
}

- (IBAction)onClick:(id)sender {
  
  // Standard tag switches.
  switch ([sender tag]) {
      // The return button.
    case 13: {
      
      // Pop the current ViewController.
      [self.navigationController popViewControllerAnimated:YES];
      
    }
      break;
      
      // The restore button.
    case 14: {
      
      [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
      
    }
      
      break;
  }
  
  // Iterate through the views.
  // update the shop buttons to reflect whether or not the user has bought
  // the item.
  for (NSString *sku in _mIbHashMap) {
    
    // Store a reference to the current iteration's Image Holder.
    UIButton *ibHolder = [_mIbHashMap objectForKey:sku];
    
    // If the clicked view tag matches this iteration's view tag, launch the
    // purchase flow for this item.
    if ([[sender getStringTag] isEqualToString:[ibHolder getStringTag]]) {
      [self setWaitScreen:YES];
      
      // Check whether payments are enabled on the device.
      if ([SKPaymentQueue canMakePayments]) {
        
        // Launch the purchase flow.
        
        // Create a payment object and add it to the payment queue.
        SKProduct *selectedProduct = [_myProducts objectForKey:sku];
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
      }
      else {
        // Warn the user that purchases are disabled.
        [self alert:@"Your device has purchases disabled. Please enable your device's purchase feature to make app purchases."];
      }
    }
  }
  
}

// Implements viewDidUnload.
- (void)viewDidUnload {
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

@end
