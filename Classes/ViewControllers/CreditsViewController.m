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

#import "CreditsViewController.h"

@interface CreditsViewController ()

@end


@implementation CreditsViewController

@synthesize mSvCreditsBody = _mSvCreditsBody;
@synthesize mScreenWidth = _mScreenWidth;
@synthesize mScreenHeight = _mScreenHeight;
@synthesize isPortrait = _isPortrait;
@synthesize mVerticalScrollMax = _mVerticalScrollMax;
@synthesize mVerticalScrollMin = _mVerticalScrollMin;
@synthesize mScrollTimer = _mScrollTimer;
@synthesize mScrollPos = _mScrollPos;
@synthesize image = _image;
@synthesize mImageNameArray = _mImageNameArray;

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
  
  // Calculate screen metrics
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  
  if (_isPortrait) {
    // Use standard metrics.
    _mScreenWidth = screenRect.size.width;
    _mScreenHeight = screenRect.size.height;
  }
  else {
    // Use inversed metrics.
    _mScreenWidth = screenRect.size.height;
    _mScreenHeight = screenRect.size.width;
  }
  
  // DETERMINE DEVICE TYPE
  NSInteger device = UI_USER_INTERFACE_IDIOM();
  
  // Set defaults
  _isTablet = NO;
  _isLarge = NO;
  
  switch (device) {
    case UIUserInterfaceIdiomPhone: {
      if ([[UIScreen mainScreen] bounds].size.height == 480) {
        
        // iPhone Classic
        _isLarge = NO;
        
      }
      if ([[UIScreen mainScreen] bounds].size.height == 568) {
        _isLarge = YES;
      }
    }
      break;
      
    case UIUserInterfaceIdiomPad: {
      _isTablet = YES;
    }
      break;
  }
  
  // Define the image name array.
  NSString *file_a;
  
  if (_isPortrait) {
    file_a = @"creepypasta_files_credits_portrait";
  } else {
    file_a = @"creepypasta_files_credits_landscape";
  }
  
  _mImageNameArray = [[NSMutableArray alloc] init];
  [_mImageNameArray addObject:file_a];
  
  // Set the scrollview background color.
  // [[self view] setBackgroundColor:[Colors colorFromHexString:@"#00163BFF"]];
  
  
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
  [_mIbReturn setImage:returnButtonImage forState:UIControlStateNormal];
  [_mIbReturn setAlpha:1.0];
  _mIbReturn.frame = CGRectMake(returnButtonX,
                                returnButtonY,
                                returnButtonImage.size.width,
                                returnButtonImage.size.height);
  [_mIbReturn setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbReturn setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbReturn setTag:13];
  
  [[self view] addSubview:_mIbReturn];
  
  // Add the images to the ScrollView.
  [self addImagesToView];
}

- (void)addImagesToView {
  // Loop through the credits image array.
  for (NSInteger i = 0; i < [_mImageNameArray count]; i++) {
    
    /*
     * UIImage
     */
    
    // Get the image resource information
    UIImage *imageInfo = [UIImage imageNamed:[_mImageNameArray objectAtIndex:i]];
    
    CGFloat inSampleSize = 1;
    CGFloat imageWidth = imageInfo.size.width;
    CGFloat imageHeight = imageInfo.size.height;
    
    // The failed scale image bounds
    CGFloat newWidth;
    CGFloat newHeight;
    
    // The layout bounds.
    CGFloat dstWidth;
    CGFloat dstHeight;
    
    // If the scale fails, we will need to use more memory to perform
    // scaling for the layout to work on all size screens.
    BOOL scaleFailed = NO;
    CGFloat resizeRatioWidth = 1;
    
    // Scale down only if necessary.
    if (imageWidth != _mScreenWidth) {
      resizeRatioWidth =  imageWidth / _mScreenWidth;
      
      inSampleSize = resizeRatioWidth;
      
      // Scaling is needed flag.
      if (inSampleSize <= 1) {
        scaleFailed = YES;
      }
    }
    
    // If the scale failed, that means a scale was needed but didn't happen.
    // We need to create a scaled copy of the image by allocating more
    // memory.
    if (scaleFailed) {
      
      newWidth = ceil((imageWidth / resizeRatioWidth));
      newHeight = ceil((imageHeight / resizeRatioWidth));
      
      CGSize newSize = CGSizeMake(newWidth, newHeight);
      
      UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
      [imageInfo drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
      _image = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      
    } else {
      
      // No scaling was needed in the first place!
      _image = imageInfo;
      newWidth = imageWidth;
      newHeight = imageHeight;
    }
    
    // With the final decoded image info, define the layout bounds (2 *
    // the screen width + the image).
    dstWidth = _mScreenWidth;
    dstHeight = (_mScreenHeight * 2) + newHeight;
    
    // Create layout params with the calculated sizes.
    [_mSvCreditsBody setContentSize:CGSizeMake(dstWidth, dstHeight)];
    
    // Create a UIImageView in which to place the UIImage.
    UIImageView *ibCredits = [[UIImageView alloc] initWithImage:_image];
    [ibCredits setContentMode:UIViewContentModeCenter];
    
    // Add UIImage to the scrollbar.
    [_mSvCreditsBody addSubview:ibCredits];
    
    // Reposition the UIImageView so that it is in the center of the parent view.
    ibCredits.center = [_mSvCreditsBody convertPoint:CGPointFromString([NSString stringWithFormat:@"{%f, %f}",
                                                                        dstWidth / 2,
                                                                        dstHeight / 2])
                                            fromView:_mSvCreditsBody.superview];
  }
}

// Implements viewWillAppear.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Don't Show the navigation bar for this view.
  //[UIView beginAnimations:nil context:NULL];
  //[UIView setAnimationDuration:0.5];
  //[self.navigationController.navigationBar setAlpha:0.0];
  //[UIView commitAnimations];
}


// Implements viewDidAppear.
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Get the max scroll value.
  [self getScrollMaxAmount];
  // Set the initial scroll value to min + 1
  [_mSvCreditsBody setContentOffset:CGPointMake(0, 1)];
  // Start the scroll animation.
  [self startAutoScrolling];
}

- (void)getScrollMaxAmount {
  
  // Get the content size of the scrollview (the total height of
  // all the combined credit image elements).
  // We can also set a max scroll limit by subtracting from this width.
  CGFloat actualHeight = _mSvCreditsBody.contentSize.height;
  // Set the maximum scroll value.
  _mVerticalScrollMax = actualHeight - _mScreenHeight;
  _mVerticalScrollMin = 1;
}

- (void)startAutoScrolling {
  
  // If the timer has not been previously created.
  if (_mScrollTimer == nil) {
    // Create a new timer.
    _mScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                     target:self
                                                   selector:@selector(moveScrollView:)
                                                   userInfo:nil
                                                    repeats:YES];
  }
}

- (void)moveScrollView:(NSTimer *)theTimer {
  
  // Get the current scroll position and make sure it is int casted.
  // Add 1 to the position.
  _mScrollPos = ([_mSvCreditsBody contentOffset].y) + 1.0;
  
  // If the new scrollPos is greater than or equal to the max vertical
  // scroll.
  
  // Loop around at the start of the credits screen.
  if (_mScrollPos <= _mVerticalScrollMin) {
    _mScrollPos = _mVerticalScrollMax - 1.0f;
  }
  
  // Loop around at the end of the credits screen.
  if (_mScrollPos >= _mVerticalScrollMax) {
    // Reset the scroll position.
    _mScrollPos = _mVerticalScrollMin + 1.0f;
  }
  // Set our calculated scroll position to the scrollview.
  [_mSvCreditsBody setContentOffset:CGPointMake(0, _mScrollPos)];
  
}

- (void)clearTimers {
  
  // When this view is killed, make sure to implement proper garbage
  // collection.
  
  // Clean up the timers.
  [_mScrollTimer invalidate];
  _mScrollTimer = nil;
  
}

- (IBAction)onClick:(id)sender {
  
  switch ([sender tag]) {
      // The return button.
    case 13: {
      
      // Clean up the timer before popping the VC.
      [self clearTimers];
      [self.navigationController popViewControllerAnimated:YES];
      
    }
      
      break;
  }
  
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

// Pops the navigation controller on orientation change.
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                 duration:(NSTimeInterval)duration {
  UINavigationController *navController = self.navigationController;
  
  // Pop this controller.
  [navController popViewControllerAnimated:NO];
}

@end
