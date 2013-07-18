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

#import "DBUpgradeTask.h"
#import "NodeDatabase.h"

@implementation DBUpgradeTask

- (id)initWithContext:(NodeDatabase *)nodeDatabase
             scriptID:(NSString *)scriptID
{
  self = [super init];
  if (self) {
    // Initialization code
    _mContext = nodeDatabase;
    _mScriptID = scriptID;
  }
  return self;
}

- (void)execute {
  [self onPreExecute];
  // Initialize the handler
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^(void) {
    [self run];
    
    // Once the main task is done, run the onPostExecute hook on the
    // main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
      // main task is done. Call onPostExecute on the main thread.
      [self onPostExecute];
    });
  });
}

- (void)onPreExecute {
  _mContext.mIsUpgradeTaskInProgress = YES;
  
  _alert = [[UIAlertView alloc] initWithTitle:@"[processing]" message:@"Acquiring new files..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
  [_alert show];
  
  if(_alert != nil) {
    _vcIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _vcIndicator.center = CGPointMake(_alert.bounds.size.width / 2, _alert.bounds.size.height - _vcIndicator.bounds.size.height - 6);
    [_vcIndicator startAnimating];
    [_alert addSubview:_vcIndicator];
    [_vcIndicator startAnimating];
  }
}

- (void)run {
  [_mContext runUpdates:_mScriptID];
}

- (void)onPostExecute {
  _mContext.mIsUpgradeTaskInProgress = NO;
  [_vcIndicator stopAnimating];
  [_alert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
