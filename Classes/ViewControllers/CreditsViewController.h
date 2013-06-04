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
#import "Colors.h"

// Displays an animated activity screen with scrolling credits.
@interface CreditsViewController : UIViewController {
  
 @private
  
  // Define views.
  UIScrollView *_mSvCreditsBody;
  
  // Define display metric properties
  CGFloat _mScreenWidth;
  CGFloat _mScreenHeight;
  BOOL _isPortrait;
  
  // Define scroll animation properties.
  CGFloat _mVerticalScrollMax;
  CGFloat _mVerticalScrollMin;
  NSTimer *_mScrollTimer;
  CGFloat _mScrollPos;
  
  // Use for solo bitmap.
  UIImage *_image;
  
  // Define the credits display arrays.
  NSMutableArray *_mImageNameArray;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, strong) IBOutlet UIScrollView *mSvCreditsBody;
@property(nonatomic, assign) CGFloat mScreenWidth;
@property(nonatomic, assign) CGFloat mScreenHeight;
@property(nonatomic, assign) BOOL isPortrait;
@property(nonatomic, assign) CGFloat mVerticalScrollMax;
@property(nonatomic, assign) CGFloat mVerticalScrollMin;
@property(nonatomic, strong) IBOutlet NSTimer *mScrollTimer;
@property(nonatomic, assign) CGFloat mScrollPos;
@property(nonatomic, strong) IBOutlet UIImage *image;
@property(nonatomic, strong) NSMutableArray *mImageNameArray;


// Adds images to the view. This is extendible to multiple images, but we
// are currently only using one very large credits image.
- (void)addImagesToView;

// Calculates and sets the maximum scroll value.
- (void)getScrollMaxAmount;

// Initiates the scrolling animation using a Timer.
- (void)startAutoScrolling;

// Moves the scroll view. This is called by the Timer Tick.
- (void)moveScrollView:(NSTimer *)theTimer;

// GCs the timer object.
- (void)clearTimers;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
