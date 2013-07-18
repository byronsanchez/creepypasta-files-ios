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

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mIvBackground = _mIvBackground;
@synthesize mButtonFiles = _mButtonFiles;
@synthesize mButtonBookmarks = _mButtonBookmarks;
@synthesize isTablet = _isTablet;
@synthesize mButtonHelp = _mButtonHelp;
@synthesize mButtonSettings = _mButtonSettings;
@synthesize mBgImage = _mBgImage;

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
  
	// Do any additional setup after loading the view, typically from a nib.
  [self.navigationController setNavigationBarHidden:YES];
  
  /*
   * This screen needs to be dynamically positioned to fit each screen
   * size fluidly.
   */
  
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
  
  // LOCALIZED STRINGS
  
  [_mButtonFiles setTitle:NSLocalizedString(@"b_main_browse", nil)
                 forState:UIControlStateNormal];
  [_mButtonBookmarks setTitle:NSLocalizedString(@"b_main_bookmarks", nil)
                     forState:UIControlStateNormal];
  
  /**
   * Database source data.
   */
  
  // Probe the database in case installation or upgrades are necessary.
  _mDbNodeHelper = [[NodeDatabase alloc] init];
  [_mDbNodeHelper createDatabase];
  [_mDbNodeHelper close];
  
  /**
   * Background image.
   */
  
  // Create the background image and add it to the view.
  UIImage *bgImage = [UIImage imageNamed:@"bg"];
  
  _mIvBackground = [[UIImageView alloc] initWithImage:bgImage];
  _mIvBackground.frame = CGRectMake((_screenWidth / 2) - (bgImage.size.width / 2),
                                    (_screenHeight / 2) - (bgImage.size.height / 2),
                                    bgImage.size.width,
                                    bgImage.size.height);
  [_mIvBackground setContentMode:UIViewContentModeCenter];
  [_mIvBackground setAutoresizingMask:(UIViewAutoresizingFlexibleWidth
                                       | UIViewAutoresizingFlexibleHeight)];
  
  [[self view] addSubview:_mIvBackground];
  [[self view] sendSubviewToBack:_mIvBackground];
  
  
  /**
   * Buttons.
   */
  
  // Add gradients to the main button.
  
  // Add Border
  
  _mButtonFiles.layer.cornerRadius = 3.0f;
  _mButtonFiles.layer.masksToBounds = YES;
  _mButtonFiles.layer.borderWidth = 3.0f;
  _mButtonFiles.layer.borderColor = [UIColor colorWithWhite:0.7f
                                                      alpha:1.0f].CGColor;
  
  _mButtonBookmarks.layer.cornerRadius = 3.0f;
  _mButtonBookmarks.layer.masksToBounds = YES;
  _mButtonBookmarks.layer.borderWidth = 3.0f;
  _mButtonBookmarks.layer.borderColor = [UIColor colorWithWhite:0.7f
                                                          alpha:1.0f].CGColor;
  
  // Add Shine
  CAGradientLayer *filesShineLayer = [CAGradientLayer layer];
  filesShineLayer.frame = _mButtonFiles.layer.bounds;
  filesShineLayer.colors = [NSArray arrayWithObjects:
                            (id)[Colors colorFromHexString:@"000000FF"].CGColor,
                            (id)[Colors colorFromHexString:@"555555FF"].CGColor,
                            nil];
  
  filesShineLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
  
  CAGradientLayer *bookmarksShineLayer = [CAGradientLayer layer];
  bookmarksShineLayer.frame = _mButtonBookmarks.layer.bounds;
  bookmarksShineLayer.colors = [NSArray arrayWithObjects:
                                (id)[Colors colorFromHexString:@"000000FF"].CGColor,
                                (id)[Colors colorFromHexString:@"555555FF"].CGColor,
                                nil];
  bookmarksShineLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.0f],
                                   [NSNumber numberWithFloat:1.0f],
                                   nil];
  
  // Render an image based off of the generated gradient and set it as the
  // background. 0 indicate that the image created should be at the scale of the
  // main screen, thus proper scaling for all devices.
  
  //[_mButtonFiles.layer addSublayer:filesShineLayer];
  //[_mButtonBookmarks.layer addSublayer:bookmarksShineLayer];
  
  UIGraphicsBeginImageContextWithOptions(filesShineLayer.frame.size, NO, 0);
  [filesShineLayer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *filesImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [_mButtonFiles setBackgroundImage:filesImage forState:UIControlStateNormal];
  
  UIGraphicsBeginImageContextWithOptions(bookmarksShineLayer.frame.size, NO, 0);
  [bookmarksShineLayer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *bookmarksImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [_mButtonBookmarks setBackgroundImage:bookmarksImage forState:UIControlStateNormal];
  
  // Button positioning
  CGFloat buttonPadding;
  
  if (_isTablet) {
    buttonPadding = 20;
  }
  else {
    buttonPadding = 8;
  }
  
  // Calculate the button positions based on the current screen metrics.
  UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [settingsButton addTarget:self
                     action:@selector(onClick:)
           forControlEvents:UIControlEventTouchUpInside];
  UIImage *settingsButtonImage = [UIImage imageNamed:@"button_settings"];
  [settingsButton setImage:settingsButtonImage forState:UIControlStateNormal];
  settingsButton.frame = CGRectMake(buttonPadding,
                                    _screenHeight - settingsButtonImage.size.height - buttonPadding,
                                    settingsButtonImage.size.width,
                                    settingsButtonImage.size.height);
  [settingsButton setContentMode:UIViewContentModeScaleAspectFit];
  [settingsButton setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin
                                       | UIViewAutoresizingFlexibleTopMargin)];
  [settingsButton setTag:3];
  
  [[self view] addSubview:settingsButton];
  
  UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [helpButton addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  UIImage *helpButtonImage = [UIImage imageNamed:@"button_help"];
  [helpButton setImage:helpButtonImage forState:UIControlStateNormal];
  helpButton.frame = CGRectMake(_screenWidth - helpButtonImage.size.width - buttonPadding,
                                _screenHeight - helpButtonImage.size.height - buttonPadding,
                                helpButtonImage.size.width,
                                helpButtonImage.size.height);
  [helpButton setContentMode:UIViewContentModeScaleAspectFit];
  [helpButton setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin
                                   | UIViewAutoresizingFlexibleTopMargin)];
  [helpButton setTag:4];
  
  [[self view] addSubview:helpButton];
  
  // Update button positioning based on the padding.
  _mButtonSettings.frame = CGRectMake(0,
                                      0,
                                      _mButtonSettings.frame.size.width,
                                      _mButtonSettings.frame.size.height);
  _mButtonHelp.frame = CGRectMake(0,
                                  0,
                                  _mButtonHelp.frame.size.width,
                                  _mButtonHelp.frame.size.height);
  // Update the UIButtons.
  // [filesLayer insertSublayer: filesShineLayer atIndex:0];
  // [bookmarksLayer insertSublayer:bookmarksShineLayer atIndex:0];
  
  // HELP VIEW
  
  CGFloat fontSize;
  
  // If the device is a tablet.
  if (_isTablet) {
    _infoView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 700, 500)];
    fontSize = 40;
  }
  // If the device is a phone
  else {
    _infoView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    fontSize = 16;
  }
  
  // Prevent the white flash
  _infoView.backgroundColor = [UIColor clearColor];
  _infoView.opaque = NO;
  
  // Load the image resource path.
  NSString *path = [[NSBundle mainBundle] bundlePath];
  NSURL *baseUrl = [NSURL fileURLWithPath:path];
  
  // Set font styling.
  UIFont *helpFont = [UIFont systemFontOfSize:fontSize];
  
  // Populate the text fields with corresponding data from the SQLite
  // database.
  // Set the text size of the webview based on the preference setting.
  [_infoView loadHTMLString:[NSString stringWithFormat:@"<html><head><meta name=\"viewport\" /><style type=\"text/css\"> body {font-family: \"%@\"; font-size: %f;} img {max-width: 100%%; width: auto;}</style></head><body text=\"#FFFFFF\">%@</body></html>", helpFont.familyName, helpFont.pointSize, NSLocalizedString(@"tv_help", nil)] baseURL:baseUrl];
  
  // Create layout params with the calculated sizes.
  [_infoView setContentMode:UIViewContentModeScaleToFill];
  
  // For backwards compatibility, we need to manually iterate through the webview to find the scroll view
  UIScrollView *webScroller = (UIScrollView *) [[_infoView subviews] objectAtIndex:0];
  [webScroller setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
  
  // Hide the shadow images that are default in webviews.
  for (UIView *wview in [[[_infoView subviews] objectAtIndex:0] subviews]) {
    if ([wview isKindOfClass:[UIImageView class]]) {
      wview.hidden = YES;
    }
  }
}

// Implements viewWillAppear.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
}

// Implements viewDidUnload.
- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

/*
 - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 // Use the segue identifier to pass invoker data to the new view controller.
 
 if ([segue.identifier isEqualToString:@"sMainToNodeList"]) {
 // Go through the navigation controller to get to the node list controller.
 //UINavigationController *destViewController = segue.destinationViewController;
 //NodeListViewController *controller = (NodeListViewController *) destViewController.topViewController;
 NodeListViewController *controller = segue.destinationViewController;
 // Get the object in the array corresponding to the current row.
 controller.controllerInvoker = @"sMainToNodeList";
 }
 else if ([segue.identifier isEqualToString:@"sMainToBookmarkList"]) {
 // Go through the navigation controller to get to the node list controller.
 //UINavigationController *destViewController = segue.destinationViewController;
 //NodeListViewController *controller = (NodeListViewController *) destViewController.topViewController;
 NodeListViewController *controller = segue.destinationViewController;
 // Get the object in the array corresponding to the current row.
 controller.controllerInvoker = @"sMainToBookmarkList";
 }
 }
 */

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

- (IBAction)onClick:(id)sender {
  switch ([sender tag]) {
      // The files button.
    case 1: {
      NodeListViewController *nodeListViewController;
      
      if (_isTablet) {
        nodeListViewController = [[NodeListViewController alloc] initWithNibName:@"NodeListViewController_iPad"
                                                                          bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          nodeListViewController = [[NodeListViewController alloc] initWithNibName:@"NodeListViewController_iPhoneLarge"
                                                                            bundle:nil];
        }
        else {
          // iPhone Classic
          nodeListViewController = [[NodeListViewController alloc] initWithNibName:@"NodeListViewController_iPhone"
                                                                            bundle:nil];
        }
      }
      
      nodeListViewController.controllerInvoker = @"sMainToNodeList";
      
      [self.navigationController pushViewController:nodeListViewController
                                           animated:YES];
      
    }
      break;
      
      // The bookmarks button.
    case 2: {
      NodeListViewController *nodeListViewController;
      
      if (_isTablet) {
        nodeListViewController = [[NodeListViewController alloc] initWithNibName:@"NodeListViewController_iPad"
                                                                          bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          nodeListViewController = [[NodeListViewController alloc] initWithNibName:@"NodeListViewController_iPhoneLarge"
                                                                            bundle:nil];
        }
        else {
          // iPhone Classic
          nodeListViewController = [[NodeListViewController alloc] initWithNibName:@"NodeListViewController_iPhone"
                                                                            bundle:nil];
        }
      }
      
      nodeListViewController.controllerInvoker = @"sMainToBookmarkList";
      
      [self.navigationController pushViewController:nodeListViewController animated:YES];
    }
      
      break;
      
      // The settings button.
    case 3: {
      SettingsViewController *settingsViewController;
      
      if (_isTablet) {
        settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController_iPad"
                                                                          bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController_iPhoneLarge"
                                                                            bundle:nil];
        }
        else {
          // iPhone Classic
          settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController_iPhone"
                                                                            bundle:nil];
        }
      }
      
      [self.navigationController pushViewController:settingsViewController
                                           animated:YES];
    }
      
      break;
      // The Help Button
    case 4: {
      
      [[KGModal sharedInstance] setShowCloseButton:YES];
      [[KGModal sharedInstance] setAnimateWhenDismissed:NO];
      [[KGModal sharedInstance] showWithContentView:_infoView
                                        andAnimated:NO];
      [[KGModal sharedInstance] setModalBackgroundColor:[Colors colorFromHexString:@"#000000FF"]];
      [[KGModal sharedInstance] setBackgroundDisplayStyle:KGModalBackgroundDisplayStyleSolid];
      
    }
      break;
  }
}

@end
