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
#import <iAd/iAd.h>

#import "GADBannerView.h"
#import "GADAdMobExtras.h"

#import "Preferences.h"
#import "Node.h"
#import "Variable.h"
#import "NodeDatabase.h"
#import "SettingsViewController.h"
#import "Toast+UIView.h"
#import "Colors.h"

// Outputs a single node for a user to read. This includes the title and the
// body. This activity also allows a user to access a modal that lets a user
// change node display settings. These settings are also configurable from the
// Settings Activity.
@interface NodeViewController : UIViewController<UIWebViewDelegate, GADBannerViewDelegate> {
  
 @private
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  BOOL _isPortrait;
  CGFloat _titleHeight;
  
  // Text size array
  NSMutableArray *_mTextSizeArray;
  
  // Define the database access property.
  NodeDatabase *_mDbNodeHelper;
  
  // Define a node object that will store the node data from the database.
  Node *_mNodeData;
  // Define a variable object that will store the variable data from the
  // database.
  NSArray *_mVariableData;
  
  NSInteger _mId;
  UIButton *_bNodeBookmark;
  UIButton *_bNodeSettings;
  UIWebView *_wvNodeBody;
  UIView *_titleView;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
  
  // Ad properties.
  GADBannerView *_adBannerView;
  BOOL _adBannerViewIsVisible;
}

@property(nonatomic, assign) BOOL isTablet;
@property(nonatomic, strong) NSMutableArray *mTextSizeArray;
@property(nonatomic, strong) NodeDatabase *mDbNodeHelper;
@property(nonatomic, strong) Node *mNodeData;
@property(nonatomic, strong) NSArray *mVariableData;
@property(nonatomic, assign) NSInteger mId;
@property(nonatomic, strong) IBOutlet UILabel *labelNodeTitle;
@property(nonatomic, strong) IBOutlet UIWebView *wvNodeBody;
@property(nonatomic, strong) GADBannerView *adBannerView;
@property(nonatomic, assign) BOOL adBannerViewIsVisible;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
