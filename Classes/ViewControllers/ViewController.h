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
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "NodeDatabase.h"
#import "NodeListViewController.h"
#import "SettingsViewController.h"
#import "KGModal.h"
#import "Colors.h"

// Displays the default menu screen.
@interface ViewController : UIViewController {
  
 @private
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  
  // Define the database access property.
  NodeDatabase *_mDbNodeHelper;
  
  // Define views
  UIWebView *_infoView;
  UIImageView *_mIvBackground;
  UIButton *_mButtonFiles;
  UIButton *_mButtonBookmarks;
  UIButton *_mButtonSettings;
  UIButton *_mButtonHelp;
  UIImageView *_mBgImage;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, assign) BOOL isTablet;
@property(nonatomic, strong) UIImageView *mIvBackground;
@property(nonatomic, strong) IBOutlet UIButton *mButtonFiles;
@property(nonatomic, strong) IBOutlet UIButton *mButtonBookmarks;
@property(nonatomic, strong) IBOutlet UIButton *mButtonSettings;
@property(nonatomic, strong) IBOutlet UIButton *mButtonHelp;
@property(nonatomic, strong) IBOutlet UIImageView *mBgImage;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
