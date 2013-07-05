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

#import "NSString+RegexSplitAdditions.h"

@implementation NSString (RegexSplitAdditions)

- (NSArray *)componentsSeparatedByPattern:(NSString *)pattern {
  NSMutableArray *items = [[NSMutableArray alloc] init];
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:pattern
                                options:NSRegularExpressionAnchorsMatchLines
                                error:&error];
  
  NSMutableString *mutableString = [self mutableCopy];
  // keeps track of what has already been added to the result split array.
  NSInteger lastOffset = 0;
  for (NSTextCheckingResult* result in [regex matchesInString:self
                                                      options:0
                                                        range:NSMakeRange(0, [self length])]) {
    NSRange resultRange = [result range];
    NSInteger rangeLength = resultRange.location - lastOffset;
    
    NSString *substring = [mutableString substringWithRange:NSMakeRange(lastOffset, rangeLength)];
    [items addObject:substring];
    lastOffset = resultRange.location + resultRange.length;
  }
  NSArray *array = [items copy];
  return array;
}

@end
