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

#import "NodeViewController.h"

#import <AdSupport/ASIdentifierManager.h>

@interface NodeViewController ()

@end

@implementation NodeViewController

@synthesize mTextSizeArray = _mTextSizeArray;
@synthesize mDbNodeHelper = _mDbNodeHelper;
@synthesize mNodeData = _mNodeData;
@synthesize mVariableData = _mVariableData;
@synthesize mId = _mId;
@synthesize wvNodeBody = _wvNodeBody;
@synthesize isTablet = _isTablet;
@synthesize adBannerView = _adBannerView;
@synthesize adBannerViewIsVisible = _adBannerViewIsVisible;

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
    // Set initial color so initial transitions don't show a white bg.
    _wvNodeBody.backgroundColor = [UIColor blackColor];
    [_wvNodeBody loadHTMLString:[NSString stringWithFormat:@"<html><head></head><body bgcolor=\"#000000\" text=\"#C4C4C4\"></body></html>"]
                               baseURL:nil];

    // Make the scrollbar indicator white.
    _wvNodeBody.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _wvNodeBody.scrollView.backgroundColor = [UIColor blackColor];
  }
  return self;
}

// Implements viewDidLoad.
- (void)viewDidLoad {
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
  
  // Set padding for the return button and progress indicator.
  CGFloat padding = 0;
  
  if (_isTablet) {
    padding = 10;
  }
  else {
    padding = 4;
  }
  _screenWidthPadded = _screenWidth - (padding * 2);
  _screenHeightPadded = _screenHeight - (padding * 2);
  _screenMin = fminf(_screenWidthPadded, _screenHeightPadded);
  
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
  
  // TITLE VIEW
  // ALGORITHMS
  
  UIFont *titleFont;
  
  if (_isTablet) {
    titleFont = [UIFont boldSystemFontOfSize:40];
  }
  else {
    titleFont = [UIFont boldSystemFontOfSize:16];
  }
  
  UIImage *returnButtonImage = [UIImage imageNamed:@"button_return"];
  CGFloat titleHeight = returnButtonImage.size.height;
  CGFloat totalButtonWidth = returnButtonImage.size.width * 2;
  
  // TITLEVIEW
  
  _titleView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        0,
                                                        _screenWidth,
                                                        titleHeight)];
  [_titleView setBackgroundColor:[UIColor blackColor]];
  [_titleView setContentMode:UIViewContentModeScaleAspectFit];
  [_titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  
  // RETURN BUTTON
  
  // Set padding for the return button and progress indicator.
  CGFloat returnButtonY = (titleHeight / 2) - (returnButtonImage.size.height / 2);
  CGFloat returnButtonX = 0;
  CGFloat bookmarksButtonX = _screenWidth - (returnButtonImage.size.width * 2);
  CGFloat settingsButtonX = _screenWidth - returnButtonImage.size.width;
  
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
  [_mIbReturn setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbReturn setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbReturn setTag:13];
  
  [_titleView addSubview:_mIbReturn];
  
  
  // BOOKMARK BUTTON
  
  UIButton *bookmarksButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [bookmarksButton addTarget:self
                      action:@selector(onClick:)
            forControlEvents:UIControlEventTouchUpInside];
  UIImage *bookmarksButtonImage = [UIImage imageNamed:@"button_bookmarks_icon"];
  [bookmarksButton setImage:bookmarksButtonImage forState:UIControlStateNormal];
  bookmarksButton.frame = CGRectMake(bookmarksButtonX,
                                     returnButtonY,
                                     bookmarksButtonImage.size.width,
                                     bookmarksButtonImage.size.height);
  [bookmarksButton setContentMode:UIViewContentModeScaleAspectFit];
  [bookmarksButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
  [bookmarksButton setTag:1];
  
  [_titleView addSubview:bookmarksButton];
  
  // Create a reference to this via via an instance variable.
  _bNodeBookmark = bookmarksButton;
  
  // SETTINGS BUTTON
  
  UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [settingsButton addTarget:self
                     action:@selector(onClick:)
           forControlEvents:UIControlEventTouchUpInside];
  UIImage *settingsButtonImage = [UIImage imageNamed:@"button_settings_icon"];
  [settingsButton setImage:settingsButtonImage
                  forState:UIControlStateNormal];
  settingsButton.frame = CGRectMake(settingsButtonX,
                                    returnButtonY,
                                    settingsButtonImage.size.width,
                                    settingsButtonImage.size.height);
  [settingsButton setContentMode:UIViewContentModeScaleAspectFit];
  [settingsButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
  [settingsButton setTag:2];
  
  [_titleView addSubview:settingsButton];
  
  // Create a reference to this via via an instance variable.
  _bNodeSettings = settingsButton;
  
  // TITLE LABEL
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalButtonWidth,
                                                                  0,
                                                                  _screenWidth - (totalButtonWidth * 2),
                                                                  titleHeight)];
  [titleLabel setContentMode:UIViewContentModeLeft];
  [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [titleLabel setTextColor:[Colors colorFromHexString:@"#C4C4C4FF"]];
  [titleLabel setBackgroundColor:[UIColor clearColor]];
  [titleLabel setTextAlignment:UITextAlignmentCenter];
  [titleLabel setFont:titleFont];
  [titleLabel setLineBreakMode:UILineBreakModeTailTruncation];
  
  [_titleView addSubview:titleLabel];
  
  [[self view] addSubview:_titleView];
  
  
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
  //background. 0 indicate that the image created should be at the scale of the
  // main screen, thus proper scaling for all devices.
  UIGraphicsBeginImageContextWithOptions(filesShineLayer.frame.size, NO, 0);
  [filesShineLayer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *filesImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [titleViewBg setImage:filesImage];
  
  [_titleView addSubview:titleViewBg];
  [_titleView sendSubviewToBack:titleViewBg];
  
  
  // WEBVIEW
  _titleHeight = titleHeight;
  _wvNodeBody.frame = CGRectMake(0,
                                 titleHeight,
                                 _screenWidth,
                                 (_screenHeight - titleHeight));
  [_wvNodeBody setContentMode:UIViewContentModeScaleAspectFit];
  [_wvNodeBody setAutoresizingMask:(UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleHeight)];
  
  // Set initial color so initial transitions don't show a white bg.
  _wvNodeBody.backgroundColor = [UIColor clearColor];
  _wvNodeBody.opaque = NO;
  
  // Make the scrollbar indicator white.
  UIScrollView *webScroller = (UIScrollView *) [[_wvNodeBody subviews] objectAtIndex:0];
  [webScroller setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
  
  
  /**
   * Database source.
   */
  
  // Create our database access object.
  _mDbNodeHelper = [[NodeDatabase alloc] init];
  
  // Call the create right after initializing the helper, just in case
  // the user has never run the app before.
  [_mDbNodeHelper createDatabase];
  
  // Query the database for a node containing the id which was passed
  // from BrowseActivity.
  _mNodeData = [_mDbNodeHelper getNodeData:self.mId];
  // Get variable data in case ads are off.
  _mVariableData = [_mDbNodeHelper getVariableListData];
  // Define whether or not a bookmark is currently set for the
  // node.
  NSInteger result = 0;
  result = [_mDbNodeHelper getNodeIsBookmarked:_mId];
  
  // Set the initial bookmark button state based on the result
  if (result == 0) {
    [_bNodeBookmark setSelected:NO];
  }
  else {
    [_bNodeBookmark setSelected:YES];
  }
  
  // Close the database.
  [_mDbNodeHelper close];
  
  // Populate the text fields with corresponding data from the SQLite
  // database.
  titleLabel.text = _mNodeData.title;
  
  // Render any custom tags if necessary.
  _mNodeData.body = [self renderCustomTags:_mNodeData.body];
  
  // Load the image resource path.
  NSString *path = [[NSBundle mainBundle] bundlePath];
  NSURL *baseUrl = [NSURL fileURLWithPath:path];
  
  // Set font styling.
  UIFont *font = [UIFont systemFontOfSize:16.0f];
  
  // Get the set or default preference for text size (the index).
  NSInteger defaultInteger = 2;
  
  NSInteger fontSize = [[_mTextSizeArray objectAtIndex:[Preferences getPreferenceInt:@"textSize" defaultValue:defaultInteger]] intValue];
  
  // Populate the text fields with corresponding data from the SQLite
  // database.
  // Set the text size of the webview based on the preference setting.
  NSString *data = [NSString stringWithFormat:@"<!DOCTYPE html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=10.0, user-scalable=yes\"><link rel=\"stylesheet\"  href=\"nodeactivity.css\"><script src=\"nodeactivity.js\"></script><style type=\"text/css\"> html { -webkit-text-size-adjust: none; } body { font-family: \"%@\"; font-size: %dpx; margin: 0; padding: %fpx; } img { width: %fpx; } </style></head><body bgcolor=\"#000000\" text=\"#C4C4C4\">%@</body></html>", font.familyName, fontSize, padding, _screenMin, _mNodeData.body];
  
  [_wvNodeBody loadHTMLString:data baseURL:baseUrl]; 

  /**
   * iAds and AdMob Mediation.
   */

  for (NSInteger i = 0; i < [_mVariableData count]; i++) {
    
    // Store the current iteration's Variable locally.
    Variable *variable = [_mVariableData objectAtIndex:i];
    
    if ([variable.sku isEqualToString:@"001_no_ads"]) {
      if ([variable.value isEqualToString:@"0"]) {
        
        [self createAdBannerView];
        
        GADRequest *adRequest = [GADRequest request];
        adRequest.testDevices = [NSArray arrayWithObjects:
                                 GAD_SIMULATOR_ID,
                                 nil];
        
        // Set the ad style colors.
        GADAdMobExtras *extras = [[GADAdMobExtras alloc] init];
        extras.additionalParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"000000", @"color_bg",
                                       @"FFFFFF", @"color_link",
                                       @"C4C4C4", @"color_text",
                                       @"000000", @"bg_top",
                                       @"000000", @"border",
                                       @"FFFFFF", @"color_url",
                                       nil];
        [adRequest registerAdNetworkExtras:extras];
        
        // Configure autoresizing masks and content mode.
        [_adBannerView setContentMode:UIViewContentModeLeft];
        [_adBannerView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)];
        
        // Initiate a generic request to load an ad.
        [_adBannerView loadRequest:[GADRequest request]];
        
      }
    }
  }
}

// Creates the initial adView and set its size baesd on orientation.
- (void)createAdBannerView {
  Class classAdBannerView = NSClassFromString(@"GADBannerView");
  if (classAdBannerView != nil) {
    
    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
      _adBannerView = [[classAdBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    }
    else
    {
      _adBannerView = [[classAdBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    }
    
    // Specify the ad's "unit identifier."
    _adBannerView.adUnitID = @"YOUR_UNIT_ID_HERE";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    _adBannerView.rootViewController = self;
    
    // Position the ad right below the screen.
    [_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, _screenHeight)];

    // Set the ad delegate to handle ad events.
    [_adBannerView setDelegate:self];
    
    // Add the adview to the main view.
    [[self view] addSubview:_adBannerView];

  }
     
}

// Invoked whenever an ad is successfully loaded.
  
- (void)adViewDidReceiveAd:(GADBannerView *)view {
  
  if (!_adBannerViewIsVisible) {
    
    _adBannerViewIsVisible = YES;
    [self fixupAdView:[UIDevice currentDevice].orientation];
    view.hidden = NO;
    
    // Ensure that the banner view is at the front.
    [[self view] bringSubviewToFront:_adBannerView];
    
  }
}

// Invoked whenever an ad fails to load.
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  
  if (_adBannerViewIsVisible) {
    
    _adBannerViewIsVisible = NO;
    [self fixupAdView:[UIDevice currentDevice].orientation];
    
    view.hidden = YES;
  }
  
}

// Define a common function for choosing an ad size based on the device's
// orientation.
- (void)fixupAdView:(UIDeviceOrientation)toInterfaceOrientation {
  
  if (_adBannerView != nil ) {
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [_adBannerView setAdSize:kGADAdSizeSmartBannerLandscape];
    }
    else
    {
      [_adBannerView setAdSize:kGADAdSizeSmartBannerPortrait];
    }
    
    //[UIView beginAnimations:@"fixupViews" context:nil];
    
    if (_adBannerViewIsVisible) {
      CGRect contentViewFrame = _wvNodeBody.frame;
      contentViewFrame.size.height = (self.view.frame.size.height - _titleHeight) - _adBannerView.frame.size.height;
      _wvNodeBody.frame = contentViewFrame;
      
      CGRect adBannerViewFrame = [_adBannerView frame];
      adBannerViewFrame.origin.x = 0;
      adBannerViewFrame.origin.y = self.view.frame.size.height - _adBannerView.frame.size.height;
      [_adBannerView setFrame:adBannerViewFrame];
    }
    else {
      CGRect contentViewFrame = _wvNodeBody.frame;
      contentViewFrame.size.height = (self.view.frame.size.height - _titleHeight);
      _wvNodeBody.frame = contentViewFrame;
      
      CGRect adBannerViewFrame = [_adBannerView frame];
      adBannerViewFrame.origin.x = 0;
      adBannerViewFrame.origin.y = self.view.frame.size.height;
      [_adBannerView setFrame:adBannerViewFrame];
    }
    //[UIView commitAnimations];
  }
  
}

// Implements viewWillAppear.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Update output based on stored preferences, if any.
  [self updateView];
  
  // iAds
  [self fixupAdView:[UIDevice currentDevice].orientation];
  
}


// Updates the text preview based on text configuration preferences.
- (void)updateView {

  // Get the set or default preference for text size (the index).
  NSInteger defaultInteger = 2;
  
  NSInteger fontSize = [[_mTextSizeArray objectAtIndex:[Preferences getPreferenceInt:@"textSize" defaultValue:defaultInteger]] intValue];
  
  // Use JavaScript to inject the new font size.
  [_wvNodeBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.style.fontSize = '%dpx';", fontSize]];
  
  // Update the bookmark button image in case the user changed the bookmark
  // state.
  if (_bNodeBookmark.selected == NO) {
    [_bNodeBookmark setImage:[UIImage imageNamed:@"button_bookmarks_icon"]
                   forState:UIControlStateNormal];
  }
  else {
    [_bNodeBookmark setImage:[UIImage imageNamed:@"button_bookmarks_remove_icon"]
                   forState:UIControlStateNormal];
  }
  
  // Update image sizes.
  [_wvNodeBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"updateImages(%f);", _screenMin]];
}

- (IBAction)onClick:(id)sender {
  
  switch ([sender tag]) {
      
      // Bookmark Button
    case 1: {
      
      // Define a boolean integer to contain whether or not we should
      // bookmark the current node.
      NSInteger isBookmarked = 0;
      
      NSString *resultText = @"";
      
      // If a bookmark is currently not set, add one.
      if (!_bNodeBookmark.selected) {
        isBookmarked = 1;
        
        // Set the music toggle preference to be the opposite of what it
        // currently is.
        _bNodeBookmark.selected = YES;
        ;
        resultText = @"Bookmark has been added.";
      } else {
        // Else remove it.
        isBookmarked = 0;
        
        // Set the music toggle preference to be the opposite of what it
        // currently is.
        _bNodeBookmark.selected = NO;
        
        resultText = @"Bookmark has been removed.";
      }
      
      // Create our database object so we can communicate with the db.
      _mDbNodeHelper = [[NodeDatabase alloc] init];
      
      // Call the createDatabase() function...just in case for some
      // weird reason the database does not yet exist. Otherwise, it will load
      // our database for use.
      [_mDbNodeHelper createDatabase];
      
      // Query the database to set/remove a bookmark for the current
      // node.
      [_mDbNodeHelper updateNode:_mId
                          column:@"is_bookmarked"
                           value:isBookmarked];
      
      // Close the database.
      [_mDbNodeHelper close];
      
      // Display a toast confirming what just happened.
      [self.view makeToast:resultText
                  duration:3.0
                  position:@"bottom"];
      
      // Update the preview based on the new preference.
      [self updateView];
    }
      
      break;
      
      // Settings Button
    case 2: {
      
      // Launch the settings screen.
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
      
      // The Return button.
    case 13: {
      [self.navigationController popViewControllerAnimated:YES];
    }
      
      break;
  }
  
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

// Handles any necessary programmatic changes that need to occur on device
// orientation change.
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                 duration:(NSTimeInterval)duration {
  
  // iAds
  if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    _isPortrait = NO;
    [self fixupAdView:UIDeviceOrientationLandscapeLeft];
    
  }
  else {
    _isPortrait = YES;
    [self fixupAdView:UIDeviceOrientationPortrait];
  }
  [self updateView];
}

// Renders tags placed in the node and returns the entired body of the node,
// whether it has been rendered or not.
- (NSString *) renderCustomTags:(NSString *)nodeString {
  
  NSString *syntax = @"\\[video\\s+?(.*?)(?:\\s+?\\|\\s+?(.*?))?\\]";
  NSError *errorSyntax = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:syntax options:0 error:&errorSyntax];
  if (!regex) {
    // Output a message.
    [[[UIAlertView alloc] initWithTitle:[errorSyntax localizedDescription]
                                message:[errorSyntax localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
  }
  NSArray *matches = [regex matchesInString:nodeString
                                    options:0
                                      range:NSMakeRange(0, [nodeString length])];
  CGFloat width = _screenMin;
  CGFloat height = .75f * width;
  // Will contain the rendered data. Needed because live updates on nodeString
  // invalidate regex range data and replacements won't work properly.
  NSString *newNodeString = [nodeString copy];
  
  for (NSTextCheckingResult *match in matches) {
    NSString *matchString = [nodeString substringWithRange:[match rangeAtIndex:0]];
    NSString *source = nil;
    NSString *name = nil;
    if (!NSEqualRanges([match rangeAtIndex:1], NSMakeRange(NSNotFound, 0))) {
      source = [nodeString substringWithRange:[match rangeAtIndex:1]];
    }
    if (!NSEqualRanges([match rangeAtIndex:2], NSMakeRange(NSNotFound, 0))) {
      // This value is not currently used, as iOS embed the video with all the
      // necessary details.
      name = [nodeString substringWithRange:[match rangeAtIndex:2]];
    }
    
    // [String length] returns 0 if the string is nil or empty.
    if ([source length] != 0) {
      // Youtube Regex
      NSString *syntaxYoutube = @"(?:https?:\\/\\/)?(?:www\\.)?youtu(?:\\.be|be\\.com)\\/(?:watch\\?v=)?([\\w\\-]{10,})";
      NSError *errorSyntaxYoutube = NULL;
      NSRegularExpression *regexYoutube = [NSRegularExpression regularExpressionWithPattern:syntaxYoutube options:0 error:&errorSyntaxYoutube];
      if (!regexYoutube)
      {
        // Output a message.
        [[[UIAlertView alloc] initWithTitle:[errorSyntaxYoutube localizedDescription]
                                    message:[errorSyntaxYoutube localizedFailureReason]
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                              nil)
                          otherButtonTitles:nil] show];
      }
      // There should only be one match, so we're using the first index only.
      NSTextCheckingResult *matchYoutube = [[regexYoutube matchesInString:source
                                                                  options:0
                                                                    range:NSMakeRange(0, [source length])] objectAtIndex:0];
      
      // Truncate any decimal portions.
      NSInteger intWidth = (NSInteger) width;
      NSInteger intHeight = (NSInteger) height;
      
      if (matchYoutube != nil) {
        // Build a hash of search and replace values [search] => replace.
        // NSRegularExpression uses data it finds after scanning the entire
        // string, so live updates invalidate that data and cause what would
        // look like wrong replacements.
        NSString *youtubeId = [source substringWithRange:[matchYoutube rangeAtIndex:1]];
        NSString *replacementString = [NSString stringWithFormat:@"<iframe width=\"%d\" height=\"%d\" src=\"http://www.youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen></iframe>", intWidth, intHeight, youtubeId];
        newNodeString = [newNodeString stringByReplacingOccurrencesOfString:matchString withString:replacementString];
      }
    }
  }
  
  return newNodeString;
}

@end
