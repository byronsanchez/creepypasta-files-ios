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
#import <StoreKit/StoreKit.h>

#import "NodeDatabase.h"
#import "Colors.h"
#import "UIButton+StringTagAdditions.h"
#import "Toast+UIView.h"

// Outputs a list of items that can be bought via the marketplace as well as
// corresponding buy buttons.
@interface ShopViewController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
  
 @private
  
  // Define the database access property.
  NodeDatabase *_mDbNodeHelper;
  
  // Define a category object that will store the category data from the
  // database.
  NSArray *_mVariableData;
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  BOOL _isPortrait;
  
  CGFloat _rowXOffsetLabel;
  CGFloat _rowXOffsetButton;
  CGFloat _rowHeight;
  CGFloat _titleHeight;
  CGFloat _descriptionHeight;
  UIFont *_rowFont;
  
  UIView *_titleView;
  
  // (arbitrary) request code for the purchase flow
  // TODO: private static final int RC_REQUEST = 10001;
  
  // The helper object
  // TODO: private IabHelper mHelper;
  
  // Define hash maps for dynamically generated data.
  NSMutableDictionary *_mIbHashMap;
  NSMutableDictionary *_myProducts;
  
  // Does the user have the second coloring book? (String -> Boolean)
  NSMutableDictionary *_mHas;
  
  // Define the necessary views.
  UIActivityIndicatorView *_mPbShopQuery;
  UIScrollView *_mSvShopBody;
  
  // Shop properties.
  SKProductsRequest *_request;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, strong) NSMutableDictionary *mTvHashMap;
@property(nonatomic, strong) NSMutableDictionary *mIbHashMap;
@property(nonatomic, strong) IBOutlet UIScrollView *mSvShopBody;

// Queries product inventory data from the Apple server.
// Input a set of product identifiers for the items I wish to sell.
- (void)requestProductData;

// Handle reponse for the product inventory data request.
// Provides the localized product information for all valid product identifier.
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response;

// Handles a completed transaction.
- (void)provideContent:(NSString *)productIdentifier;

// Handles a transaction result.
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions;

// Handles a completed transaction.
- (void)completeTransaction:(SKPaymentTransaction *)transaction;

// Handles a restored transaction.
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

// Handles a failed transaction.
- (void)failedTransaction:(SKPaymentTransaction *)transaction;

// Restore completed transcations.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;

// Updates UI to reflect model
- (void)updateUi;

// Enables or disables the "please wait" screen.
- (void)setWaitScreen:(BOOL)set;

// Creates buttons for all coloring books in the categories table.
- (void)createButtons;

// Renders a message to the screen for user confirmation.
- (void)alert:(NSString *)message;

// Checks to see if the database contains the purchase information.
- (void)checkDatabase;

// Loads current category status from the database.
- (void)loadData;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
