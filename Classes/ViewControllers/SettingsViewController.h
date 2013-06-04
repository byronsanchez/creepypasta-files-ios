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
#import "Preferences.h"
#import "KGModal.h"
#import "Colors.h"
#import "CreditsViewController.h"
#import "ShopViewController.h"

// Outputs a list of user-configurable settings to affect the user experience of
// the application. Also provides buttons to access other parts of the
// application, such as the shop or to view production credits (this is placed
// here to prevent negative UX due to placing shop and credits somewhere where
// the user can always see them. The settings place might be a good candidate as
// it is not-interfering and consequently, more of an opt-in if you want to
// access the credits or the shop).
@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
  
 @private
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  BOOL _isPortrait;
  
  // An array of NSNumbers
  NSMutableArray *_mTextSizeArray;
  UIButton *_mButtonSettingsTextSize;
  CGFloat _cellCounter;
  
  // Define necessary views.
  UIView *_KGContentView;
  UIView *_titleView;
  UILabel *_titleLabel;
  UILabel *_mCurrentSizeLabel;
  UILabel *_mLabelTextSize;
  UILabel *_mLabelShop;
  UILabel *_mLabelCredits;
  
  UIButton *_mIbReturn;
  UIButton *_mButtonTextSize;
  UIButton *_mButtonShop;
  UIButton *_mButtonCredits;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, strong) NSMutableArray *mTextSizeArray;
@property(nonatomic, strong) IBOutlet UIButton *mButtonSettingsTextSize;

// Updates the text preview based on text configuration preferences.
- (void)updateView;

// Updates the size of the KGModal Frame based on the total table size.
- (void)updateKgFrame:(CGRect)newFrame;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
